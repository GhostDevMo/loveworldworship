//
//  MyPlayListVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import Async
import DeepSoundSDK
import EzPopup

class MyPlayListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var songsFilterType:FilterData = .ascending
    private var playlistArray = [Playlist]()
    private var refreshControl = UIRefreshControl()
    var playlistOffSet = "0"
    var playlistLastCount = 0
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchMyPlaylist()
        self.setupMusicPlayerNotification()
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        tableView.register(UINib(resource: R.nib.createPlaylistTableViewCell), forCellReuseIdentifier: R.reuseIdentifier.createPlaylistTableViewCell.identifier)
        tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        self.tableView.addPullToRefresh {
            self.playlistArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchMyPlaylist()
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
    
    func fetchMyPlaylist(){
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil{
                        Async.main({
                            log.debug("userList = \(success?.status ?? 0)")
                            self.playlistArray = success?.playlists ?? []
                            self.isLoading = false
                            self.tableView.reloadData()
                        })
                    }else if sessionError != nil {
                        Async.main({
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error)
                        })
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
        }
    }
}

extension MyPlayListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            if self.playlistArray.count == 0 {
                return 1
            }else{
                return self.playlistArray.count + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.btnPlayPause.isHidden = true
            cell.startSkelting()
            return cell
        }else {
            if self.playlistArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
                cell.selectionStyle = .none
                return cell
            }else{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.createPlaylistTableViewCell.identifier, for: indexPath) as! CreatePlaylistTableViewCell
                 return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                    cell.selectionStyle = .none
                    cell.stopSkelting()
                    let object = self.playlistArray[indexPath.row-1]
                    cell.indexPath = indexPath
                    cell.delegate = self
                    cell.bindProfilePlayList(object, index: indexPath.row-1)
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            if indexPath.row != 0 {
                let vc = R.storyboard.playlist.showPlaylistDetailsVC()
                vc?.playlistObject = self.playlistArray[indexPath.row-1]
                self.navigationController?.pushViewController(vc!, animated: true)
            }else {
                guard let vc = R.storyboard.playlist.createPlaylistVC() else { return }
                let panVC: PanModalPresentable.LayoutType = vc
                presentPanModal(panVC)
            }
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return UITableView.automaticDimension
        }else {
            if self.playlistArray.count == 0 {
                return 500.0
            } else {
                if indexPath.row == 0 {
                    return 80.0
                } else {
                    return UITableView.automaticDimension
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLoading {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.startSkelting()
            return headerView
        }else {
            if self.playlistArray.count == 0 {
                return nil
            }
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblOrderName.text = self.songsFilterType.type
            headerView.stopSkelting()
            headerView.lblTotalSongs.text = "\(playlistArray.count) PlayList"
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(_:)), for: .touchUpInside)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MyPlayListVC: SongsTableCellsDelegate {
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        
    }
    
    func moreButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        let panVC: PanModalPresentable.LayoutType = PlayListBottomSheetController(playlist: self.playlistArray[indexPath.row-1], delegate: self)
        presentPanModal(panVC)
    }
}

extension MyPlayListVC: PlayListBottomSheetDelegate {
    
    func editButton(_ sender: UIButton, object: Playlist) {
        self.view.endEditing(true)
        guard let vc = R.storyboard.playlist.createPlaylistVC() else { return }
        vc.selectedPlayList = object
        let panVC: PanModalPresentable.LayoutType = vc
        presentPanModal(panVC)
    }
}

//MARK: - Music Player Notification Handling Functions -
extension MyPlayListVC {
    func setupMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: "ReloadPlayListData") { notification in
            self.playlistArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchMyPlaylist()
        }
    }
}

extension MyPlayListVC: BottomSheetDelegate {
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

extension MyPlayListVC: FilterTable {
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        self.songsFilterType = order!
        switch order {
        case .ascending:
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            tableView.reloadData()
            break
        case .descending:
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            playlistArray = playlistArray.sorted(by: { $0.time ?? 0 > $1.time ?? 0})
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}

extension MyPlayListVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}
