//
//  ShowAlbumVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 23/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds
import EzPopup
import Braintree
import PassKit
import Toast_Swift

class ShowAlbumVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var shuffleBtn:UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var albumObject: Album?
    private var albumSongsArray = [Song]()
    // private let popupContentController = R.storyboard.player.musicPlayerVC()
    var isPurchase:Bool = false
    var userID:Int = 0
    var albumID:Int = 0
    var AlbumURL:String = ""
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    var price: MultipleValues?
    var albumIDSting:String = ""
    var shuffled:Bool = false
    var isLoading = true
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var paymentRequest = PKPaymentRequest()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        log.verbose("Search Price = \(self.albumObject?.album_id ?? "")")
        self.fetchAlbumtSongs()
        self.setupMusicPlayerNotification()
        if ControlSettings.shouldShowAddMobBanner {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: ControlSettings.interestialAddUnitId,
                                   request: request) { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            }
        }
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
    
    // MARK: - Selectors
    
    @IBAction func shuffleSongList(_ sender: UIButton) {
        self.shuffled = true
        self.playSong(sender)
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        self.shuffled = false
        self.playSong(sender)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if AppInstance.instance.getUserSession() {
            let vc = R.storyboard.popups.purchaseRequiredPopupVC()
            vc?.modalPresentationStyle = .custom
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
        }else{
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func morePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let albumObject = self.albumObject {
            let panVC: PanModalPresentable.LayoutType = ShareBottomSheetController(album: albumObject)
            presentPanModal(panVC)
        }
    }
    
    @objc func playSong(_ sender: UIButton) {
        self.view.endEditing(true)
        var indexPath = IndexPath(row: sender.tag, section: 0)
        var randomInt = 0
        if self.albumSongsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.albumSongsArray
        var object = songsArray[indexPath.row]
        if shuffled {
            albumSongsArray.shuffle()
            randomInt = Int.random(in: 0..<albumSongsArray.count)
            object = albumSongsArray[randomInt]
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
    
    // MARK: - Helper functions
    
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: ControlSettings.interestialAddUnitId, request: GADRequest(), completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        })
        return  self.interstitial
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupUI() {
        let object = albumObject
        self.albumNameLabel.text = object?.title ?? ""
        let coverURL = URL.init(string: object?.thumbnail ?? "")
        if object?.is_purchased == 1 {
            self.btnStackView.isHidden = false
            self.buyBtn.isHidden = true
            self.isPurchase = false
        } else {
            if (object?.price?.intValue == 0 || object?.price?.doubleValue == 0) {
                self.btnStackView.isHidden = false
                self.buyBtn.isHidden = true
                self.isPurchase = false
            } else {
                self.btnStackView.isHidden = true
                self.buyBtn.isHidden = false
                self.isPurchase = true
            }
        }
        thumbnailImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
        self.userID = object?.publisher?.id ?? 0
        self.albumID = object?.id ?? 0
        self.AlbumURL = object?.url ?? ""
        self.price = object?.price
        self.songsCountLabel.text = "\(object?.count_songs ?? 0) Songs - \(object?.purchases ?? 0) Purchases"
        self.albumIDSting = object?.album_id ?? ""
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource: R.nib.purchaseButtonTableItem), forCellReuseIdentifier: R.reuseIdentifier.purchaseButtonTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
    }
    
    private func fetchAlbumtSongs() {
        if Connectivity.isConnectedToNetwork() {
            self.albumSongsArray.removeAll()
            // self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let albumId = self.albumID
            Async.background {
                AlbumManager.instance.getAlbumSongs(albumId: albumId, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog { [self] in
                                log.debug("userList = \(success?.songs ?? [])")
                                self.albumSongsArray = success?.songs ?? []
                                if self.albumSongsArray.count == 0 {
                                    self.playBtn.isHidden = true
                                    self.shuffleBtn.isHidden = true
                                    self.buyBtn.isHidden = true
                                } else {
                                    if self.isPurchase {
                                        self.playBtn.isHidden = true
                                        self.shuffleBtn.isHidden = true
                                        self.buyBtn.isHidden = false
                                    } else {
                                        self.playBtn.isHidden = false
                                        self.shuffleBtn.isHidden = false
                                        self.buyBtn.isHidden = true
                                    }
                                }
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
    
    private func deleteTrack(albumID: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                AlbumManager.instance.deleteAlbum(albumId: albumID, AccessToken: accessToken, type: "single") { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            }
                        }
                    }
                }
            }
        } else {
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
            }
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
    
}

// MARK: - Extensions

