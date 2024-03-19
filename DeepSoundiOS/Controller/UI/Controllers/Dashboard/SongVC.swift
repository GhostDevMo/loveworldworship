//
//  SongVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Async
import DeepSoundSDK
import SwiftEventBus
import EzPopup

class SongVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var songArray = [Song]()
    var parentVC: BaseVC?
    var isOtherUser = false
    var userID: Int?
    
    // MARK: - View Life Cycels
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchUserProfile()
        self.tableView.addPullToRefresh {
            self.songArray.removeAll()
            self.tableView.reloadData()
            self.fetchUserProfile()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        self.setupMusicPlayerNotification()
    }
    
    private func fetchUserProfile() {
        var userId = 0
        if isOtherUser {
            userId = self.userID ?? 0
        } else {
            userId = AppInstance.instance.userId ?? 0
        }
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, fetch: "top_songs", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.songArray = success?.data?.top_songs?.first ?? []
                            self.tableView.reloadData()
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
                            //self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
    
    @objc func didTapFilterData(sender: UIButton) {
        let filterVC = FilterPopUPController(dele: self)
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
extension SongVC {
    
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.songArray
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
            let songsArray: [Song] = self.songArray
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
                let songsArray: [Song] = self.songArray
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

// MARK: BottomSheetDelegate
extension SongVC: BottomSheetDelegate {
    
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.parentVC?.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: FilterTable
extension SongVC: FilterTable {
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            songArray = songArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            songArray = songArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            songArray = songArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
    
}

// MARK: PopupViewControllerDelegate
extension SongVC: PopupViewControllerDelegate {
    
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}

// MARK: TableView Setup
extension SongVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songArray.count == 0 {
            return 1
        }
        return songArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if songArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
            cell.titleLabel.text = "No Songs"
            cell.noDataLabel.text = "You don't have any Songs"
            return cell
        }
        if indexPath.row == 0 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblTotalSongs.text = "\(self.songArray.count) Songs"
            return headerView
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.selectionStyle = .none
            let object = self.songArray[indexPath.row-1]
            cell.bind(object)
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: SongsTableCellsDelegate
extension SongVC: SongsTableCellsDelegate {
    
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.songArray[indexPath.row - 1].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.songArray
        let object = songsArray[indexPath.row-1]
        if let canListen = object.can_listen, canListen {
            for (i, _) in songsArray.enumerated() {
                if i == (indexPath.row-1) {
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
        self.parentVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true) {
            popupContentController?.musicObject = object
            popupContentController?.musicArray = songsArray
            popupContentController?.currentAudioIndex = indexPath.row-1
            popupContentController?.delegate = self
            popupContentController?.setup()
        }
    }
    
    func moreButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.songArray[indexPath.row-1], delegate: self)
        presentPanModal(panVC)
    }
    
}
