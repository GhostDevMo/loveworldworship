//
//  FavouriteVC.swift
//  DeepSoundiOS
//
//  Created by Moghees on 15/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds
import EzPopup
import EmptyDataSet_Swift
import Toast_Swift

class FavouriteTBVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var shuffle: UIButton!
    
    // MARK: - Properties
    
    private var selectedFilterType: FilterData = .ascending
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    private var favoriteArray = [Song]()
    var isLoading = true {
        didSet {
            if isLoading {
                self.tableView.reloadData()
            }
        }
    }
    var shuffled:Bool = false
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMusicPlayerNotification()
        if ControlSettings.shouldShowAddMobBanner {
            // bannerView = GADBannerView(adSize: GADAdSize())
            // addBannerViewToView(bannerView)
            // bannerView.adUnitID = ControlSettings.addUnitId
            // bannerView.rootViewController = self
            // bannerView.load(GADRequest())
            
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: ControlSettings.interestialAddUnitId, request: request, completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            })
        }
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isLoading = true
        self.fetchfavorite()
    }
    
    // MARK: - Selectors
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.search.searchVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    @objc func didTapFilterData(sender: UIButton) {
        self.view.endEditing(true)
        let filterVC = FilterPopUPController(dele: self)
        filterVC.filter = self.selectedFilterType
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 150)), popupWidth: 200, popupHeight: 150)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        present(popupVC, animated: true, completion: nil)
    }
    
    @objc func playSong(_ sender: UIButton) {
        self.view.endEditing(true)
        var indexPath = IndexPath(row: sender.tag, section: 0)
        var randomInt = 0
        if self.favoriteArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.favoriteArray
        var object = songsArray[indexPath.row]
        if shuffled {
            favoriteArray.shuffle()
            randomInt = Int.random(in: 0..<favoriteArray.count)
            object = favoriteArray[randomInt]
            indexPath = IndexPath(row: randomInt, section: 0)
        } else {
            
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
    
    @IBAction func playSongList(_ sender: UIButton) {
        sender.tag = 0
        shuffled = false
        if favoriteArray.count != 0 {
            self.playSong(sender)
        } else {
            self.view.makeToast("Song is not available ")
        }
        
    }
    
    @IBAction func shuffleSongList(_ sender: UIButton) {
        self.shuffled = true
        if favoriteArray.count != 0 {
            self.playSong(sender)
        } else {
            self.view.makeToast("Song is not available ")
        }
    }
    
}

// MARK: - Extensions

// MARK: Helper Functions
extension FavouriteTBVC {
    
    private func setupUI() {
        playBtn.backgroundColor = .lightButtonColor
        shuffle.backgroundColor = .ButtonColor
        playBtn.setTitleColor(.ButtonColor, for: .normal)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        self.tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.addPullToRefresh {
            self.favoriteArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchfavorite()
        }
    }
    
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
    
}

// MARK: API Call
extension FavouriteTBVC {
    
    private func fetchfavorite() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                FavoriteManager.instance.getFavorite(UserId: userId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.favoriteArray = success?.data?.data ?? []
                                self.buttonView.isHidden = self.favoriteArray.count == 0
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension FavouriteTBVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.favoriteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.startSkelting()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.stopSkelting()
            cell.selectionStyle = .none
            let object = self.favoriteArray[indexPath.row]
            cell.bind(object, index: indexPath.row)
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // if self.favoriteArray.count != 0 {
        let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(favoriteArray.count) Favourites"
        headerView.btnArrangOrder.tag = section
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
        return headerView
        // }
        // return nil
    }
}

// MARK: SongsTableCellsDelegate
extension FavouriteTBVC: SongsTableCellsDelegate {
    
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.favoriteArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.favoriteArray
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
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: favoriteArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
    
}

// MARK: Music Player Notification Handling Functions
extension FavouriteTBVC {
    
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                    let songsArray: [Song] = self.favoriteArray
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
            let songsArray: [Song] = self.favoriteArray
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
                let songsArray: [Song] = self.favoriteArray
                if songsArray.count != 0 {
                    if let currentIndex = songsArray.firstIndex(where: { $0.audio_id == popupContentController?.musicObject?.audio_id }) {
                        if songsArray.count != 0 {
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
    
}

// MARK: FilterTable
extension FavouriteTBVC: FilterTable {
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        self.selectedFilterType = order ?? .ascending
        switch order {
        case .ascending:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
    
}

// MARK: BottomSheetDelegate
extension FavouriteTBVC: BottomSheetDelegate {
    
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

// MARK: EmptyDataSetSource, EmptyDataSetDelegate
extension FavouriteTBVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Songs", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24), .foregroundColor : UIColor.textColor])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You don't have any favorite songs", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
    
}
