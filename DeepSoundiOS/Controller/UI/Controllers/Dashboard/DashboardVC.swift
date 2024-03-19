//
//  DashboardVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import MediaPlayer
import EzPopup
import EmptyDataSet_Swift
import Toast_Swift

class DashboardVC: BaseVC {
    
    // MARK: - IBOutelets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var latestSongsArray: [Song] = []
    var recentlyPlayedArray: [Song] = []
    var mostPopularArray: [Song] = []
    var slideShowArray: Randoms?
    var genresArray = [GenresModel.Datum]()
    var artistArray = [Publisher]()
    var topSongsArray = [Song]()
    var topAlbumsArray = [Album]()
    var storysArray = [Story]()
    var type: DashboardActionType = .suggested
    var isloading = true
    var selectedCategoryIndex = 0
    let homeCategoryTitle = [
        "Suggestion",
        "Top Songs",
        "Latest Songs",
        "Recently Played",
        "Top Albums",
        "Popular",
        "Artists"
    ]
    var topSongsFilterType: FilterData = .ascending
    var latestSongsFilterType: FilterData = .ascending
    var recentlyPlayedFilterType: FilterData = .ascending
    var topAlbumsFilterType: FilterData = .ascending
    var popularFilterType: FilterData = .ascending
    var artistsFilterType: FilterData = .ascending
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var latestSongLastCount = 0
    var topSongOffSet = "0"
    var latestSongOffSet = "0"
    var recentlySongOffSet = "0"
    var recentlySongLastCount = 0
    var artistOffSet = 0
    var artistLastCount = 0
    var topSongLastCount = 0
    var topAlbumLastIds = 0
    var topAlbumLastViews = "0"
    var topAlbumLastCount = 0
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchDiscover()
        self.setuMusicPlayerNotification()
    }
    
    // MARK: - Selectors
    
    @IBAction func notificationPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let vc = R.storyboard.notfication.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.search.searchVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let panVC: PanModalPresentable.LayoutType = AddMenuBottomSheetController(delegate: self)
        presentPanModal(panVC)
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().isPrefetchingEnabled = false
        }
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.sectionHeaderTableItem), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashboardSectionTwoTableItem), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionTwoTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashboardSectionThreeTableItem), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashBoardSectionSixTableItem), forCellReuseIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashboardTopAlbums_TableViewCell), forCellReuseIdentifier: R.reuseIdentifier.dashboardTopAlbums_TableViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.foldersTableCell), forCellReuseIdentifier: R.reuseIdentifier.foldersTableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        self.tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.artistTableCell), forCellReuseIdentifier: R.reuseIdentifier.artistTableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.profileAlbumsTableCell), forCellReuseIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.noLoginTableItem), forCellReuseIdentifier: R.reuseIdentifier.noLoginTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.createStoryTableCell), forCellReuseIdentifier: R.reuseIdentifier.createStoryTableCell.identifier)
        
        self.tableView.sectionHeaderHeight = 45.0
        self.tableView.tableFooterView = activityIndicator
        self.tableView.tableFooterView?.isHidden = true
        self.collectionView.register(UINib(resource: R.nib.categoryCell), forCellWithReuseIdentifier: R.reuseIdentifier.categoryCell.identifier)
        // tableView.emptyDataSetSource = self
        // tableView.emptyDataSetDelegate = self
        self.tableView.addPullToRefresh {
            self.isloading = true
            self.tableView.reloadData()
            switch self.type {
            case .suggested:
                self.refresh()
            case .topsongs:
                if AppInstance.instance.isLoginUser {
                    self.topSongsArray.removeAll()
                    self.topSongOffSet = "0"
                    self.fetchTopSongs()
                } else {
                    self.tableView.stopPullToRefresh()
                    self.isloading = false
                    self.tableView.reloadData()
                }
            case .latestsongs:
                if AppInstance.instance.isLoginUser {
                    self.latestSongsArray.removeAll()
                    self.latestSongOffSet = "0"
                    self.fetchLatestsSongs()
                } else {
                    self.tableView.stopPullToRefresh()
                    self.isloading = false
                    self.tableView.reloadData()
                }
            case .recentlyplayed:
                if AppInstance.instance.isLoginUser {
                    self.recentlyPlayedArray.removeAll()
                    self.recentlySongOffSet = "0"
                    self.fetchRecentlyPlayedSongs()
                } else {
                    self.tableView.stopPullToRefresh()
                    self.isloading = false
                    self.tableView.reloadData()
                }
            case .topalbums:
                self.topAlbumsArray.removeAll()
                self.topAlbumLastIds = 0
                self.topAlbumLastViews = "0"
                self.fetchTopAlbums()
            case .popular:
                self.tableView.stopPullToRefresh()
                self.isloading = false
                self.tableView.reloadData()
                break
            case .artists:
                self.artistArray.removeAll()
                self.artistOffSet = 0
                self.fetchArtist()
            }
        }
    }
    
    @objc func didTappSeeAll(_ sender: UIButton) {
        self.view.endEditing(true)
        self.type = DashboardActionType(rawValue: sender.tag) ?? .suggested
        self.selectedCategoryIndex = sender.tag
        self.collectionView.selectItem(at: IndexPath(item: sender.tag, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        self.collectionView.reloadData()
        if AppInstance.instance.isLoginUser {
            if sender.tag != 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToTop()
                }
            }
        }
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: true)
    }
    
    func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
    @objc func refresh() {
        self.latestSongsArray.removeAll()
        self.slideShowArray?.recommended?.removeAll()
        self.slideShowArray = nil
        self.topSongsArray.removeAll()
        self.topAlbumsArray.removeAll()
        self.recentlyPlayedArray.removeAll()
        self.mostPopularArray.removeAll()
        self.recentlyPlayedArray.removeAll()
        self.artistArray.removeAll()
        self.genresArray.removeAll()
        self.tableView.reloadData()
        self.topSongOffSet = "0"
        self.latestSongOffSet = "0"
        self.recentlySongOffSet = "0"
        self.artistOffSet = 0
        self.topAlbumLastIds = 0
        self.topAlbumLastViews = "0"
        self.fetchDiscover()
    }
    
    @objc func didTapFilterData(_ sender: UIButton) {
        self.view.endEditing(true)
        let filterVC = FilterPopUPController(dele: self)
        switch self.type {
        case .suggested:
            break
        case .topsongs:
            filterVC.filter = self.topSongsFilterType
        case .latestsongs:
            filterVC.filter = self.latestSongsFilterType
        case .recentlyplayed:
            filterVC.filter = self.recentlyPlayedFilterType
        case .topalbums:
            filterVC.filter = self.topAlbumsFilterType
        case .popular:
            filterVC.filter = self.popularFilterType
        case .artists:
            filterVC.filter = self.artistsFilterType
        }
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.view.frame.width - 190, y: 190)), popupWidth: 190, popupHeight: 150)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
}

