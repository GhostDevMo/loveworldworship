//
//  NotLoggedInPlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 3/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds

class NotLoggedInPlaylistVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var publicPlaylistArray = [PublicPlaylistModel.Playlist]()
    private var PlaylistArray = [PlaylistModel.Playlist]()
    private var refreshControl = UIRefreshControl()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.navigationItem.title = NSLocalizedString("Trending", comment: "Trending")
        fetchPublicPlaylist()
//        self.fetchMyPlaylist()
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

            
            bannerView = GADBannerView(adSize: GADAdSize())
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    private func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.tableView.register(PlayListSectionOneTableItem.nib, forCellReuseIdentifier: PlayListSectionOneTableItem.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                    refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
                    self.tableView.addSubview(refreshControl)
        
    }
    @objc func refresh(sender:AnyObject) {
             self.publicPlaylistArray.removeAll()
             self.PlaylistArray.removeAll()
             self.tableView.reloadData()
             fetchPublicPlaylist()
             self.fetchMyPlaylist()
             refreshControl.endRefreshing()
         }
    private func fetchPublicPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.publicPlaylistArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PlaylistManager.instance.getPublicPlayList(AccessToken: accessToken, Limit: 20, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.playlists?.count ?? 0)")
                                self.publicPlaylistArray = success?.playlists ?? []
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
    private func fetchMyPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.publicPlaylistArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.PlaylistArray = success?.playlists ?? []
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

extension NotLoggedInPlaylistVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = NSLocalizedString("Hot PlayList", comment: "Hot PlayList")
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayListSectionOneTableItem.identifier) as? PlayListSectionOneTableItem
            cell?.selectionStyle = .none
            cell?.noLoggedVC = self
            cell?.bind(publicPlaylistArray)
            return cell!
            
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
            
        default:
            return 280
        }
    }
    
    
}
