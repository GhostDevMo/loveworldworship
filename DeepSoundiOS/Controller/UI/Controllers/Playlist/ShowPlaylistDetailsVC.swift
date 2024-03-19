//
//  ShowPlaylistDetailsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import Alamofire

class ShowPlaylistDetailsVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var shuffleBtn:UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var playlistObject: Playlist?
    var userID:Int = 0
    private var playlistSongsArray = [Song]()
    private var playlistID:Int = 0
    var shuffled:Bool = false
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.setupUI()
        self.setuMusicPlayerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize") {
            if let newvalue = change?[.newKey] {
                let newsize = newvalue as! CGSize
                tableViewHeight.constant = newsize.height
            }
        }
    }
    
    @objc func playSong(_ sender: UIButton) {
        self.view.endEditing(true)
        var indexPath = IndexPath(row: 0, section: 0)
        var randomInt = 0
        if self.playlistSongsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
            AppInstance.instance.AlreadyPlayed = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        } else {
            if AppInstance.instance.AlreadyPlayed {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            } else {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            }
            return
        }
        let songsArray: [Song] = self.playlistSongsArray
        var object = songsArray[indexPath.row]
        if shuffled {
            playlistSongsArray.shuffle()
            randomInt = Int.random(in: 0..<playlistSongsArray.count)
            object = playlistSongsArray[randomInt]
            indexPath = IndexPath(row: randomInt, section: 0)
        }
        if let canListen = object.can_listen, canListen {
            for (i, _) in songsArray.enumerated() {
                if i == indexPath.row {
                    if AppInstance.instance.AlreadyPlayed {
                        if let cell = tableView.cellForRow(at: indexPath) as? SongsTableCells {
                            changeButtonImage(cell.btnPlayPause, play: true)
                            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                            return
                        }
                    } else {
                        if let cell = tableView.cellForRow(at: indexPath) as? SongsTableCells {
                            changeButtonImage(cell.btnPlayPause, play: false)
                        }
                    }
                } else {
                    if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                        changeButtonImage(cell.btnPlayPause, play: true)
                    }
                }
            }
        }
        
        AppInstance.instance.popupPlayPauseSong = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
        }
        self.addToRecentlyWatched(trackId: object.id ?? 0)
        self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true) {
            popupContentController?.musicObject = object
            popupContentController?.musicArray = songsArray
            popupContentController?.currentAudioIndex = indexPath.row
            popupContentController?.delegate = self
                popupContentController?.setup()
        }
    }
    
    @IBAction func shuffleSongList(_ sender: UIButton) {
        self.view.endEditing(true)
        self.shuffled = true
        self.playSong(sender)
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.shuffled = false
        self.playSong(sender)
    }
    
    @IBAction func downloadPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if AppInstance.instance.userProfile?.data?.is_pro == 0 {
            let warningPopupVC = R.storyboard.popups.warningPopupVC()
            warningPopupVC?.delegate = self
            warningPopupVC?.titleText = "Warning"
            warningPopupVC?.messageText = "To activate this service, the account must be upgraded"
            warningPopupVC?.okText = "OK"
            warningPopupVC?.cancelText = "CANCEL"
            self.present(warningPopupVC!, animated: true, completion: nil)
            warningPopupVC?.okButton.tag = 10001
        }else {
            if AppInstance.instance.isLoginUser {
                self.downloadBtn.isEnabled = true
                if Connectivity.isConnectedToNetwork() {
                    for (index, object) in self.playlistSongsArray.enumerated() {
                        var audioString = ""
                        if object.demo_track == "" {
                            audioString = object.audio_location ?? ""
                        }else if object.demo_track != "" && object.audio_location != "" {
                            audioString = object.audio_location ?? ""
                        }else{
                            audioString = object.secure_url ?? ""
                        }
                        
                        if getLocalVideoAdded(url: audioString) {
                            if index == (self.playlistSongsArray.count - 1) {
                                self.view.makeToast("Already added in recently downloaded songs.", duration: 1.0)
                            }
                        }else {
                            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                            AF.download(
                                audioString,
                                to: destination).downloadProgress(closure: { (progress) in
                                    log.verbose("progress = \(progress)")
                                    print(progress.fractionCompleted)
                                }).response(completionHandler: { (DefaultDownloadResponse) in
                                    print(DefaultDownloadResponse)
                                    if let error = DefaultDownloadResponse.error {
                                        self.view.makeToast(error.localizedDescription)
                                        return
                                    }
                                    Async.main {
                                        self.downloadBtn.isEnabled = false
                                        self.downloadBtn.setImage(R.image.ic_circularTick(), for: .normal)
                                        for array in self.playlistSongsArray {
                                            if let url = URL(string: array.secure_url ?? "") {
                                                if url.lastPathComponent == DefaultDownloadResponse.fileURL?.lastPathComponent {
                                                    self.setDownloadSongs(objectToEncode: array)
                                                }
                                            }
                                        }
                                    }
                                })
                        }
                    }
                }else {
                    self.view.makeToast(InterNetError)
                }
            }else{
                self.showLoginAlert(delegate: self)
            }
        }
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let object = self.playlistObject?.url {
            self.share(shareString: object)
        }
    }
    
    @IBAction func morePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let playlistObject = self.playlistObject {
            let panVC: PanModalPresentable.LayoutType = PlayListBottomSheetController(playlist: playlistObject, delegate: self)
            presentPanModal(panVC)
        }
    }
    
    private func setupUI(){
        playBtn.backgroundColor = .lightButtonColor
        playBtn.setTitleColor(.ButtonColor, for: .normal)
        shuffleBtn.backgroundColor = .ButtonColor
        let playList = self.playlistObject
        let url = URL.init(string: playList?.thumbnail_ready ?? "")
        self.playlistNameLabel.text = playList?.name ?? ""
        self.songsCountLabel.text = "\(playList?.songs ?? 0) Songs"
        self.downloadBtn.isHidden = playList?.songs == 0
        thumbnailImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder())
        self.userID = playList?.publisher?.id ?? 0
        self.playlistID = playlistObject?.id ?? 0
        
        self.moreBtn.isHidden = !(self.userID == (AppInstance.instance.userId ?? 0))
        
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        self.fetchPlaylistSongs()
    }
    
    private func setDownloadSongs(objectToEncode: Song) {
        log.verbose("Check = \(UserDefaults.standard.getDownloadSongs(Key: Local.SHARE_SONG.Share_Song))")
        do {
            let data = try PropertyListEncoder().encode(objectToEncode)
            var getDownloadSongsrData = UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song)
            getDownloadSongsrData.append(data)
            UserDefaults.standard.setDownloadSongs(value: getDownloadSongsrData, ForKey: Local.DOWNLOAD_SONG.Download_Song)
            appDelegate.window?.rootViewController?.view.makeToast("Added to recently downloaded songs", duration: 1.0)
        }catch {
            appDelegate.window?.rootViewController?.view.makeToast(error.localizedDescription)
        }
    }
    
    private func share(shareString: String?) {
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func fetchPlaylistSongs(){
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PlaylistManager.instance.getPlayListSongs(playlistId: self.playlistID, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.songs ?? [])")
                                self.playlistSongsArray = success?.songs ?? []
                                
                                
                                for (index, object) in self.playlistSongsArray.enumerated() {
                                    var audioString = ""
                                    if object.demo_track == "" {
                                        audioString = object.audio_location ?? ""
                                    }else if object.demo_track != "" && object.audio_location != "" {
                                        audioString = object.audio_location ?? ""
                                    }else{
                                        audioString = object.secure_url ?? ""
                                    }
                                    
                                    if getLocalVideoAdded(url: audioString) {
                                        if index == (self.playlistSongsArray.count - 1) {
                                            self.downloadBtn.isEnabled = false
                                            self.downloadBtn.setImage(R.image.icn_downloaded_song(), for: .normal)
                                        }
                                    }else {
                                        self.downloadBtn.isEnabled = true
                                        self.downloadBtn.setImage(R.image.icDownloadSquare(), for: .normal)
                                    }
                                }
                                self.btnStackView.isHidden = self.playlistSongsArray.count == 0
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func deletePlaylist(playlistID:Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PlaylistManager.instance.deletePlaylist(playlistId: playlistID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }else if sessionError != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                }
            })
        }else{
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
        }
    }
}

