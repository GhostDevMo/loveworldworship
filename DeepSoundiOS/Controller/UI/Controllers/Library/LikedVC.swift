//
//  LikedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import EmptyDataSet_Swift
import EzPopup

class LikedVC: BaseVC {
    //MARK: - Properties -
    @IBOutlet weak var tableView: UITableView!
    
    var likedArray = [Song]()
    private var refreshControl = UIRefreshControl()
    var isLoading = false
    var songsFilterType:FilterData = .ascending
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchLiked()
        self.setuMusicPlayerNotification()
    }
    
    //MARK: - Helper Functions -
    private func setupUI() {
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.tableView.addPullToRefresh {
            self.likedArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchLiked()
        }
    }
    
    @objc func didTapFilterData(_ sender: UIButton) {
        self.view.endEditing(true)
        let filterVC = FilterPopUPController(dele: self)
        filterVC.filter = self.songsFilterType
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.view.frame.width - 190, y: 190)), popupWidth: 190, popupHeight: 150)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    private func fetchLiked() {
        if Connectivity.isConnectedToNetwork() {
            self.likedArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                LikeManager.instance.getLiked(UserId: userId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.likedArray = success?.data?.data ?? []
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
}

//MARK: - TableView Delegate and DataSource -
extension LikedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            return self.likedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as? SongsTableCells
            cell?.startSkelting()
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as? SongsTableCells
            cell?.stopSkelting()
            cell?.selectionStyle = .none
            let object = self.likedArray[indexPath.row]
            cell?.delegate = self
            cell?.indexPath = indexPath
            cell?.bind(object, index: indexPath.row)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if likedArray.count == 0 {
            return nil
        }
        let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(self.likedArray.count ) Songs"
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(_:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if likedArray.count == 0 {
            return 0
        }
        return UITableView.automaticDimension
    }
}

//MARK: - Songs TableViewCell Delegate Methods -
extension LikedVC: SongsTableCellsDelegate {
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.likedArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.likedArray
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
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.likedArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
}

//MARK: - Music Player Notification Handling Functions -
extension LikedVC {
    func setuMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.likedArray
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
            let songsArray: [Song] = self.likedArray
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
                let songsArray: [Song] = self.likedArray
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

//MARK: - BottomSheet Delegate Methods -
extension LikedVC:BottomSheetDelegate{
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

//MARK: - Filter Data Delegate Methods -
extension LikedVC: FilterTable {
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        self.songsFilterType = order!
        switch order {
        case .ascending:
            likedArray = likedArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            likedArray = likedArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            likedArray = likedArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0})
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}

extension LikedVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
}

// MARK: - EmptyView Delegate Methods -
extension LikedVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Liked songs", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have not any liked song yet! ", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}
