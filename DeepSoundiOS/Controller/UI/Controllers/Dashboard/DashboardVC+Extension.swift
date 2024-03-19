//
//  DashboardVC+Extension.swift
//  DeepSoundiOS
//
//  Created by iMac on 18/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import Toast_Swift

// MARK: API Services
extension DashboardVC {
    
    func fetchDiscover() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success, notDiscovered, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.mostPopularArray = success?.mostPopularWeek?.songDataValue?.data ?? []
                                self.slideShowArray = success?.randoms ?? nil
                                if self.type == .suggested {
                                    if AppInstance.instance.isLoginUser {
                                        self.fetchStoryAPI()
                                    }
                                    self.fetchGenres()
                                } else {
                                    self.isloading = false
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } else if notDiscovered != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(notDiscovered?.status ?? 0)")
                                self.latestSongsArray = notDiscovered?.newReleases?.data ?? []
                                if !(notDiscovered?.recentlyPlayed ?? []).isEmpty {
                                    self.recentlyPlayedArray = notDiscovered?.recentlyPlayed?.first?.data ?? []
                                }
                                self.mostPopularArray = notDiscovered?.mostPopularWeek?.songDataValue?.data ?? []
                                self.slideShowArray = notDiscovered?.randoms ?? nil
                                if self.type == .suggested {
                                    self.fetchGenres()
                                } else {
                                    self.isloading = false
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
        }
    }
    
    func fetchGenres() {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.genresArray = success?.data ?? []
                            if self.type == .suggested {
                                self.fetchArtist()
                            } else {
                                self.isloading = false
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            })
        }
    }
    
    func fetchArtist() {
        Async.background {
            ArtistManager.instance.getArtistAPI(Limit: 10, Offset: self.artistOffSet) { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? 0)")
                            let listArray = success?.data?.data ?? []
                            if self.artistOffSet == 0 {
                                self.artistArray = listArray
                                if self.type == .suggested {
                                    self.fetchTopAlbums()
                                } else {
                                    self.isloading = false
                                    self.tableView.reloadData()
                                }
                            } else {
                                self.artistArray.append(contentsOf: listArray)
                            }
                            self.artistLastCount = listArray.count
                            self.artistOffSet = listArray.last?.id ?? 0
                            if self.artistOffSet != 0 {
                                self.tableView.reloadData()
                                self.tableView.tableFooterView?.isHidden=true
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    func fetchTopAlbums() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                AlbumManager.instance.getTrending(limit: 12, views: self.topAlbumLastViews, ids: self.topAlbumLastIds) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.topAlbums ?? []
                                if self.topAlbumLastViews == "0" {
                                    self.topAlbumsArray = listArray
                                    if self.type == .suggested {
                                        self.fetchTopSongs()
                                    } else {
                                        self.isloading = false
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    self.topAlbumsArray.append(contentsOf: listArray)
                                }
                                self.topAlbumLastCount = listArray.count
                                self.topAlbumLastIds = listArray.last?.id ?? 0
                                switch listArray.last?.views {
                                case .integer(let value):
                                    self.topAlbumLastViews = "\(value)"
                                case .string(let value):
                                    self.topAlbumLastViews = value
                                case .none:
                                    break
                                }
                                if self.topAlbumLastViews != "0" {
                                    self.tableView.reloadData()
                                    self.tableView.tableFooterView?.isHidden=true
                                }
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
    
    func fetchTopSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                SongsManager.instance.getTopSongsAPI(limit: 20, offSet: self.topSongOffSet) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data ?? []
                                if self.topSongOffSet == "0" {
                                    self.topSongsArray = listArray
                                    if self.type == .suggested && AppInstance.instance.isLoginUser {
                                        self.fetchLatestsSongs()
                                    } else {
                                        self.isloading = false
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    self.topSongsArray.append(contentsOf: listArray)
                                }
                                self.topSongLastCount = listArray.count
                                switch listArray.last?.count_views {
                                case .integer(let value):
                                    self.topSongOffSet = "\(value)"
                                case .string(let value):
                                    self.topSongOffSet = value
                                case .none:
                                    break
                                }
                                if self.topSongOffSet != "0" {
                                    self.tableView.reloadData()
                                    self.tableView.tableFooterView?.isHidden=true
                                }
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
    
    func fetchLatestsSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                SongsManager.instance.getLatestSongsAPI(limit: 20, offSet: self.latestSongOffSet) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data ?? []
                                if self.latestSongOffSet == "0" {
                                    self.latestSongsArray = listArray
                                    if self.type == .suggested {
                                        self.fetchRecentlyPlayedSongs()
                                    } else {
                                        self.isloading = false
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    self.latestSongsArray.append(contentsOf: listArray)
                                }
                                self.latestSongLastCount = listArray.count
                                switch listArray.last?.count_views {
                                case .integer(let value):
                                    self.latestSongOffSet = "\(value)"
                                case .string(let value):
                                    self.latestSongOffSet = value
                                case .none:
                                    break
                                }
                                if self.latestSongOffSet != "0" {
                                    self.tableView.reloadData()
                                    self.tableView.tableFooterView?.isHidden=true
                                }
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
    
    func followUser(userId: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been Followed")
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
    
    func unFollowUser(userId: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
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
    
    func fetchRecentlyPlayedSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                RecentlyPlayedManager.instance.getRecentlyPlayed(Limit: 20, Offset: self.recentlySongOffSet) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data?.data ?? []
                                if self.recentlySongOffSet == "0" {
                                    self.recentlyPlayedArray = listArray
                                    self.isloading = false
                                } else {
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
    
    func purchaseSongWallet(trackId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                UpgradeMemberShipManager.instance.purchaseTrack(AccessToken: accessToken, type: "buy_song", TrackID: trackId) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success ?? "")")
                                self.view.makeToast(success ?? "")
                                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER)
                                self.isloading = true
                                self.tableView.reloadData()
                                switch self.type {
                                case .suggested, .popular:
                                    self.refresh()
                                    break
                                case .topsongs:
                                    self.topSongsArray.removeAll()
                                    self.topSongOffSet = "0"
                                    self.fetchTopSongs()
                                    break
                                case .latestsongs:
                                    self.latestSongsArray.removeAll()
                                    self.latestSongOffSet = "0"
                                    self.fetchLatestsSongs()
                                    break
                                case .recentlyplayed:
                                    self.recentlyPlayedArray.removeAll()
                                    self.recentlySongOffSet = "0"
                                    self.fetchRecentlyPlayedSongs()
                                    break
                                case .topalbums:
                                    self.topAlbumsArray.removeAll()
                                    self.topAlbumLastIds = 0
                                    self.topAlbumLastViews = "0"
                                    self.fetchTopAlbums()
                                    break
                                case .artists:
                                    self.artistArray.removeAll()
                                    self.artistOffSet = 0
                                    self.fetchArtist()
                                    break
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
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
    
    func fetchStoryAPI() {
        Async.background {
            StoryManager.instance.getStoryAPI { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose("success :--------- \(success?.data.count ?? 0)")
                            self.storysArray = success?.data ?? []
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: TableView Delegate and DataSources
extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if type == .suggested {
            if !AppInstance.instance.isLoginUser {
                return SuggestedSections.allCases.count + 2
            }
            return SuggestedSections.allCases.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isloading {
            if type == .suggested {
                if !AppInstance.instance.isLoginUser {
                    if section == 0 || section == 1 {
                        return 0
                    }
                } else {
                    if section == 0 {
                        return 0
                    }
                }
                let section = AppInstance.instance.isLoginUser ? (section-1) : (section-2)
                let categoryType = SuggestedSections(rawValue: section)!
                switch categoryType {
                case .genres:
                    return 1
                case .latestsongs:
                    return 1
                case .recentlyplayed:
                    return 1
                case .popular:
                    return 1
                case .artist:
                    return 1
                case .topSongs:
                    return 1
                case .topalbums:
                    return 1
                }
            } else {
                return 10
            }
        } else {
            if type == .suggested {
                if !AppInstance.instance.isLoginUser {
                    if section == 0 || section == 1 {
                        return 0
                    }
                } else {
                    if section == 0 {
                        return 0
                    }
                }
                let section = AppInstance.instance.isLoginUser ? (section-1) : (section-2)
                return self.getRowsForTableView(section: section).0
            } else if type == .topsongs {
                return topSongsArray.count
            } else if type == .topalbums {
                return topAlbumsArray.count
            } else if type == .artists {
                return artistArray.count
            } else if type == .recentlyplayed {
                return recentlyPlayedArray.count
            } else if type == .popular {
                return mostPopularArray.count
            } else if type == .latestsongs {
                return latestSongsArray.count
            }
        }
        return 1
    }
    
    func getRowsForTableView(section: Int) -> (Int, CGFloat) {
        let categoryType = SuggestedSections(rawValue: section)!
        switch categoryType {
        case .genres:
            if genresArray.count != 0 {
                return (1, 45.0)
            }
        case .latestsongs:
            if latestSongsArray.count != 0 {
                return (1, 45.0)
            }
        case .topalbums:
            if topAlbumsArray.count != 0 {
                return (1, 45.0)
            }
        case .recentlyplayed:
            if recentlyPlayedArray.count != 0 {
                return (1, 45.0)
            }
        case .popular:
            if mostPopularArray.count != 0 {
                return (1, 45.0)
            }
        case .artist:
            if artistArray.count != 0 {
                return (1, 45.0)
            }
        case .topSongs:
            if topSongsArray.count != 0 {
                return (1, 45.0)
            }
        }
        return (0,0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if type == .suggested {
            if !AppInstance.instance.isLoginUser {
                if section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noLoginTableItem.identifier) as! NoLoginTableItem
                    cell.delegate = self
                    self.isloading ? cell.startSkelting() : cell.stopSkelting()
                    return cell
                } else if section == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.createStoryTableCell.identifier) as! CreateStoryTableCell
                    cell.delegate = self
                    return cell
                }
            } else {
                if section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.createStoryTableCell.identifier) as! CreateStoryTableCell
                    cell.delegate = self
                    cell.bind(self.storysArray)
                    return cell
                }
            }
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
            self.isloading ? headerView.startSkelting() : headerView.stopSkelting()
            let section = AppInstance.instance.isLoginUser ? (section-1) : (section-2)
            let type = SuggestedSections(rawValue: section)!
            switch type {
            case .genres:
                headerView.titleLabel.text = "Genres"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = true
                return headerView
            case .latestsongs:
                headerView.titleLabel.text = "Latest Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag =  2
                return headerView
            case .recentlyplayed:
                if recentlyPlayedArray.count != 0 {
                    headerView.titleLabel.text = "Recently Played"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 3
                    return headerView
                }
                return nil
            case .popular:
                headerView.titleLabel.text = "Popular"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 5
                return headerView
            case .artist:
                headerView.titleLabel.text = "Artist"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 6
                return headerView
            case .topSongs:
                headerView.titleLabel.text = "Top Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1
                headerView.btnSeeAll.isHidden = false
                return headerView
            case .topalbums:
                headerView.titleLabel.text = "Top Albums"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 4
                headerView.btnSeeAll.isHidden = false
                return headerView
            }
        } else if type == .topsongs {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblOrderName.text = self.topSongsFilterType.type.capitalized
            headerView.lblTotalSongs.text = "\(topSongsArray.count) Top Songs"
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            return headerView
        } else if type == .artists {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblOrderName.text = self.artistsFilterType.type.capitalized
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(artistArray.count ) Artists"
            return headerView
        } else if type == .topalbums {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblOrderName.text = self.topAlbumsFilterType.type.capitalized
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(topAlbumsArray.count) Top Albums"
            return headerView
        } else if type == .recentlyplayed {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.lblOrderName.text = self.recentlyPlayedFilterType.type.capitalized
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(recentlyPlayedArray.count) Recently Played"
            return headerView
        } else if type == .popular {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.lblOrderName.text = self.popularFilterType.type.capitalized
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(mostPopularArray.count) Popular"
            return headerView
        } else {
            let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.assigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.lblOrderName.text = self.latestSongsFilterType.type.capitalized
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(latestSongsArray.count) Latest Songs"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.type == .suggested {
            if !AppInstance.instance.isLoginUser {
                if section == 0 {
                    return 75
                }
                if section == 1 {
                    return 200
                }
            } else {
                if section == 0 {
                    return 200
                }
            }
            let section = AppInstance.instance.isLoginUser ? (section-1) : (section-2)
            let height = self.getRowsForTableView(section: section).1
            self.tableView.sectionHeaderHeight = height
            return self.getRowsForTableView(section: section).1
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if self.type == .suggested {
            if !AppInstance.instance.isLoginUser {
                if section == 0 {
                    return 75
                }
                if section == 1 {
                    return 200
                }
            } else {
                if section == 0 {
                    return 200
                }
            }
            let section = AppInstance.instance.isLoginUser ? (section-1) : (section-2)
            let height = self.getRowsForTableView(section: section).1
            self.tableView.sectionHeaderHeight = height
            return self.getRowsForTableView(section: section).1
        }
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isloading ==  true {
            if type == .suggested {
                let section = AppInstance.instance.isLoginUser ? (indexPath.section-1) : (indexPath.section-2)
                let categoryType = SuggestedSections(rawValue: section)!
                switch categoryType {
                case .topSongs, .latestsongs, .popular, .recentlyplayed:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as! DashboardSectionThreeTableItem
                    cell.isloading = true
                    return cell
                case .genres:
                    let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.dashboardSectionTwoTableItem.identifier) as! DashboardSectionTwoTableItem
                    cell.isloading = true
                    return cell
                case .artist:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier) as! DashBoardSectionSixTableItem
                    cell.isloading = true
                    return cell
                case .topalbums:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardTopAlbums_TableViewCell.identifier) as! DashboardTopAlbums_TableViewCell
                    cell.isloading = true
                    return cell
                }
            } else if (type == .topsongs || type == .recentlyplayed || type == .latestsongs || type == .popular) {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.startSkelting()
                return cell
            } else if type == .topalbums {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
                cell.startSkelting()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
                cell.startSkelting()
                return cell
            }
        } else {
            if type == .suggested {
                let section = AppInstance.instance.isLoginUser ? (indexPath.section-1) : (indexPath.section-2)
                let categoryType = SuggestedSections(rawValue: section)!
                switch categoryType {
                case .topSongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as! DashboardSectionThreeTableItem
                    cell.delegate = self
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(topSongsArray)
                    return cell
                case .genres:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionTwoTableItem.identifier) as! DashboardSectionTwoTableItem
                    cell.delegate = self
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(genresArray)
                    return cell
                case .latestsongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as! DashboardSectionThreeTableItem
                    cell.delegate = self
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(latestSongsArray)
                    return cell
                case .recentlyplayed:
                    // let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFiveTableItem.identifier) as! DashboardSectionFiveTableItem
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as! DashboardSectionThreeTableItem
                    cell.delegate = self
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(recentlyPlayedArray)
                    return cell
                case .popular:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as! DashboardSectionThreeTableItem
                    cell.delegate = self
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(mostPopularArray)
                    return cell
                case .artist:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier) as! DashBoardSectionSixTableItem
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.delegate = self
                    cell.selectionStyle = .none
                    cell.bind(artistArray)
                    return cell
                case .topalbums:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardTopAlbums_TableViewCell.identifier) as! DashboardTopAlbums_TableViewCell
                    cell.isloading = false
                    cell.stopSkelting()
                    cell.delegate = self
                    cell.selectionStyle = .none
                    cell.bind(topAlbumsArray)
                    return cell
                }
            } else if type == .topsongs {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind((topSongsArray[indexPath.row]))
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            } else if type == .artists {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.btnFollow.tag = indexPath.row
                cell.delegate = self
                cell.bind(artistArray[indexPath.row])
                return cell
            } else if type == .topalbums {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
                cell.stopSkelting()
                cell.selectionStyle = .none
                let object = self.topAlbumsArray[indexPath.row]
                cell.publicAlbumBind(object)
                return cell
            } else if type == .popular {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind((mostPopularArray[indexPath.row]))
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            } else if type == .latestsongs {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind((latestSongsArray[indexPath.row]))
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            } else if type == .recentlyplayed {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.songsTableCells.identifier, for: indexPath) as! SongsTableCells
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.bind((recentlyPlayedArray[indexPath.row]))
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.foldersTableCell.identifier) as! FoldersTableCell
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == .artists {
            if self.artistArray[indexPath.row].artist == 0 {
                let vc = R.storyboard.dashboard.showProfile2VC()
                vc?.userID  = self.artistArray[indexPath.row].id ?? 0
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                let vc = R.storyboard.discover.artistDetailsVC()
                vc?.artistObject = self.artistArray[indexPath.row]
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else if type == .topalbums {
            let vc = R.storyboard.dashboard.showAlbumVC()
            vc?.albumObject = topAlbumsArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if type == .artists {
            if indexPath.row == (self.artistArray.count - 1) {
                if !(self.artistLastCount < 10) {
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView?.isHidden = false
                        self.activityIndicator.startAnimating()
                        self.fetchArtist()
                    }
                }
            }
        } else if type == .topalbums {
            if indexPath.row == (self.topAlbumsArray.count - 1) {
                if !(self.topAlbumLastCount < 12) {
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView?.isHidden = false
                        self.activityIndicator.startAnimating()
                        self.fetchTopAlbums()
                    }
                }
            }
        }
        if AppInstance.instance.isLoginUser {
            if type == .topsongs {
                if indexPath.row == (self.topSongsArray.count - 1) {
                    if !(self.topSongLastCount < 20) {
                        DispatchQueue.main.async {
                            self.tableView.tableFooterView?.isHidden = false
                            self.activityIndicator.startAnimating()
                            self.fetchTopSongs()
                        }
                    }
                }
            } else if type == .latestsongs {
                if indexPath.row == (self.latestSongsArray.count - 1) {
                    if !(self.latestSongLastCount < 20) {
                        DispatchQueue.main.async {
                            self.tableView.tableFooterView?.isHidden = false
                            self.activityIndicator.startAnimating()
                            self.fetchLatestsSongs()
                        }
                    }
                }
            } else if type == .recentlyplayed {
                if indexPath.row == (self.recentlyPlayedArray.count - 1) {
                    if !(self.recentlySongLastCount < 20) {
                        DispatchQueue.main.async {
                            self.tableView.tableFooterView?.isHidden = false
                            self.activityIndicator.startAnimating()
                            self.fetchRecentlyPlayedSongs()
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: CollectionView Delegate and DataSources
extension DashboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeCategoryTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.categoryCell.identifier, for: indexPath) as! CategoryCell
        cell.categoryLabel.text = self.homeCategoryTitle[indexPath.row]
        if indexPath.row == self.selectedCategoryIndex {
            cell.backView.backgroundColor = .ButtonColor
            cell.categoryLabel.textColor = .ButtonColor
        } else {
            cell.backView.backgroundColor = .clear
            cell.categoryLabel.textColor = .gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !(self.isloading) {
            self.selectedCategoryIndex = indexPath.row
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadData()
            self.type = DashboardActionType(rawValue: self.selectedCategoryIndex) ?? .suggested
            if AppInstance.instance.isLoginUser {
                if indexPath.row != 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if self.type == .recentlyplayed {
                            if self.recentlyPlayedArray.count == 0 {
                                return
                            }
                        } else if self.type == .popular {
                            if self.mostPopularArray.count == 0 {
                                return
                            }
                        }
                        self.scrollToTop()
                    }
                }
            }
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: getWidthFromItem(title: self.homeCategoryTitle[indexPath.row], font: setCustomFont(size: 16.0, fontName: R.font.urbanistSemiBold.name)).width + 30.0, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    // Get Width From String
    func getWidthFromItem(title: String, font: UIFont) -> CGSize {
        let itemSize = title.size(withAttributes: [
            NSAttributedString.Key.font: font
        ])
        return itemSize
    }
    
    // Set Custom Font
    func setCustomFont(size: CGFloat, fontName: String) -> UIFont {
        return UIFont.init(name: fontName, size: size)!
    }
    
}

// MARK: followUserDelegate
extension DashboardVC: followUserDelegate {
    
    func followUser(_ index: Int, _ sender: UIButton) {
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let userId = self.artistArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        artistArray[sender.tag].is_following = !(artistArray[sender.tag].is_following)
        if sender.currentTitle == "Follow" {
            sender.setTitle("Following", for: .normal)
            sender.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
            sender.setTitleColor(.mainColor, for: .normal)
            self.followUser(userId: userId)
        } else {
            sender.setTitle("Follow", for: .normal)
            sender.backgroundColor = .mainColor
            sender.setTitleColor(.white, for: .normal)
            self.unFollowUser(userId: userId)
        }
    }
}

// MARK: CreateStoryDelegate
extension DashboardVC: CreateStoryDelegate {
    
    func createStoryPressed() {
        if AppInstance.instance.isLoginUser {
            self.view.endEditing(true)
            guard let newVC = R.storyboard.dashboard.createStoryVC() else { return }
            self.navigationController?.pushViewController(newVC, animated: true)
        } else {
            self.showLoginAlert(delegate: self)
        }
    }
    
    func storyView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let newVC = R.storyboard.dashboard.showStoryVC() else { return }
        newVC.storyArray = self.storysArray
        self.present(newVC, animated: true)
    }
    
}