extension ShowPlaylistDetailsVC: PlayListBottomSheetDelegate {
    
    func editButton(_ sender: UIButton, object: Playlist) {
        self.view.endEditing(true)
        guard let vc = R.storyboard.playlist.createPlaylistVC() else { return }
        vc.selectedPlayList = object
        let panVC: PanModalPresentable.LayoutType = vc
        presentPanModal(panVC)
    }
}

extension ShowPlaylistDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            if self.playlistSongsArray.count == 0 {
                return 1
            } else {
                return self.playlistSongsArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as? SongsTableCells
            cell?.startSkelting()
            return cell!
        }else {
            if self.playlistSongsArray.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as? NoDataTableItem
                cell?.selectedBackgroundView()
                return cell!
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as? SongsTableCells
                cell?.selectedBackgroundView()
                cell?.stopSkelting()
                cell?.selectionStyle = .none
                cell?.bind( self.playlistSongsArray[indexPath.row])
                cell?.indexPath = indexPath
                cell?.delegate = self
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return UITableView.automaticDimension
        }else {
            if self.playlistSongsArray.count == 0 {
                return 500.0
            }else {
                return UITableView.automaticDimension
            }
        }
    }
}

extension ShowPlaylistDetailsVC: SongsTableCellsDelegate {
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.playlistSongsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
            AppInstance.instance.AlreadyPlayed = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        } else {
            if AppInstance.instance.AlreadyPlayed {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            } else {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            }
            return
        }
        let songsArray: [Song] = self.playlistSongsArray
        
        let object = songsArray[indexPath.row]
        if let canListen = object.can_listen, canListen {
            for (i, _) in songsArray.enumerated() {
                if i == indexPath.row {
                    if AppInstance.instance.AlreadyPlayed {
                        changeButtonImage(sender, play: true)
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                        return
                    } else {
                        changeButtonImage(sender, play: false)
                    }
                } else {
                    if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                        changeButtonImage(cell.btnPlayPause, play: true)
                    }
                }
            }
        }
        
        AppInstance.instance.popupPlayPauseSong = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
        }
        self.addToRecentlyWatched(trackId: object.id ?? 0)
        self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true) {
            popupContentController?.musicObject = object
            popupContentController?.musicArray = songsArray
            popupContentController?.currentAudioIndex = indexPath.row
            popupContentController?.delegate = self
            popupContentController?.setup()
        }
    }
    
    func moreButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.playlistSongsArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
}

