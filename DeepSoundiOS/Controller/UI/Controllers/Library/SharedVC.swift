//
//  SharedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import Async
import EzPopup
import EmptyDataSet_Swift

class SharedVC: BaseVC {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var sharedSongsArray = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getSharedSongs()
        self.setupMusicPlayerNotification()
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
    }
    
    @objc func didTapFilterData(sender:UIButton) {
        let filterVC = FilterPopUPController(dele: self)        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.view.frame.width - 190, y: 190)), popupWidth: 190, popupHeight: 150)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    private func getSharedSongs() {
        var allData =  UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
        self.tableView.isHidden = false
        log.verbose("all data = \(allData)")
        for data in allData {
            if let musicObject = try? PropertyListDecoder().decode(Song.self ,from: data)  {
                log.verbose("musicObject = \(musicObject.id)")
                self.sharedSongsArray.append(musicObject)
            }else{
                log.verbose("Nil values cannot be append in Array!")
            }
        }
        self.tableView.reloadData()
    }
}

extension SharedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sharedSongsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as? SongsTableCells
        cell?.selectionStyle = .none
        let object = self.sharedSongsArray[indexPath.row]
        cell?.btnPlayPause.tag = indexPath.row
        cell?.delegate = self
        cell?.indexPath = indexPath
        cell?.bind(object)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sharedSongsArray.count != 0 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as! AssigingOrderHeaderTableCell
            headerView.lblTotalSongs.text = "\(sharedSongsArray.count ) Songs"
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SharedVC: SongsTableCellsDelegate {
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        self.view.endEditing(true)
        if self.sharedSongsArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id {
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
        let songsArray: [Song] = self.sharedSongsArray
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
        let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: self.sharedSongsArray[indexPath.row], delegate: self)
        presentPanModal(panVC)
    }
}

//MARK: - Music Player Notification Handling Functions -
extension SharedVC {
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { [self] (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                let songsArray: [Song] = self.sharedSongsArray
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
            let songsArray: [Song] = self.sharedSongsArray
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
                let songsArray: [Song] = self.sharedSongsArray
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

extension SharedVC:BottomSheetDelegate{
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

extension SharedVC: FilterTable{
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}
extension SharedVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}


// MARK: - EmptyView Delegate Methods -
extension SharedVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Share songs", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have not any share song yet! ", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}
