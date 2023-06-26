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
import PureLayout

class LibraryVC: BaseVC {
    
    @IBOutlet weak var chatBtn: UIButton!
    
    let libraryNameArray = [
        (NSLocalizedString("Liked", comment: "")),
        (NSLocalizedString("Recently Played", comment: "")),
        (NSLocalizedString("Favorite", comment: "")),
        (NSLocalizedString("Shared", comment: "")),
        (NSLocalizedString("Latest Download", comment: "")),
        (NSLocalizedString("Purchases", comment: ""))
        
    ]
    let libraryImageArray = [
        "ic-heart-bs",
        "ic-play-squre",
        "ic-heart-bs",
        "ic-share-bs",
        "ic-download-square",
         "ic-purchase"
    ]
    let libraryNameArray1 = [
           NSLocalizedString("Liked", comment: ""),
           (NSLocalizedString("Recently Played", comment: "")),
           (NSLocalizedString("Favorite", comment: "")),
           (NSLocalizedString("Shared", comment: "")),
           (NSLocalizedString("Latest Download", comment: "")),
           (NSLocalizedString("Purchases", comment: ""))
       ]
       let libraryImageArray1 = [
           "ic-heart-bs",
           "ic-play-squre",
           "ic-heart-bs",
           "ic-share-bs",
            "ic-purchase"
       ]
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    private var recentlyPlayedArray:DiscoverModel.RecentlyplayedUnion?
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var libraryTableView: UITableView!
    
    @IBOutlet weak var viewAlbumss: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let fileView = self.storyboard!.instantiateViewController(withIdentifier: "Dashboard1VC") as? Dashboard1VC {
            fileView.typeFromLibrary =  .topalbums
            fileView.fromLibraryVC = true
            self.addChild(fileView)
            viewAlbumss.addSubview(fileView.view)
            fileView.view.configureForAutoLayout()
            fileView.view.autoPinEdgesToSuperviewEdges()
            fileView.didMove(toParent: self)
        }
        self.showProgressDialog(text: "Loading...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismissProgressDialog { }
        }
        self.chatBtn.tintColor = .ButtonColor
        self.setupUI()
        self.titleLabel.title = (NSLocalizedString("Library", comment: ""))
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
           // bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//            addBannerViewToView(bannerView)
//            bannerView.adUnitID = ControlSettings.addUnitId
//            bannerView.rootViewController = self
//            bannerView.load(GADRequest())
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
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDiscover()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    private func fetchDiscover(){
        if Connectivity.isConnectedToNetwork(){

            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,NotDiscovered, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            log.debug("userList = \(success?.status ?? 0)")
                            AppInstance.instance.latestSong = success?.newReleases?.data ?? []
                            if ((success?.recentlyPlayed?.emptyArray?.isEmpty) == true){
                            }else{
                                self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
                            }
                           
                            self.libraryTableView.reloadData()
                            
                            
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                                
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            
                        })
                    }else {
                        Async.main({
                            
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
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
        self.libraryTableView.separatorStyle = .none
        libraryTableView.register(Library_TableCell.nib, forCellReuseIdentifier: Library_TableCell.identifier)
        self.libraryTableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.libraryTableView.register(DashboardSectionFourTableItem.nib, forCellReuseIdentifier: DashboardSectionFourTableItem.identifier)    }
    
    
    @IBAction func chatPressed(_ sender: Any) {
        let vc = R.storyboard.chat.chatVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension LibraryVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
       if recentlyPlayedArray?.newRelease?.count != 0{
            return 2
        }
        else{
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recentlyPlayedArray?.newRelease?.count != 0{

            return 1
        }
        else{
        if ControlSettings.showHideDownloadBtn{
               return self.libraryNameArray1.count
        }else{
               return self.libraryNameArray.count
        }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if recentlyPlayedArray?.newRelease?.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFourTableItem.identifier) as! DashboardSectionFourTableItem
            cell.selectionStyle = .none
            cell.loggedLibrayInVC = self
            cell.bind(recentlyPlayedArray?.newRelease ?? nil)
            return cell
        }
        else{
        if ControlSettings.showHideDownloadBtn{
                   let cell = tableView.dequeueReusableCell(withIdentifier: Library_TableCell.identifier) as? Library_TableCell
                       cell?.libraryImage.image = UIImage(named: self.libraryImageArray1[indexPath.row])
                       cell?.nameLabel.text = self.libraryNameArray1[indexPath.row]
                       return cell!
               }else{
                     let cell = tableView.dequeueReusableCell(withIdentifier: Library_TableCell.identifier) as? Library_TableCell
                         cell?.libraryImage.image = UIImage(named: self.libraryImageArray[indexPath.row])
                         cell?.nameLabel.text = self.libraryNameArray[indexPath.row]
                         return cell!
               }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.section == 0{
        if recentlyPlayedArray?.newRelease?.count != 0{
            return UITableView.automaticDimension
        }
        }
        else{
            return UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
            interstitial.present(fromRootViewController: self)
                interstitial = CreateAd()
                AppInstance.instance.addCount = 0
        }
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        self.showDidScreen(index: indexPath.row, ShowHideDownloadBtn: ControlSettings.showHideDownloadBtn)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && recentlyPlayedArray?.newRelease?.count != 0 {
            return 50
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
        let headerView = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as! SectionHeaderTableItem
        headerView.titleLabel.text = "Resently Played"
       // headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
        //headerView.btnSeeAll.tag = section - 1
        return headerView
        }
        else{
            return nil
        }
    }
    private func showDidScreen(index:Int?,ShowHideDownloadBtn:Bool){
        if ShowHideDownloadBtn{
            if index == 0{
                       let vc = R.storyboard.library.likedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                   }else if index == 1{
                       let vc = R.storyboard.library.recentlyPlayedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 2{
                       let vc = R.storyboard.library.favoriteVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 3{
                       let vc = R.storyboard.library.sharedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 4{
                       let vc = R.storyboard.library.purchasesVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }
        }else{
            if index == 0{
                       let vc = R.storyboard.library.likedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                   }else if index == 1{
                       let vc = R.storyboard.library.recentlyPlayedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 2{
                       let vc = R.storyboard.library.favoriteVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 3{
                       let vc = R.storyboard.library.sharedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 4{
                       let vc = R.storyboard.library.latestDownloadVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 5{
                       let vc = R.storyboard.library.purchasesVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }
        }
       
        
    }
}