//MARK: - Music Player Notification Handling Functions -
extension ShowPlaylistDetailsVC {
    func setuMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.playlistSongsArray
                if songsArray.count != 0 {
                    if let currentIndex = songsArray.firstIndex(where: { $0.audio_id == popupContentController?.musicObject?.audio_id }) {
                        for (i, song) in songsArray.enumerated() {
                            if i == currentIndex && (song.can_listen ?? false) {
                                if popupContentController?.musicObject?.audio_id == song.audio_id {
                                    if let cell = tableView.cellForRow(at: IndexPath(item: currentIndex, section: 0)) as? SongsTableCells {
                                        if !statusBool {
                                            cell.btnPlayPause.setImage(R.image.icPauseBtn(), for: .normal)
                                        }else{
                                            cell.btnPlayPause.setImage(R.image.ic_playPlayer(), for: .normal)
                                        }
                                    }
                                } else {
                                    if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                                        changeButtonImage(cell.btnPlayPause, play: true)
                                    }
                                }
                            }else {
                                if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                                    changeButtonImage(cell.btnPlayPause, play: true)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            let songsArray: [Song] = self.playlistSongsArray
            for (i, _) in songsArray.enumerated() {
                if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                    changeButtonImage(cell.btnPlayPause, play: true)
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "EVENT_NEXT_TRACK_BTN") { [self] (notification) in
            log.verbose("Notification = \(notification?.object as? Bool ?? false)")
            let statusBool = notification?.object as? Bool
            if statusBool! {
                let songsArray: [Song] = self.playlistSongsArray
                if songsArray.count != 0 {
                    if let currentIndex = songsArray.firstIndex(where: { $0.audio_id == popupContentController?.musicObject?.audio_id }) {
                        let indexPath = IndexPath(item: currentIndex, section: 0)
                        let songObj = songsArray[indexPath.row]
                        if let canListen = songObj.can_listen, canListen {
                            for (i, song) in songsArray.enumerated() {
                                if i == currentIndex && (song.can_listen ?? false) {
                                    if popupContentController?.musicObject?.audio_id == song.audio_id {
                                        if AppInstance.instance.AlreadyPlayed {
                                            if let cell = tableView.cellForRow(at: indexPath) as? SongsTableCells {
                                                changeButtonImage(cell.btnPlayPause, play: false)
                                            }
                                        } else {
                                            if let cell = tableView.cellForRow(at: indexPath) as? SongsTableCells {
                                                changeButtonImage(cell.btnPlayPause, play: true)
                                            }
                                        }
                                    }else {
                                        if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                                            changeButtonImage(cell.btnPlayPause, play: true)
                                        }
                                    }
                                } else {
                                    if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells {
                                        changeButtonImage(cell.btnPlayPause, play: true)
                                    }
                                }
                            }
                        } else {
                            // let warningPopupVC = R.storyboard.popups.purchaseRequiredPopupVC()
                            // warningPopupVC?.delegate = self
                            // warningPopupVC?.object = songObj
                            // self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension ShowPlaylistDetailsVC: BottomSheetDelegate {
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ShowPlaylistDetailsVC: WarningPopupVCDelegate {
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            appDelegate.window?.rootViewController = newVC
            return
        }
        
        if sender.tag == 10001 {
            guard let newVC = R.storyboard.upgrade.upgradeProVC() else { return }
            self.navigationController?.pushViewController(newVC, animated: true)
            return
        }
    }
}

func getSavedLocalSongsList() -> [Song] {
    var videoData:[Song] = []
    let allData =  UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song)
    log.verbose("all data = \(allData)")
    for data in allData {
        do {
            let videoObject = try PropertyListDecoder().decode(Song.self ,from: data)
            log.verbose("videoObject = \(videoObject.id ?? 0)")
            videoData.append(videoObject)
        }catch {
            print(error.localizedDescription)
        }
    }
    return videoData
}

func getLocalVideoAdded(url: String) -> Bool {
    let videoURL = URL(string: url)?.lastPathComponent ?? ""
    print("VideoURL:------------", videoURL)
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let urlSTR = documentsURL.appendingPathComponent(videoURL).path
    return FileManager.default.fileExists(atPath: urlSTR)
}
