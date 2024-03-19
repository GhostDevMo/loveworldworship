//
//  LibraryVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds
import Async
import Toast_Swift

class LibraryVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var libraryTableView: UITableView!
    
    // MARK: - Properties
    
    let libraryNameArray = [
        "Playlists",
        "Liked",
        "Downloads",
        "Shared",
        "Purchases"
    ]
    let libraryImageArray = [
        "icn_playlist_01",
        "ic-heart-bs",
        "ic-download-square",
        "icn_share",
        "ic-purchase"
    ]
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    private var recentlyPlayedArray: [Song] = []
    var isloading = true {
        didSet {
            if isloading {
                self.libraryTableView.reloadData()
            }
        }
    }
    // private let popupContentController = R.storyboard.player.musicPlayerVC()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.titleLabel.title = (NSLocalizedString("Library", comment: ""))
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        if ControlSettings.shouldShowAddMobBanner {
            // bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            // addBannerViewToView(bannerView)
            // bannerView.adUnitID = ControlSettings.addUnitId
            // bannerView.rootViewController = self
            // bannerView.load(GADRequest())
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId, request: request, completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchRecentlyPlayedSongs()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Selectors
    
    @objc func seeAllButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.library.recentlyPlayedVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    @IBAction func chatPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.chat.chatVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    private func fetchRecentlyPlayedSongs() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                RecentlyPlayedManager.instance.getRecentlyPlayed(Limit: 20, Offset: "0") { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                let listArray = success?.data?.data ?? []
                                self.recentlyPlayedArray = listArray
                                self.isloading = false
                                self.libraryTableView.reloadData()
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
    
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: ControlSettings.interestialAddUnitId, request: GADRequest(), completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        })
        return self.interstitial
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
        self.libraryTableView.separatorStyle = .none
        self.libraryTableView.register(UINib(resource: R.nib.library_TableCell), forCellReuseIdentifier: R.reuseIdentifier.library_TableCell.identifier)
        self.libraryTableView.register(UINib(resource: R.nib.sectionHeaderTableItem), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.libraryTableView.register(UINib(resource: R.nib.dashboardSectionThreeTableItem), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier)
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension LibraryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isloading {
                return 1
            } else {
                if recentlyPlayedArray.count != 0 {
                    return 1
                }else {
                    return 0
                }
            }
        } else {
            return self.libraryNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isloading {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                cell.isloading = self.isloading
                return cell
            } else {
                if recentlyPlayedArray.count != 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier, for: indexPath) as! DashboardSectionThreeTableItem
                    cell.isloading = self.isloading
                    cell.lineView.isHidden = false
                    cell.delegate = self
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.bind(recentlyPlayedArray)
                    return cell
                }
                return UITableViewCell()
            }
        } else {
            let cell = libraryTableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.library_TableCell.identifier, for: indexPath) as! Library_TableCell
            cell.libraryImage.image = UIImage(named: self.libraryImageArray[indexPath.row])
            cell.nameLabel.text = self.libraryNameArray[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if isloading {
                return UITableView.automaticDimension
            } else {
                if recentlyPlayedArray.count != 0 {
                    return 230 // UITableView.automaticDimension
                }
                return 0
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*if AppInstance.instance.addCount == ControlSettings.interestialCount {
         interstitial.present(fromRootViewController: self)
         interstitial = CreateAd()
         AppInstance.instance.addCount = 0
         }
         AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
         self.showDidScreen(index: indexPath.row, ShowHideDownloadBtn: ControlSettings.showHideDownloadBtn)*/
        self.showDidScreen(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if isloading {
                return 50
            } else {
                if recentlyPlayedArray.count != 0 {
                    return 50
                }
                return 0
            }
        } else {
            self.libraryTableView.sectionHeaderHeight = 0
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if isloading {
                let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                headerView.startSkelting()
                headerView.titleLabel.text = "Recently Played"
                // headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                //headerView.btnSeeAll.tag = section - 1
                return headerView
            } else {
                if recentlyPlayedArray.count != 0 {
                    let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    headerView.stopSkelting()
                    headerView.titleLabel.text = "Recently Played"
                    headerView.btnSeeAll.addTarget(self, action: #selector(seeAllButtonPressed(_:)), for: .touchUpInside)
                    return headerView
                }
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func showDidScreen(index: Int) {
        if index == 0 {
            let vc = R.storyboard.library.myPlayListVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if index == 1 {
            let vc = R.storyboard.library.likedVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if index == 2 {
            let vc = R.storyboard.library.latestDownloadVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if index == 3 {
            let vc = R.storyboard.library.sharedVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if index == 4 {
            let vc = R.storyboard.library.purchasesVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}

// MARK: DashaboardSectionTableItemDelegate
extension LibraryVC: DashaboardSectionTableItemDelegate {
    
    func selectArtist(publisherArray: [Publisher], indexPath: IndexPath, cell: DashBoardSectionSixTableItem) {
        
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

// MARK: BottomSheetDelegate
extension LibraryVC: BottomSheetDelegate {
    
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