// MARK: - Extensions

// MARK: Music Player Notification Handling Functions
extension DashboardVC {
    
    func setuMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if type != .suggested {
                var songsArray: [Song] = []
                if type == .topsongs {
                    songsArray = topSongsArray
                } else if type == .latestsongs {
                    songsArray = latestSongsArray
                } else if type == .recentlyplayed {
                    songsArray = recentlyPlayedArray
                } else if type == .popular {
                    songsArray = mostPopularArray
                }
                if let statusBool = notification?.object as? Bool {
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
            } else {
                // self.tableView.reloadData()
            }
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            var songsArray: [Song] = []
            if type == .topsongs {
                songsArray = topSongsArray
            } else if type == .latestsongs {
                songsArray = latestSongsArray
            } else if type == .recentlyplayed {
                songsArray = recentlyPlayedArray
            } else if type == .popular {
                songsArray = mostPopularArray
            }
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
                if type != .suggested {
                    var songsArray: [Song] = []
                    if type == .topsongs {
                        songsArray = topSongsArray
                    } else if type == .latestsongs {
                        songsArray = latestSongsArray
                    } else if type == .recentlyplayed {
                        songsArray = recentlyPlayedArray
                    } else if type == .popular {
                        songsArray = mostPopularArray
                    }
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

// MARK: NoLogin Delegate Methods
extension DashboardVC: NoLoginTableDelegate {
    
    func buttonPressed(_ sender: UIButton) {
        if !isloading {
            self.showLoginAlert(delegate: self)
        }
    }
    
}

// MARK: AddMenu BottomSheet Delegate Methods
extension DashboardVC: AddMenuBottomSheetDelegate {
    
    func uploadSingleSongPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func importSongPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.track.importURLVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func createAlbumPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.album.uploadAlbumVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func createPlayListPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let vc = R.storyboard.playlist.createPlaylistVC() else { return }
        let panVC: PanModalPresentable.LayoutType = vc
        presentPanModal(panVC)
    }
    
    func createStationPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.stations.stationsFullVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func createAdvertisePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.dashboard.createAdVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: MPMedia Picker Delegate Methods
extension DashboardVC: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background {
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                if exportSession!.status == AVAssetExportSession.Status.completed {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                    Async.main {
                        self.uploadTrack(TrackData: data)
                    }
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    func uploadTrack(TrackData: Data) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.file_path ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                vc?.uploadTrackModel = success
                                self.navigationController?.pushViewController(vc!, animated: true)
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
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: PopView Delegate Methods
extension DashboardVC: PopupViewControllerDelegate {
    
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}

// MARK: BottomSheet Delegate Methods
extension DashboardVC: BottomSheetDelegate {
    
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
        /*let vc = R.storyboard.dashboard.showProfile2VC()
        vc?.userID = userID
        self.navigationController?.pushViewController(vc!, animated: true)*/
    }
    
    func goToAlbum() {
        self.type =  .topalbums
        self.selectedCategoryIndex = 4
        collectionView.selectItem(at: IndexPath(item: 4, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        collectionView.reloadData()
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: true)
    }
    
}

// MARK: Filter Delegate Methods
extension DashboardVC: FilterTable {
    
    func filterData(order: Int) {
        if type == .recentlyplayed {
            let order = FilterData(rawValue: order)
            self.recentlyPlayedFilterType = order!
            switch order {
            case .ascending:
                recentlyPlayedArray = recentlyPlayedArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                recentlyPlayedArray = recentlyPlayedArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                recentlyPlayedArray = recentlyPlayedArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0 })
                tableView.reloadData()
            case .none:
                break
            }
        } else if type == .latestsongs {
            let order = FilterData(rawValue: order)
            self.latestSongsFilterType = order!
            switch order {
            case .ascending:
                latestSongsArray = latestSongsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                latestSongsArray = latestSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                latestSongsArray = latestSongsArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0 })
                tableView.reloadData()
            case .none:
                break
            }
        } else if type == .popular {
            let order = FilterData(rawValue: order)
            self.popularFilterType = order!
            switch order {
            case .ascending:
                mostPopularArray = mostPopularArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                mostPopularArray = mostPopularArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                mostPopularArray = mostPopularArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0 })
                tableView.reloadData()
            case .none:
                break
            }
        } else if type == .topalbums {
            let order = FilterData(rawValue: order)
            self.topAlbumsFilterType = order!
            switch order {
            case .ascending:
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0})
                tableView.reloadData()
            case .none:
                break
            }
        } else if type == .artists {
            let order = FilterData(rawValue: order)
            self.artistsFilterType = order!
            switch order {
            case .ascending:
                artistArray = artistArray.sorted(by: { $0.name ?? "" < $1.name ?? "" })
                tableView.reloadData()
            case .descending:
                artistArray = artistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
                tableView.reloadData()
            case .dateAdded:
                artistArray = artistArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0})
                tableView.reloadData()
            case .none:
                break
            }
        } else if type == .topsongs {
            let order = FilterData(rawValue: order)
            self.topSongsFilterType = order!
            switch order {
            case .ascending:
                topSongsArray = topSongsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                topSongsArray = topSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                topSongsArray = topSongsArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0})
                tableView.reloadData()
            case .none:
                break
            }
        }
    }
}

