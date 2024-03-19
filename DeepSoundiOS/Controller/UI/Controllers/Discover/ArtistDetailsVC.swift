//
//  ArtistDetailsVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 21/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds
import EmptyDataSet_Swift
import Toast_Swift

class ArtistDetailsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var topSongsArray = [Song]()
    var latestSongsArray: [Song] = []
    var playListArray: [Playlist] = []
    var storeArray: [Song] = []
    var albumArray: [Album] = []
    var eventsArray: [Events] = []
    var artistObject: Publisher?
    private var detailsDic: Details?
    private var followStatus: Bool = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.setuMusicPlayerNotification()
        self.fetchUserInfo()
    }
    
    // MARK: - Selectors
    
    @objc func didTapSeeAllBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag {
        case 1001:
            let newVC = R.storyboard.library.recentlyPlayedVC()
            newVC?.user_Id = self.artistObject?.id ?? 0
            newVC?.isOtherVC = true
            newVC?.titleSTR = "Latest Songs"
            self.navigationController?.pushViewController(newVC!, animated: true)
            break
        case 1002:
            let newVC = R.storyboard.library.recentlyPlayedVC()
            newVC?.user_Id = self.artistObject?.id ?? 0
            newVC?.isOtherVC = true
            newVC?.titleSTR = "Top Songs"
            self.navigationController?.pushViewController(newVC!, animated: true)
            break
        case 1003:
            break
        case 1004:
            break
        case 1005:
            break
        default:
            break
        }
    }
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let newVC = R.storyboard.popups.artistPopupVC() else {return}
        newVC.delegate = self
        self.present(newVC, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.artistInfoCell), forCellReuseIdentifier: R.reuseIdentifier.artistInfoCell.identifier)
        self.tableView.register(UINib(resource: R.nib.sectionHeaderTableItem), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashboardSectionThreeTableItem), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.dashboardTopAlbums_TableViewCell), forCellReuseIdentifier: R.reuseIdentifier.dashboardTopAlbums_TableViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.eventTableCell), forCellReuseIdentifier: R.reuseIdentifier.eventTableCell.identifier)
    }
    
}

// MARK: - Extensions

// MARK: API Call
extension ArtistDetailsVC {
    