// MARK: WarningPopupVCDelegate
extension ShowAlbumVC: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        }
    }
    
}

// MARK: Api Call
extension ShowAlbumVC {
    /*private func purchaseAlbumWallet() {
     if Connectivity.isConnectedToNetwork() {
     let accessToken = AppInstance.instance.accessToken ?? ""
     let userid = AppInstance.instance.userId ?? 0
     Async.background {
     UpgradeMemberShipManager.instance.purchaseAlbum(AccessToken: accessToken, type: "buy_album", AlbumID: "\(self.albumID)") { success, sessionError, error in
     if success != nil{
     Async.main {
     self.dismissProgressDialog {
     
     }
     }
     }else if sessionError != nil{
     Async.main {
     self.dismissProgressDialog {
     self.view.makeToast(sessionError ?? "")
     log.error("sessionError = \(sessionError ?? "")")
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
     }*/
    
    private func purchaseAlbum(albumID: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                AlbumManager.instance.PurchaseAlbum(AccessToken: accessToken, albumId: albumID, userID: userId, via: "PayPal") { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString("Your Puchased Album", comment: "Your Puchased Album"))
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            }
        } else {
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
        }
    }
    
}

// MARK: TableView Setup
extension ShowAlbumVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            if self.albumObject?.is_purchased == 1 {
                if self.albumSongsArray.count == 0 {
                    return 1
                }else{
                    return self.albumSongsArray.count
                }
            } else {
                if self.price?.intValue == 0 || self.price?.doubleValue == 0 {
                    if self.albumSongsArray.count == 0 {
                        return 1
                    }else{
                        return self.albumSongsArray.count
                    }
                } else {
                    return 1
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.startSkelting()
            return cell
        } else {
            if self.albumSongsArray.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
                cell.selectedBackgroundView()
                return cell
            } else {
                if self.albumObject?.is_purchased == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                    cell.selectedBackgroundView()
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind( self.albumSongsArray[indexPath.row])
                    cell.indexPath = indexPath
                    cell.delegate = self
                    return cell
                } else {
                    if self.price?.intValue == 0 || self.price?.doubleValue == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                        cell.selectedBackgroundView()
                        cell.stopSkelting()
                        cell.selectionStyle = .none
                        cell.bind( self.albumSongsArray[indexPath.row])
                        cell.indexPath = indexPath
                        cell.delegate = self
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseButtonTableItem.identifier) as! PurchaseButtonTableItem
                        cell.selectedBackgroundView()
                        return cell
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return UITableView.automaticDimension
        } else {
            if albumSongsArray.isEmpty {
                return 300.0
            } else {
                if self.albumObject?.is_purchased == 1 {
                    return UITableView.automaticDimension
                } else {
                    if self.price?.intValue == 0 || self.price?.doubleValue == 0 {
                        return UITableView.automaticDimension
                    } else {
                        return 400.0
                    }
                }
            }
        }
    }
    
}

// MARK: SongsTableCellsDelegate
extension ShowAlbumVC: SongsTableCellsDelegate {
    
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.albumSongsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
            AppInstance.instance.AlreadyPlayed = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        } else {
            if AppInstance.instance.AlreadyPlayed {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            }else {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            }
            return
        }
        let songsArray: [Song] = self.albumSongsArray
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
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.albumSongsArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
    
}

// MARK: Music Player Notification Handling Functions
extension ShowAlbumVC {
    
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.albumSongsArray
                if songsArray.count != 0 {
                    if let currentIndex = songsArray.firstIndex(where: { $0.audio_id == popupContentController?.musicObject?.audio_id }) {
                        for (i, song) in songsArray.enumerated() {
                            if i == currentIndex && (song.can_listen ?? false) {
                                if popupContentController?.musicObject?.audio_id == song.audio_id {
                                    if let cell = tableView.cellForRow(at: IndexPath(item: currentIndex, section: 0)) as? SongsTableCells {
                                        if !statusBool {
                                            cell.btnPlayPause.setImage(R.image.icPauseBtn(), for: .normal)
                                        } else {
                                            cell.btnPlayPause.setImage(R.image.ic_playPlayer(), for: .normal)
                                        }
                                    }
                                } else {
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
                    }
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            let songsArray: [Song] = self.albumSongsArray
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
                let songsArray: [Song] = self.albumSongsArray
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

// MARK: BottomSheetDelegate
extension ShowAlbumVC: BottomSheetDelegate {
    
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

// MARK: PurchaseRequiredPopupDelegate
extension ShowAlbumVC: PurchaseRequiredPopupDelegate {
    
    func purchaseButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        print("pressssss")
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension ShowAlbumVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