// MARK: Dashboard TopAlbums TableView Delegate Methods
extension DashboardVC: DashboardTopAlbumsTableViewCellDelegate {
    
    func selectAlbum(albumArray: [Album], indexPath: IndexPath, cell: DashboardTopAlbums_TableViewCell) {
        let vc = R.storyboard.dashboard.showAlbumVC()
        vc?.albumObject = albumArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: Dashboard Section TableView Delegate Methods
extension DashboardVC: DashaboardSectionTableItemDelegate {
    
    func selectArtist(publisherArray: [Publisher], indexPath: IndexPath, cell: DashBoardSectionSixTableItem) {
        self.view.endEditing(true)
        let vc = R.storyboard.discover.artistDetailsVC()
        vc?.artistObject = publisherArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func selectSong(songArray: [Song], indexPath: IndexPath, cell: DashboardSectionThreeTableItem) {
        self.view.endEditing(true)
        if songArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id  {
            AppInstance.instance.AlreadyPlayed = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        }
        let object = songArray[indexPath.row]
        AppInstance.instance.popupPlayPauseSong = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
        }
        addToRecentlyWatched(trackId: object.id ?? 0)
        self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true) {
            popupContentController?.musicObject = object
            popupContentController?.musicArray = songArray
            popupContentController?.currentAudioIndex = indexPath.row
            popupContentController?.delegate = self
            popupContentController?.setup()
        }
    }
    
    func selectGenres(object: [GenresModel.Datum], indexPath: IndexPath) {
        let vc = R.storyboard.discover.genresSongsVC()
        vc?.genresId = object[indexPath.row].id ?? 0
        vc?.titleString = object[indexPath.row].cateogryName ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: Warning Popup Delegate Methods
extension DashboardVC: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton,_ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        } else if sender.tag == 1003 {
            let newVC = R.storyboard.settings.settingWalletVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        } else if sender.tag == 1002 {
            
        }
    }
    
}