    private func fetchUserInfo() {
        let userId = artistObject?.id ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, AccessToken: accessToken) { (success, sessionError, error) in
                Async.main {
                    self.tableView.stopPullToRefresh()
                }
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.followStatus = (success?.data?.is_following) ?? false
                            self.detailsDic = success?.details?.details
                            self.topSongsArray = success?.data?.top_songs?.first ?? []
                            self.latestSongsArray = success?.data?.latestsongs?.first ?? []
                            self.storeArray = success?.data?.store?.first ?? []
                            self.albumArray = success?.data?.albums?.first ?? []
                            self.eventsArray = success?.data?.events ?? []
                            self.playListArray = success?.data?.playlists?.first ?? []
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
            }
        }
    }
    
    private func followUser() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = artistObject?.id ?? 0
            Async.background {
                FollowManager.instance.followUser(Id: id, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been Followed")
                                self.fetchUserInfo()
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func unFollowUser() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = artistObject?.id ?? 0
            Async.background {
                FollowManager.instance.unFollowUser(Id: id, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been unfollowed")
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
    
    private func blockUser() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.artistObject?.id ?? 0
            Async.background {
                BlockUsersManager.instance.blockUser(Id: toID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
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
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension ArtistDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SuggestedSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = ArtistInfoSections(rawValue: section)!
        switch section {
        case .header:
            return 1
        case .latestsongs:
            if self.latestSongsArray.count != 0 {
                return 2
            }
        case .topsongs:
            if self.topSongsArray.count != 0 {
                return 2
            }
        case .playlist:
            if self.playListArray.count != 0 {
                return 2
            }
        case .store:
            if self.storeArray.count != 0 {
                return 2
            }
        case .event:
            if self.eventsArray.count != 0 {
                return 2
            }
        case .albums:
            if self.albumArray.count != 0 {
                return 2
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = ArtistInfoSections(rawValue: indexPath.section)!
        switch section {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistInfoCell.identifier, for: indexPath) as! ArtistInfoCell
            cell.stopSkelting()
            cell.selectionStyle = .none
            if let object = self.artistObject {
                cell.bind(object)
            }
            cell.delegate = self
            return cell
        case .latestsongs:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier, for: indexPath) as! SectionHeaderTableItem
                headerView.titleLabel.text = "Latest Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1001
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                cell.delegate = self
                cell.isloading = false
                cell.selectionStyle = .none
                cell.bind(latestSongsArray)
                return cell
            }
        case .topsongs:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier, for: indexPath) as! SectionHeaderTableItem
                headerView.titleLabel.text = "Latest Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1002
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                cell.delegate = self
                cell.isloading = false
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind(topSongsArray)
                return cell
            }
        case .albums:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier, for: indexPath) as! SectionHeaderTableItem
                headerView.titleLabel.text = "Albums"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1003
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardTopAlbums_TableViewCell.identifier) as! DashboardTopAlbums_TableViewCell
                cell.isloading = false
                cell.stopSkelting()
                cell.delegate = self
                cell.selectionStyle = .none
                cell.bind(albumArray)
                return cell
            }
        case .playlist:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier, for: indexPath) as! SectionHeaderTableItem
                headerView.titleLabel.text = "PlayList"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1004
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                cell.delegate = self
                cell.isloading = false
                cell.isPlaylist = true
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bindPlaylist(self.playListArray)
                return cell
            }
        case .store:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier, for: indexPath) as! SectionHeaderTableItem
                headerView.titleLabel.text = "Store"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1006
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                cell.delegate = self
                cell.isloading = false
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind(storeArray)
                return cell
            }
        case .event:
            if indexPath.row == 0 {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                headerView.selectionStyle = .none
                headerView.btnSeeAll.isHidden = false
                headerView.btnSeeAll.addTarget(self, action: #selector(didTapSeeAllBtnAction(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1005
                headerView.titleLabel.text = (NSLocalizedString("Event", comment: ""))
                return headerView
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventTableCell.identifier) as! EventTableCell
                cell.isEvent = true
                cell.selectionStyle = .none
                cell.delegate = self
                cell.isLoading = false
                cell.bind(eventsArray)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: Artist Info Cell Delegate
extension ArtistDetailsVC: ArtistInfoCellDelegate {
    
    func followUnfollowBtnAction(_ sender: UIButton) {
        if sender.currentTitle == "Follow" {
            sender.setTitle("Following", for: .normal)
            sender.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
            sender.setTitleColor(.mainColor, for: .normal)
            self.followUser()
        } else {
            sender.setTitle("Follow", for: .normal)
            sender.backgroundColor = .mainColor
            sender.setTitleColor(.white, for: .normal)
            self.unFollowUser()
        }
    }
    
    func messageBtnAction(_ sender: UIButton) {        
        let object = artistObject
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.userData = object
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: Dashboard Section TableView Delegate Methods
extension ArtistDetailsVC: DashaboardSectionTableItemDelegate {
    
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
        
    }
    
    func selectPlaylist(playlistArray: [Playlist], indexPath: IndexPath, cell: DashboardSectionThreeTableItem) {
        let vc = R.storyboard.playlist.showPlaylistDetailsVC()
        vc?.playlistObject = playlistArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated:true)
    }
    
}

// MARK: Music Player Notification Handling Functions
extension ArtistDetailsVC {
    
    func setuMusicPlayerNotification() {
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
    }
    
}

// MARK: Dashboard TopAlbums TableView Delegate Methods
extension ArtistDetailsVC: DashboardTopAlbumsTableViewCellDelegate {
    
    func selectAlbum(albumArray: [Album], indexPath: IndexPath, cell: DashboardTopAlbums_TableViewCell) {
        let vc = R.storyboard.dashboard.showAlbumVC()
        vc?.albumObject = albumArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: EventTableCellDelegate
extension ArtistDetailsVC: EventTableCellDelegate {
    
    func selectArticle(_ articleArray: [Blog], indexPath: IndexPath, cell: EventTableCell) {
        self.view.endEditing(true)
        let vc = R.storyboard.settings.articlesDetailsVC()
        vc?.object = articleArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated:true)
    }
    
    func selectEvent(_ eventsArray: [Events], indexPath: IndexPath, cell: EventTableCell) {
        self.view.endEditing(true)
        let vc = R.storyboard.products.eventDetailVC()
        vc?.eventDetailObject = eventsArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: Artist Popup Delegate
extension ArtistDetailsVC: ArtistPopupDelegate {
    
    func profileInfoPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let newVC = R.storyboard.settings.myInfoVC() else { return }
        newVC.publisher = self.artistObject
        newVC.detailsDic = self.detailsDic
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func blockPressed(_ sender: UIButton) {
        self.blockUser()
    }
    
    func copyProfileLinkPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        UIPasteboard.general.string = self.artistObject?.url
        self.view.makeToast("Link Copied Successfully!..")
    }
    
}

// MARK: BottomSheetDelegate
extension ArtistDetailsVC: BottomSheetDelegate {
    
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
