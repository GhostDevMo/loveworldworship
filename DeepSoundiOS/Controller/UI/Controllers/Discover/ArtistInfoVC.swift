//
//  ArtistInfoVC.swift
//  DeepSoundiOS
//
//  Created by Moghees on 25/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import Async
import SwiftEventBus
import DeepSoundSDK
import SwiftUI
class ArtistInfoVC: BaseVC {
    @IBOutlet weak var tableView: UITableView!
    var artistObject:ArtistModel.Datum?
    private var latestSongArray = [UserInfoModel.Latestsong]()
    private var topSongArray = [UserInfoModel.Latestsong]()
    private var storeSongsArray = [UserInfoModel.Latestsong]()
    private var activitiesArray = [UserInfoModel.Activity]()
    var followersObject:FollowerModel.Datum?
    var followingObject:FollowingModel.Datum?
    private var followStatus:Bool? = false
    var artistSearchObject:SearchModel.Artist?
    private var detailsDic = [String:Int]()
    private var refreshControl = UIRefreshControl()
    var isLoading = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        fetchUserInfo()
    }
    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.tableView.register(DashboardSectionThreeTableItem.nib, forCellReuseIdentifier: DashboardSectionThreeTableItem.identifier)
        self.tableView.register(BrowserSectionOneTableItem.nib, forCellReuseIdentifier: BrowserSectionOneTableItem.identifier)
        self.tableView.register(PlayListSectionOneTableItem.nib, forCellReuseIdentifier: PlayListSectionOneTableItem.identifier)
        self.tableView.register(ArtistInfoCell.nib, forCellReuseIdentifier: ArtistInfoCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        self.tableView.register(ArtistInfoDetail.nib, forCellReuseIdentifier: ArtistInfoDetail.identifier)
        self.tableView.register(UINib(nibName: "EventTableCell", bundle: nil), forCellReuseIdentifier: "EventTableCell")
        
        
        refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        
        let button = UIButton()
        button.setImage(UIImage(named: "ic-round-dotedmore"), for:.normal)
        button.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let barButton = UIBarButtonItem(customView: button)
       self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    @objc func refresh(sender:AnyObject) {
           self.latestSongArray.removeAll()

           self.topSongArray.removeAll()
           self.storeSongsArray.removeAll()
           self.activitiesArray.removeAll()
           self.tableView.reloadData()
           self.fetchUserInfo()
           refreshControl.endRefreshing()
       }
    @objc func showMore(_ sender:UIButton){
    if AppInstance.instance.getUserSession(){
        
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @objc func didTappSeeAll(_ sender:UIButton){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
         let vc = storyBoard.instantiateViewController(withIdentifier: "InfoListVC") as! InfoListVC
       
         
   
        let section = ArtistInfoSections(rawValue: sender.tag)!
        
        switch section {
            
        case .header:
            break
        case .latestsongs:
            vc.songArray =  self.latestSongArray
            vc.tittle = "Latest Songs"
          
        case .topsongs:
            vc.songArray = self.topSongArray
            vc.tittle = "Top Songs"
        case .playlist:
            
            vc.songArray = self.storeSongsArray
            vc.tittle = "Playlist Songs"
           
        case .store:
            vc.songArray = self.storeSongsArray
            vc.tittle = "Store Song"
        case .event:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
   @objc func followPressed(_ sender: UIButton) {
        if AppInstance.instance.getUserSession(){
            self.followStatus = !self.followStatus!
            if self.followStatus!{
                 sender.setImage(R.image.ic_tick(), for: .normal)
                sender.backgroundColor = UIColor.hexStringToUIColor(hex: "FFA143")
                self.followUser()
                
            }else{
                sender.setImage(R.image.ic_add(), for: .normal)
                sender.backgroundColor = UIColor.hexStringToUIColor(hex: "444444")
                self.unFollowUser()
            }
        }else{
           // self.loginAlert()
        }
        
        
    }
    private func followUser(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            var userIDSelectedFollow:Int? = 0
            if artistObject != nil{
                userIDSelectedFollow = artistObject?.id ??  0
            }else if followersObject != nil{
                userIDSelectedFollow = followersObject?.id ??  0
            }else if followingObject != nil {
                userIDSelectedFollow = followingObject?.id ??  0
            }else if artistSearchObject != nil{
                userIDSelectedFollow = artistSearchObject?.id ??  0
            }
            
            Async.background({
                FollowManager.instance.followUser(Id: userIDSelectedFollow!, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                
                                self.view.makeToast("User has been Followed")
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func unFollowUser(){
        if Connectivity.isConnectedToNetwork(){
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            var userIDSelectedunFollwo:Int? = 0
            if artistObject != nil{
                userIDSelectedunFollwo = artistObject?.id ??  0
            }else if followersObject != nil{
                userIDSelectedunFollwo = followersObject?.id ??  0
            }else if followingObject != nil {
                userIDSelectedunFollwo = followingObject?.id ??  0
                
            }else if artistSearchObject != nil{
                userIDSelectedunFollwo = artistSearchObject?.id ??  0
            }
            
            Async.background({
                FollowManager.instance.unFollowUser(Id: userIDSelectedunFollwo!, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been unfollowed")
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }

    private func fetchUserInfo(){
        if Connectivity.isConnectedToNetwork(){
            self.latestSongArray.removeAll()
            self.topSongArray.removeAll()
            self.storeSongsArray.removeAll()
            
        //    self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            var userIDSelectedFetch:Int? = 1
//            if artistObject != nil{
//                userIDSelectedFetch = artistObject?.id ??  0
//            }else if followersObject != nil{
//                userIDSelectedFetch = followersObject?.id ??  0
//            }else if followingObject != nil {
//                userIDSelectedFetch = followingObject?.id ??  0
//
//            }else if artistSearchObject != nil{
//                userIDSelectedFetch = artistSearchObject?.id ??  0
//            }
            Async.background({
                UserInforManager.instance.getUserInfo(UserId: userIDSelectedFetch!, AccessToken: accessToken, Fetch_String: "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,activities,latest_songs,top_songs,store", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.followStatus = (success?.data?.isFollowing) ?? false
                                if (success?.data?.isFollowing) ?? false{
//                                    self.followBtn.setImage(R.image.ic_tick(), for: .normal)
//                                    self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "FFA143")
                                    
                                }else{
//                                    self.followBtn.setImage(R.image.ic_add(), for: .normal)
//                                    self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "444444")
                                }
                                self.latestSongArray = success?.data?.latestsongs ?? []
                                self.topSongArray = success?.data?.topSongs ?? []
                                self.storeSongsArray = success?.data?.store?[0] ?? []
                                self.activitiesArray = success?.data?.activities ?? []
                                self.isLoading = false
                                self.tableView.reloadData()
                               
                                self.detailsDic = success?.details ?? [:]
//                                
//                                self.followerCountLabel.text = "\(success?.details!["followers"] ?? 0)"
//                                
//                                self.followingCountLabel.text = "\(success?.details!["following"] ?? 0)"
//                                self.trackCountLabel.text = "\(success?.details!["latest_songs"] ?? 0)"
                                
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
extension ArtistInfoVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return SuggestedSections.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = ArtistInfoSections(rawValue: section)!
        if isLoading {
            switch section {
            case .header:
                return 1
            case .latestsongs:
                return 1
            case .topsongs:
                return 1
            case .playlist:
                return 1
            case .store:
                return 1
            case .event:
                return 1
            }
        }
        else{
            
            switch section {
            case .header:
                return 1
            case .latestsongs:
                return 1
            case .topsongs:
                return 1
            case .playlist:
                return 1
            case .store:
                return 1
            case .event:
                return 1
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.isLoading {
            let type = ArtistInfoSections(rawValue: indexPath.section)!
            
            switch type {
                
            case .header:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoCell.identifier) as! ArtistInfoCell
                
                cell.startSkelting()
                
                return cell
            case .latestsongs:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as! ArtistInfoDetail
                cell.isloading = true
                cell.startSkelting()
                return cell
            case .topsongs:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as! ArtistInfoDetail
                cell.isloading = true
                cell.startSkelting()
                return cell
            case .playlist:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as! ArtistInfoDetail
                cell.isloading = true
                cell.startSkelting()
                return cell
            case .store:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as! ArtistInfoDetail
                cell.isloading = true
                cell.startSkelting()
                return cell
            case .event:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as! ArtistInfoDetail
                cell.startSkelting()
                return cell
            }
            
        }
        else
        {
            let type = ArtistInfoSections(rawValue: indexPath.section)!
            
            switch type {
                
            case .header:
                let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoCell.identifier) as? ArtistInfoCell
                cell?.stopSkelting()
                let url = URL.init(string:artistObject?.avatar ?? "")
                cell?.imgArtist.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
                cell?.lblName.text = artistObject?.name ?? artistObject?.username ?? ""
                cell?.lblDescription.text = artistObject?.aboutDecoded
                cell?.btnFollow.addTarget(self, action: #selector(followPressed(_:)), for: .touchUpInside)
                return cell!
            case .latestsongs:
               
                    let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as? ArtistInfoDetail
                    //  cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.stopSkelting()
                cell?.bind(latestSongArray, type: ArtistInfoSections.latestsongs ,isloading: self.isLoading)
                    return cell!
                
            
            case .topsongs:
              
                    let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as? ArtistInfoDetail
                    // cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(topSongArray, type: ArtistInfoSections.topsongs, isloading: self.isLoading)
                    cell?.stopSkelting()
                    return cell!
                
                
            case .playlist:
               
                    let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as? ArtistInfoDetail
                    cell?.selectionStyle = .none
                    //  cell?.vc = self
                    cell?.bind(storeSongsArray, type: ArtistInfoSections.playlist, isloading: self.isLoading)
                    cell?.stopSkelting()
                    return cell!
                
               
            case .store:
                
                    let cell = tableView.dequeueReusableCell(withIdentifier: ArtistInfoDetail.identifier) as? ArtistInfoDetail
                    cell?.selectionStyle = .none
                    //  cell?.vc = self
                    
                    cell?.bind(storeSongsArray, type: ArtistInfoSections.store,isloading: self.isLoading)
                    cell?.stopSkelting()
                    return cell!
              
            case .event:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableCell") as? EventTableCell
                cell?.selectionStyle = .none
                // cell?.vc1 = self
                // cell?.bind(EventlistArray)
                return cell!
                
            }
        }
    
}
    
    
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
      return UITableView.automaticDimension
     
  }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        let type = ArtistInfoSections(rawValue: section)!
            
        switch type {
            
        case .header:
            return 0
        case .latestsongs:
            if latestSongArray.count != 0{
                return 43
            }
            else {
                return 0
            }
        case .topsongs:
            if topSongArray.count != 0{
                return 43
            }
            else{
                return 0
            }
        case .playlist:
            if topSongArray.count != 0{
                return 43
            }
            else{
                return 0
            }
        case .store:
            if topSongArray.count != 0{
                return 43
            }
            else{
                return 0
            }
        case .event:
            if topSongArray.count != 0{
                return 43
            }
            else{
                return 0
            }
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if isLoading{
            let headerView = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as! SectionHeaderTableItem
            headerView.startSkelting()
            return headerView
        }
        else
        {
            let headerView = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as! SectionHeaderTableItem
            headerView.stopSkelting()
            let type = ArtistInfoSections(rawValue: section)!
            
            switch type {
                
            case .header:
                return nil
            case .latestsongs:
                if latestSongArray.count != 0{
                    headerView.titleLabel.text = "Latest Songs"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 1
                    headerView.btnSeeAll.isHidden = false
                    headerView.sepratorView.isHidden = true
                    return headerView
                }
                else {return nil}
            case .topsongs:
                if topSongArray.count != 0{
                    headerView.titleLabel.text = "Top Songs"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 1
                    headerView.btnSeeAll.isHidden = false
                    headerView.sepratorView.isHidden = true
                    return headerView
                }
                else {return nil}
            case .playlist:
                if topSongArray.count != 0{
                    headerView.titleLabel.text = "Playlist"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 1
                    headerView.btnSeeAll.isHidden = false
                    headerView.sepratorView.isHidden = true
                    return headerView
                }
                else {return nil}
            case .store:
                if topSongArray.count != 0{
                    headerView.titleLabel.text = "Store"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 1
                    headerView.btnSeeAll.isHidden = false
                    headerView.sepratorView.isHidden = true
                    return headerView
                }
                else {return nil}
            case .event:
                if topSongArray.count != 0{
                    headerView.titleLabel.text = "Events"
                    headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    headerView.btnSeeAll.tag = 1
                    headerView.btnSeeAll.isHidden = false
                    headerView.sepratorView.isHidden = true
                    return headerView
                }
                else {return nil}
            }
            
            
        }
    }
    
}

extension ArtistInfoVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Not Found", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Something goes worng please trry again.", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return resizeImage(image: UIImage(named: "EmptyData")!, targetSize:  CGSize(width: 200.0, height: 200.0))
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