// MARK: Song TableView Delegate Methods
extension DashboardVC: SongsTableCellsDelegate {
    
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        var songsArray: [Song] = []
        if type == .topsongs {
            songsArray = topSongsArray
        } else if type == .latestsongs {
            songsArray = latestSongsArray
        } else if type == .recentlyplayed {
            songsArray = recentlyPlayedArray
        } else if type == .popular {
            songsArray = mostPopularArray
        }
        if songsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        var object: Song? = nil
        if type == .popular {
            object = mostPopularArray[indexPath.row]
        } else if type == .topsongs {
            object =  topSongsArray[indexPath.row]
        } else if type == .recentlyplayed {
            object =  recentlyPlayedArray[indexPath.row]
        } else if type == .latestsongs {
            object = latestSongsArray[indexPath.row]
        } else {
            return
        }
        if let object = object {
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: object, delegate: self)
            presentPanModal(panVC)
        }
    }
    
}

// MARK: Purchase Required Delegate Methods
extension DashboardVC: PurchaseRequiredPopupDelegate {
    
    func purchaseButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if AppInstance.instance.isLoginUser {
            if let object = songObject {
                let sell_music = object.price ?? 0.0
                print("Amount >>>>>", sell_music)
                AppInstance.instance.fetchUserProfile(isNew: true) { success in
                    if success {
                        let walletBalance = AppInstance.instance.userProfile?.data?.wallet?.doubleValue() ?? 0.0
                        if sell_music < walletBalance {
                            self.purchaseSongWallet(trackId: songObject?.audio_id ?? "")
                        } else {
                            let warningPopupVC = R.storyboard.popups.warningPopupVC()
                            warningPopupVC?.delegate = self
                            warningPopupVC?.okButton.tag = 1003
                            warningPopupVC?.titleText  = "Wallet"
                            warningPopupVC?.messageText = "Sorry, You do not have enough money please top up your wallet"
                            warningPopupVC?.okText = "ADD WALLET"
                            self.present(warningPopupVC!, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            self.showLoginAlert(delegate: self)
        }
    }
    
}

func changeButtonImage(_ button: UIButton, play: Bool) {
    UIView.transition(with: button, duration: 0.4,
                      options: .transitionCrossDissolve, animations: {
        button.setImage(nil, for: .normal)
        button.setImage(UIImage(named: play ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
    }, completion: nil)
}

// MARK: EmptyView Delegate Methods
extension DashboardVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black
        let message = "Seems a little quite over here"
        return message.stringToAttributed
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
    
}
