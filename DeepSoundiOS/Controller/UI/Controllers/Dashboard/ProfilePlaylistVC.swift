//
//  ProfilePlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import EzPopup
import Toast_Swift

class ProfilePlaylistVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var parentVC: BaseVC?
    var isOtherUser = false
    var userID: Int?
    var playlistArray: [Playlist] = []
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchUserProfile()
        self.tableView.addPullToRefresh {
            self.playlistArray.removeAll()
            self.tableView.reloadData()
            self.fetchUserProfile()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        tableView.register(UINib(resource: R.nib.assigingOrderHeaderTableCell), forCellReuseIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier)
        tableView.register(UINib(resource: R.nib.songsTableCells), forCellReuseIdentifier: R.reuseIdentifier.songsTableCells.identifier)
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.delegate = self
        tableView.dataSource = self
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
            ProfileManger.instance.getProfile(UserId: userId, fetch: "playlists", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.playlistArray = success?.data?.playlists?.first ?? []
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
                            // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
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

// MARK: TableView Setup
extension ProfilePlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if playlistArray.count == 0 {
            return 1
        }
        return playlistArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if playlistArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
            cell.titleLabel.text = "No Playlist"
            cell.noDataLabel.text = "You have not any playlist yet! "
            return cell
        }
        if indexPath.row == 0 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as! AssigingOrderHeaderTableCell
            headerView.lblTotalSongs.text = "\(playlistArray.count) PlayList"
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            return headerView
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
            cell.selectionStyle = .none
            let object = playlistArray[indexPath.row-1]
            cell.btnPlayPause.tag = indexPath.row-1
            cell.btnPlayPause.isHidden = true
            cell.btnMore.tag = indexPath.row-1
            cell.indexPath = indexPath
            cell.delegate = self
            cell.bindProfilePlayList(object, index: indexPath.row-1)
            return cell
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playlistArray.count != 0 {
            let vc = R.storyboard.playlist.showPlaylistDetailsVC()
            vc?.playlistObject = playlistArray[indexPath.row-1]
            self.parentVC?.navigationController?.pushViewController(vc!, animated:true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: SongsTableCellsDelegate
extension ProfilePlaylistVC: SongsTableCellsDelegate {
    
    func playButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        
    }
    
    func moreButtonPressed(_ sender: UIButton, indexPath: IndexPath, cell: SongsTableCells) {
        let panVC: PanModalPresentable.LayoutType = PlayListBottomSheetController(playlist: self.playlistArray[indexPath.row-1], delegate: self)
        presentPanModal(panVC)
    }
}

// MARK: PlayListBottomSheetDelegate
extension ProfilePlaylistVC: PlayListBottomSheetDelegate {
    
    func editButton(_ sender: UIButton, object: Playlist) {
        self.view.endEditing(true)
        guard let vc = R.storyboard.playlist.createPlaylistVC() else { return }
        vc.selectedPlayList = object
        let panVC: PanModalPresentable.LayoutType = vc
        presentPanModal(panVC)
    }
    
}

// MARK: FilterTable
extension ProfilePlaylistVC: FilterTable {
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
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
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
    
}

// MARK: PopupViewControllerDelegate
extension ProfilePlaylistVC: PopupViewControllerDelegate {
    
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        
    }
    
}
