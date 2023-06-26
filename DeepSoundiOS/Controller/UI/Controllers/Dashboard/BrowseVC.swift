//
//  BrowseVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds

class BrowseVC: BaseVC {
    
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var searchBar = UISearchBar(frame: .zero)
    private var topSongsArray = [TrendingModel.TopSong]()
    private var topAlbumsArray = [TrendingModel.TopAlbum]()
    private var refreshControl = UIRefreshControl()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var topSongMusicArray = [MusicPlayerModel]()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.titleLabel.title = (NSLocalizedString("Top Listings", comment: ""))
        self.fetchTrending()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
                if ControlSettings.shouldShowAddMobBanner{
        
                    //bannerView = GADBannerView(adSize: GADAdSize())
                    addBannerViewToView(bannerView)
                    bannerView.adUnitID = ControlSettings.addUnitId
                    bannerView.rootViewController = self
                    bannerView.load(GADRequest())
                 
                    let request = GADRequest()
                    GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                                           request: request,
                                           completionHandler: { (ad, error) in
                                            if let error = error {
                                                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                                return
                                            }
                                            self.interstitial = ad
                                           }
                    )
        
                }
    }
    
    func CreateAd() -> GADInterstitialAd {
        
        GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                               request: GADRequest(),
                               completionHandler: { (ad, error) in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               }
        )
        return  self.interstitial
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    private func setupUI(){
        
        searchBar.placeholder = (NSLocalizedString("Search...", comment: ""))
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        self.tableView.separatorStyle = .none
        self.tableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.tableView.register(BrowserSectionOneTableItem.nib, forCellReuseIdentifier: BrowserSectionOneTableItem.identifier)
        self.tableView.register(BrowserSectionTwoTableItem.nib, forCellReuseIdentifier: BrowserSectionTwoTableItem.identifier)
        tableView.register(ProfileAlbumsTableCell.nib, forCellReuseIdentifier: ProfileAlbumsTableCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        
        refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        //        scrollView.addSubview(refreshControl)
        
    }
    
    @objc func refresh(sender:AnyObject) {
        self.topSongsArray.removeAll()
        self.topAlbumsArray.removeAll()
        self.tableView.reloadData()
        self.fetchTrending()
        refreshControl.endRefreshing()
    }
    private func fetchTrending(){
        if Connectivity.isConnectedToNetwork(){
            self.topSongsArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                TrendingManager.instance.getTrending(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.topSongsArray = success?.topSongs ?? []
                                self.topAlbumsArray = success?.topAlbums ?? []
                                self.tableView.reloadData()
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(NSLocalizedString((InterNetError), comment: ""))
        }
    }
    
}
extension BrowseVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.tintColor = .white
        searchBar.resignFirstResponder()
        let vc = R.storyboard.search.searchParentVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func BrowseVC(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
    }
}
extension BrowseVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            if self.topAlbumsArray.count ==  0{
                return 1
            }else{
                return self.topAlbumsArray.count ?? 0
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString(("Top Songs"), comment: ""))
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserSectionOneTableItem.identifier) as? BrowserSectionOneTableItem
            cell?.selectionStyle = .none
           // cell?.loggedInVC = self
            cell?.bind(topSongsArray)
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString(("Top Albums"), comment: ""))
            return cell!
        case 3:
            if (self.topAlbumsArray.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                cell?.selectionStyle = .none
                
                let object = self.topAlbumsArray[indexPath.row]
                cell?.publicAlbumBind(object)
                return cell!
            }
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
            
        case 1:
            return 300
        case 2:
            return UITableView.automaticDimension
            
        case 3:
            if (self.topAlbumsArray.isEmpty){
                return 300.0
            }else{
                
                return 120.0
            }
            
            
        default:
            return 280
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            let vc = R.storyboard.dashboard.showAlbumVC()
            vc?.albumObject = self.topAlbumsArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            log.verbose("Nothing to push")
        }
    }
    
}
