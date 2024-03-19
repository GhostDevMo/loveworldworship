
//
//  RecentlyPlayedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class RecentlyPlayedVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    
    var recentlySongOffSet = "0"
    var recentlySongLastCount = 0
    var isLoading = true
    private var recentlyPlayedArray = [Song]()
//    var songsArray:[Song] = []
    var isOtherVC = false
    var titleSTR: String?
    var user_Id: Int?
    var songCount: Int = 0
    var songLastID: Int = 0
    var songLastView: Int = 0
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        if isOtherVC {
            self.lblHeader.text = titleSTR
            if self.titleSTR == "Top Songs" {
                self.fetchUserTopSongs()
            }else {
                self.fetchUserLatestSongs()
            }
        }else {
            self.fetchRecentlyPlayed()
        }
        self.setupMusicPlayerNotification()
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        self.tableView.tableFooterView = activityIndicator
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.addPullToRefresh {
            if self.isOtherVC {
                self.songCount = 0
                self.songLastID = 0
                self.songLastView = 0
                self.isLoading = true
                self.recentlyPlayedArray.removeAll()
                self.tableView.reloadData()
                if self.titleSTR == "Top Songs" {
                    self.fetchUserTopSongs()
                }else {
                    self.fetchUserLatestSongs()
                }
            }else {
                self.recentlySongOffSet = "0"
                self.recentlyPlayedArray.removeAll()
                self.isLoading = true
                self.tableView.reloadData()
                self.fetchRecentlyPlayed()
            }
        }
    }
  
    /*private func fetchRecentlyPlayed() {
        if Connectivity.isConnectedToNetwork() {
            Async.background{
                RecentlyPlayedManager.instance.getRecentlyPlayed(Limit: 20, Offset: "0") { (success, sessionError, error) in
                    if success != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.recentlyPlayedArray = success?.data?.data ?? []
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
                }
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }*/
    
    private func fetchRecentlyPlayed() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                RecentlyPlayedManager.instance.getRecentlyPlayed(Limit: 20, Offset: self.recentlySongOffSet) { (success, sessionError, error) in
                        self.tableView.stopPullToRefresh()
                        if success != nil{
                            Async.main {
                                self.dismissProgressDialog {
                                    log.debug("userList = \(success?.status ?? 0)")
                                    let listArray = success?.data?.data ?? []
                                    if self.recentlySongOffSet == "0" {
                                        self.recentlyPlayedArray = listArray
                                        self.isLoading = false
                                    }else{
                                        self.recentlyPlayedArray.append(contentsOf: listArray)
                                    }
                                    self.recentlySongLastCount = listArray.count
                                    switch listArray.last?.count_views {
                                    case .integer(let value):
                                        self.recentlySongOffSet = "\(value)"
                                    case .string(let value):
                                        self.recentlySongOffSet = value
                                    case .none:
                                        break
                                    }
                                    self.tableView.reloadData()
                                    self.tableView.tableFooterView?.isHidden=true
                                }
                            }
                        }else if sessionError != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    self.view.makeToast(sessionError?.error ?? "")
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                }
                            }
                        }else {
                            Async.main {
                                self.dismissProgressDialog {
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                }
                            }
                        }
                    }
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func fetchUserTopSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background { [self] in
                SongsManager.instance.getUserTopSongsAPI(userID: user_Id ?? 0, limit: 10, ids: self.songLastID, last_view: self.songLastView) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data ?? []
                                if self.songLastID == 0 {
                                    self.recentlyPlayedArray = listArray
                                    self.isLoading = false
                                }else{
                                    self.recentlyPlayedArray.append(contentsOf: listArray)
                                }
                                self.songCount = listArray.count
                                self.songLastID = listArray.last?.id ?? 0
                                switch listArray.last?.count_views {
                                case .integer(let value):
                                    self.songLastView = value
                                case .string(let value):
                                    self.songLastView = Int(value) ?? 0
                                case .none:
                                    break
                                }
                                self.tableView.reloadData()
                                self.tableView.tableFooterView?.isHidden=true
                            }
                        }
                    }else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    }else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func fetchUserLatestSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background { [self] in
                SongsManager.instance.getUserLatestSongsAPI(userID: user_Id ?? 0, limit: 10, offSet: self.songLastID) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data ?? []
                                if self.songLastID == 0 {
                                    self.recentlyPlayedArray = listArray
                                    self.isLoading = false
                                }else{
                                    self.recentlyPlayedArray.append(contentsOf: listArray)
                                }
                                self.songCount = listArray.count
                                self.songLastID = listArray.last?.id ?? 0
                                self.tableView.reloadData()
                                self.tableView.tableFooterView?.isHidden=true
                            }
                        }
                    }else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    }else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

extension RecentlyPlayedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            if self.recentlyPlayedArray.count == 0 {
                return 1
            }else{
                return self.recentlyPlayedArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.startSkelting()
            return cell
        }else {
            if self.recentlyPlayedArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.selectionStyle = .none
                cell.stopSkelting()
                let object = self.recentlyPlayedArray[indexPath.row]
                cell.indexPath = indexPath
                cell.delegate = self
                cell.bind(object, index: indexPath.row)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return UITableView.automaticDimension
        }else {
            if self.recentlyPlayedArray.count == 0 {
                return 500.0
            }else{
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.recentlyPlayedArray.count - 1) {
            if isOtherVC {
                if !(self.songCount < 10) {
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView?.isHidden = false
                        self.activityIndicator.startAnimating()
                        if self.titleSTR == "Top Songs" {
                            self.fetchUserTopSongs()
                        }else {
                            self.fetchUserLatestSongs()
                        }
                    }
                }
            }else {
                if !(self.recentlySongLastCount < 20) {
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView?.isHidden = false
                        self.activityIndicator.startAnimating()
                        self.fetchRecentlyPlayed()
                    }
                }
            }
        }
    }
}

extension RecentlyPlayedVC: SongsTableCellsDelegate {
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.recentlyPlayedArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        var songsArray: [Song] = self.recentlyPlayedArray
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
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.recentlyPlayedArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
}

//MARK: - Music Player Notification Handling Functions -
extension RecentlyPlayedVC {
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.recentlyPlayedArray
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
            let songsArray: [Song] = self.recentlyPlayedArray
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
                let songsArray: [Song] = self.recentlyPlayedArray
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

extension RecentlyPlayedVC: BottomSheetDelegate {
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        self.view.endEditing(true)
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
