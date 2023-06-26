//
//  UserInfoVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class UserInfoVC: BaseVC {
    
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var scrollViewShowImage: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var scrollViewShowLabel: UILabel!
    @IBOutlet weak var activitiesShowLabel: UILabel!
    @IBOutlet weak var activitiesShowImage: UIImageView!
    @IBOutlet weak var storeShowLabel: UILabel!
    @IBOutlet weak var storeShowImage: UIImageView!
    @IBOutlet weak var topSongShowLabel: UILabel!
    @IBOutlet weak var topSongShowImage: UIImageView!
    @IBOutlet weak var latestSongShowLabel: UILabel!
    @IBOutlet weak var latestSongShowImage: UIImageView!
    @IBOutlet weak var activitiesLabel: UILabel!
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topSongLabel: UILabel!
    @IBOutlet weak var latestSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var topSongsCollectionView: UICollectionView!
    @IBOutlet weak var latestSongsCollectionView: UICollectionView!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    
    var artistObject:ArtistModel.Datum?
    var followersObject:FollowerModel.Datum?
    var followingObject:FollowingModel.Datum?
    var artistSearchObject:SearchModel.Artist?
    private var latestSongArray = [UserInfoModel.Latestsong]()
    private var topSongArray = [UserInfoModel.Latestsong]()
    private var storeSongsArray = [UserInfoModel.Latestsong]()
    private var activitiesArray = [UserInfoModel.Activity]()
    private var latestMusicArray = [MusicPlayerModel]()
    private var topMusicArray = [MusicPlayerModel]()
    private var storeMusicArray = [MusicPlayerModel]()
    private var activitesMusicArray = [MusicPlayerModel]()
    private var detailsDic = [String:Int]()
    private var followStatus:Bool? = false
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchUserInfo()
        self.scrollViewShowImage.tintColor = .mainColor
        self.latestSongShowImage.tintColor = .mainColor
        
        self.topSongShowImage.tintColor = .mainColor
        self.storeShowImage.tintColor = .mainColor
        self.activitiesShowImage.tintColor = .mainColor
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
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func morePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            
            
            if artistObject != nil{
                self.loggedInshoeMoreAlert(userID: artistObject?.id ?? 0, urlLink: artistObject?.url ?? "")
                
            }else if followersObject != nil{
                self.loggedInshoeMoreAlert(userID: followersObject?.id ?? 0, urlLink: followersObject?.url ?? "")
            }else if followingObject != nil {
                self.loggedInshoeMoreAlert(userID: followingObject?.id ?? 0, urlLink: followingObject?.url ?? "")
            }else if artistSearchObject != nil{
                self.loggedInshoeMoreAlert(userID: artistSearchObject?.id ?? 0, urlLink: artistSearchObject?.url ?? "")
            }
        }else{
            if artistObject != nil{
                
                self.notLoggedInAlert(urlLink: artistObject?.url ?? "")
                
            }else if followersObject != nil{
                self.notLoggedInAlert(urlLink: followersObject?.url ?? "")
                
            }else if followingObject != nil {
                self.notLoggedInAlert(urlLink: followingObject?.url ?? "")
                
            }else if artistSearchObject != nil{
                self.notLoggedInAlert(urlLink: artistSearchObject?.url ?? "")
                
            }
            
            
        }
        
    }
    @IBAction func showDetailPressed(_ sender: Any) {
        let vc = R.storyboard.discover.discoverShowInfoVC()
        if artistObject != nil{
            vc?.artistObject = artistObject ?? nil
        }else if followersObject != nil{
            vc?.followersObject = followersObject ?? nil
        }else if followingObject != nil {
            vc?.followingObject = followingObject ?? nil
        }else if artistSearchObject != nil{
            vc?.artistSearchObject = artistSearchObject ?? nil
        }
        vc?.details = self.detailsDic
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func followPressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            self.followStatus = !self.followStatus!
            if self.followStatus!{
                self.followBtn.setImage(R.image.ic_tick(), for: .normal)
                self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "FFA143")
                self.followUser()
                
            }else{
                self.followBtn.setImage(R.image.ic_add(), for: .normal)
                self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "444444")
                self.unFollowUser()
            }
        }else{
            self.loginAlert()
        }
        
        
    }
    
    private func setupUI(){
        if artistObject != nil{
            self.title = artistObject?.name ?? artistObject?.username ?? ""
        }else if followersObject != nil{
            self.title = followersObject?.name ?? followersObject?.username ?? ""
        }else if followingObject != nil {
            self.title = followingObject?.name ?? followingObject?.username ?? ""
        }else if artistSearchObject != nil{
            self.title = artistSearchObject?.name ?? artistSearchObject?.username ?? ""
        }
        
        //        self.scrollViewHeight.constant = 90
        self.topSongLabel.isHidden = true
        self.latestSongLabel.isHidden = true
        self.storeLabel.isHidden = true
        self.activitiesLabel.isHidden = true
        self.latestSongShowImage.isHidden = true
        self.topSongShowImage.isHidden = true
        self.storeShowImage.isHidden = true
        self.activitiesShowImage.isHidden = true
        self.latestSongShowLabel.isHidden = true
        self.topSongShowLabel.isHidden = true
        self.storeShowLabel.isHidden = true
        self.activitiesShowLabel.isHidden = true
        self.scrollViewShowImage.isHidden = true
        self.scrollViewShowLabel.isHidden = true
        if artistObject != nil{
            let profileURL = URL.init(string:artistObject?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            let coverURL = URL.init(string:artistObject?.cover ?? "")
            self.coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
        }else if followersObject != nil{
            let profileURL = URL.init(string:followersObject?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            let coverURL = URL.init(string:followersObject?.cover ?? "")
            self.coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            
        }else if followingObject != nil {
            let profileURL = URL.init(string:followingObject?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            let coverURL = URL.init(string:followingObject?.cover ?? "")
            self.coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            
        }else if artistSearchObject != nil{
            let profileURL = URL.init(string:artistSearchObject?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            let coverURL = URL.init(string:artistSearchObject?.cover ?? "")
            self.coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
        if artistObject != nil{
            self.aboutLabel.text = artistObject?.about ?? "Has not any info"
        }else if followersObject != nil{
            self.aboutLabel.text = followersObject?.about ?? "Has not any info"
        }else if followingObject != nil {
            self.aboutLabel.text = followingObject?.about ?? "Has not any info"
        }else if artistSearchObject != nil{
            self.aboutLabel.text = artistSearchObject?.about ?? "Has not any info"
        }
        
        
        tableView.separatorStyle = .none
        storeCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        topSongsCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        latestSongsCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        tableView.register(Activities_TableCell.nib, forCellReuseIdentifier: Activities_TableCell.identifier)
        let followersLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.followersStackTap(_:)))
        followerStack?.isUserInteractionEnabled = true
        followerStack?.addGestureRecognizer(followersLabelTap)
        let followingLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.followingStackTap(_:)))
        followingStack?.isUserInteractionEnabled = true
        followingStack?.addGestureRecognizer(followingLabelTap)
        
        
    }
    @objc func followersStackTap(_ sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.followersVC()
        if artistObject != nil{
            vc?.userID = artistObject?.id ?? 0
        }else if followersObject != nil{
            vc?.userID = followersObject?.id ?? 0
        }else if followingObject != nil {
            vc?.userID = followingObject?.id ?? 0
        }else if artistSearchObject != nil{
            vc?.userID = artistSearchObject?.id ?? 0
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func followingStackTap(_ sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.followingsVC()
        if artistObject != nil{
            vc?.userID = artistObject?.id ?? 0
        }else if followersObject != nil{
            vc?.userID = followersObject?.id ?? 0
        }else if followingObject != nil {
            vc?.userID = followingObject?.id ?? 0
        }else if artistSearchObject != nil{
            vc?.userID = artistSearchObject?.id ?? 0
        }
        self.navigationController?.pushViewController(vc!, animated: true)
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
            
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            var userIDSelectedFetch:Int? = 0
            if artistObject != nil{
                userIDSelectedFetch = artistObject?.id ??  0
            }else if followersObject != nil{
                userIDSelectedFetch = followersObject?.id ??  0
            }else if followingObject != nil {
                userIDSelectedFetch = followingObject?.id ??  0
                
            }else if artistSearchObject != nil{
                userIDSelectedFetch = artistSearchObject?.id ??  0
            }
            Async.background({
                UserInforManager.instance.getUserInfo(UserId: userIDSelectedFetch!, AccessToken: accessToken, Fetch_String: "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,activities,latest_songs,top_songs,store", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.followStatus = (success?.data?.isFollowing) ?? false
                                if (success?.data?.isFollowing) ?? false{
                                    self.followBtn.setImage(R.image.ic_tick(), for: .normal)
                                    self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "FFA143")
                                    
                                }else{
                                    self.followBtn.setImage(R.image.ic_add(), for: .normal)
                                    self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "444444")
                                }
                                self.latestSongArray = success?.data?.latestsongs ?? []
                                self.topSongArray = success?.data?.topSongs ?? []
                                self.storeSongsArray = success?.data?.store?[0] ?? []
                                self.activitiesArray = success?.data?.activities ?? []
                                
                                if self.latestSongArray.isEmpty{
                                    self.latestSongLabel.isHidden = false
                                    self.latestSongsCollectionView.isHidden = true
                                    self.latestSongShowLabel.isHidden = false
                                    self.latestSongShowImage.isHidden = false
                                }else{
                                    self.latestSongLabel.isHidden = false
                                    self.latestSongsCollectionView.isHidden = false
                                    self.latestSongShowLabel.isHidden = true
                                    self.latestSongShowImage.isHidden = true
                                    
                                }
                                if self.topSongArray.isEmpty{
                                    self.topSongLabel.isHidden = false
                                    self.topSongsCollectionView.isHidden = true
                                    self.topSongShowLabel.isHidden = false
                                    self.topSongShowImage.isHidden = false
                                    
                                }else{
                                    self.topSongLabel.isHidden = false
                                    self.topSongsCollectionView.isHidden = false
                                    self.topSongShowLabel.isHidden = true
                                    self.topSongShowImage.isHidden = true
                                }
                                if self.storeSongsArray.isEmpty{
                                    self.storeLabel.isHidden = false
                                    self.storeCollectionView.isHidden = true
                                    self.storeShowLabel.isHidden = false
                                    self.storeShowImage.isHidden = false
                                    
                                    
                                }else{
                                    self.storeLabel.isHidden = false
                                    self.storeCollectionView.isHidden = false
                                    self.storeShowLabel.isHidden = true
                                    self.storeShowImage.isHidden = true
                                    
                                }
                                if self.activitiesArray.isEmpty{
                                    self.activitiesLabel.isHidden = false
                                    self.tableView.isHidden = true
                                    self.activitiesShowLabel.isHidden = false
                                    self.activitiesShowImage.isHidden = false
                                }else{
                                    self.activitiesLabel.isHidden = false
                                    self.tableView.isHidden = false
                                    self.activitiesShowLabel.isHidden = true
                                    self.activitiesShowImage.isHidden = true
                                }
                                
                                if self.latestSongArray.isEmpty && self.topSongArray.isEmpty && self.storeSongsArray.isEmpty && self.activitiesArray.isEmpty{
                                    
                                    let height = self.latestSongsCollectionView.frame.height + self.topSongsCollectionView.frame.height + self.storeCollectionView.frame.height + self.tableView.frame.height
                                    
                                    self.activitiesShowLabel.isHidden = true
                                    self.activitiesShowImage.isHidden = true
                                    self.storeShowLabel.isHidden = true
                                    self.storeShowImage.isHidden = true
                                    self.topSongShowLabel.isHidden = true
                                    self.topSongShowImage.isHidden = true
                                    self.latestSongShowLabel.isHidden = true
                                    self.latestSongShowImage.isHidden = true
                                    
                                    self.activitiesLabel.isHidden = true
                                    self.topSongLabel.isHidden = true
                                    self.latestSongLabel.isHidden = true
                                    self.storeLabel.isHidden = true
                                    self.tableView.isHidden = true
                                    
                                    self.latestSongsCollectionView.isHidden = true
                                    self.topSongsCollectionView.isHidden = true
                                    self.storeCollectionView.isHidden = true
                                    
                                    self.scrollViewShowImage.isHidden = false
                                    self.scrollViewShowLabel.isHidden = false
                                    self.scrollViewHeight.constant = self.scrollViewHeight.constant - height
                                    
                                }
                                self.topSongsCollectionView.reloadData()
                                self.latestSongsCollectionView.reloadData()
                                self.storeCollectionView.reloadData()
                                self.tableView.reloadData()
                                self.detailsDic = success?.details ?? [:]
                                
                                self.followerCountLabel.text = "\(success?.details!["followers"] ?? 0)"
                                
                                self.followingCountLabel.text = "\(success?.details!["following"] ?? 0)"
                                self.trackCountLabel.text = "\(success?.details!["latest_songs"] ?? 0)"
                                
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
    
    func loginAlert(){
        let alert = UIAlertController(title: "Login", message: "Sorry you can not continue, you must log in and enjoy access to everything you want", preferredStyle: .alert)
        let yes = UIAlertAction(title: "YES", style: .default) { (action) in
            self.appDelegate.window?.rootViewController = R.storyboard.login.main()
        }
        let no = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    func loggedInshoeMoreAlert(userID:Int, urlLink:String){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let blockUser = UIAlertAction(title: "Block", style: .default) { (action) in
            self.blockUser(userID: userID)
        }
        let CopyLink = UIAlertAction(title: "Copy link to profile", style: .default) { (action) in
            UIPasteboard.general.string = urlLink ?? ""
            self.view.makeToast("Text copy to clipboad")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(blockUser)
        alert.addAction(CopyLink)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    func notLoggedInAlert( urlLink:String){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let CopyLink = UIAlertAction(title: "Copy Profile Link", style: .default) { (action) in
            UIPasteboard.general.string = urlLink ?? ""
            self.view.makeToast("Text copy to clipboad")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(CopyLink)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    private func blockUser(userID:Int){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                BlockUsersManager.instance.blockUser(Id: userID, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
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
    
}

extension UserInfoVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == latestSongsCollectionView{
            return (self.latestSongArray.count) ?? 0
        }else if collectionView == topSongsCollectionView{
            return (self.topSongArray.count) ?? 0
        }else{
            return (self.storeSongsArray.count) ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latestSongsCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            let object = self.latestSongArray[indexPath.row]
            cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
            cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music - \(object.countViews)"
            let url = URL.init(string:object.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else if collectionView == topSongsCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            let object = self.topSongArray[indexPath.row]
            cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
            cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music - \(object.countViews)"
            let url = URL.init(string:object.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            let object = self.topSongArray[indexPath.row]
            cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
            cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music"
            let url = URL.init(string:object.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        if collectionView == latestSongsCollectionView{
            
            let object = self.latestSongArray[indexPath.row]
            
            self.latestSongArray.forEach({ (it) in
                var audioString:String? = ""
                var isDemo:Bool? = false
                let name = it.publisher?.name ?? ""
                let time = it.timeFormatted ?? ""
                let title = it.title ?? ""
                let musicType = it.categoryName ?? ""
                let thumbnailImageString = it.thumbnail ?? ""
                if it.demoTrack == ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else if it.demoTrack != "" && it.audioLocation != ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = it.demoTrack ?? ""
                    isDemo = true
                }
                let isOwner = it.isOwner ?? false
                let audioId = it.audioID ?? ""
                let likeCount = it.countLikes?.intValue ?? 0
                let favoriteCount = it.countFavorite?.intValue ?? 0
                let recentlyPlayedCount = it.countViews?.intValue ?? 0
                let sharedCount = it.countShares?.intValue ?? 0
                let commentCount = it.countComment?.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment?.stringValue ?? ""
                
                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                self.latestMusicArray.append(musicObject)
            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object.publisher?.name ?? ""
            let time = object.timeFormatted ?? ""
            let title = object.title ?? ""
            let musicType = object.categoryName ?? ""
            let thumbnailImageString = object.thumbnail ?? ""
            if object.demoTrack == ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else if object.demoTrack != "" && object.audioLocation != ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object.isOwner ?? false
            let audioId = object.audioID ?? ""
            let likeCount = object.countLikes?.intValue ?? 0
            let favoriteCount = object.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object.countViews?.intValue ?? 0
            let sharedCount = object.countShares?.intValue ?? 0
            let commentCount = object.countComment?.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment?.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? DashboardNewRelease_CollectionCell
//                       popupContentController!.popupItem.image = cell?.thumbnailimage.image
                                 
                                 AppInstance.instance.popupPlayPauseSong = false
                       SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.latestMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
                
            })
            
            
        }else if collectionView == topSongsCollectionView{
            
            let object = self.topSongArray[indexPath.row]
            
            self.topSongArray.forEach({ (it) in
                var audioString:String? = ""
                var isDemo:Bool? = false
                
                let name = it.publisher?.name ?? ""
                let time = it.timeFormatted ?? ""
                let title = it.title ?? ""
                let musicType = it.categoryName ?? ""
                let thumbnailImageString = it.thumbnail ?? ""
                if it.demoTrack == ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else if it.demoTrack != "" && it.audioLocation != ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = it.demoTrack ?? ""
                    isDemo = true
                }
                let isOwner = it.isOwner ?? false
                let audioId = it.audioID ?? ""
                let likeCount = it.countLikes?.intValue ?? 0
                let favoriteCount = it.countFavorite?.intValue ?? 0
                let recentlyPlayedCount = it.countViews?.intValue ?? 0
                let sharedCount = it.countShares?.intValue ?? 0
                let commentCount = it.countComment?.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment?.stringValue ?? ""
                
                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                self.topMusicArray.append(musicObject)
            })
            
            var audioString:String? = ""
            var isDemo:Bool? = false
            
            let name = object.publisher?.name ?? ""
            let time = object.timeFormatted ?? ""
            let title = object.title ?? ""
            let musicType = object.categoryName ?? ""
            let thumbnailImageString = object.thumbnail ?? ""
            if object.demoTrack == ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else if object.demoTrack != "" && object.audioLocation != ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object.isOwner ?? false
            let audioId = object.audioID ?? ""
            let likeCount = object.countLikes?.intValue ?? 0
            let favoriteCount = object.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object.countViews?.intValue ?? 0
            let sharedCount = object.countShares?.intValue ?? 0
            let commentCount = object.countComment?.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment?.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? DashboardNewRelease_CollectionCell
                                 popupContentController!.popupItem.image = cell?.thumbnailimage.image
                                           
                                           AppInstance.instance.popupPlayPauseSong = false
                                 SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            
            
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.topMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                 self.popupContentController?.setup()
                
            })
            
            
        }else if collectionView == storeCollectionView{
            
            let object = self.storeSongsArray[indexPath.row]
            
            self.storeSongsArray.forEach({ (it) in
                var audioString:String? = ""
                var isDemo:Bool? = false
                let name = it.publisher?.name ?? ""
                let time = it.timeFormatted ?? ""
                let title = it.title ?? ""
                let musicType = it.categoryName ?? ""
                let thumbnailImageString = it.thumbnail ?? ""
                if it.demoTrack == ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else if it.demoTrack != "" && it.audioLocation != ""{
                    audioString = it.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = it.demoTrack ?? ""
                    isDemo = true
                }
                let isOwner = it.isOwner ?? false
                let audioId = it.audioID ?? ""
                let likeCount = it.countLikes?.intValue ?? 0
                let favoriteCount = it.countFavorite?.intValue ?? 0
                let recentlyPlayedCount = it.countViews?.intValue ?? 0
                let sharedCount = it.countShares?.intValue ?? 0
                let commentCount = it.countComment?.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment?.stringValue ?? ""
                
                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                self.storeMusicArray.append(musicObject)
            })
            
            
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object.publisher?.name ?? ""
            let time = object.timeFormatted ?? ""
            let title = object.title ?? ""
            let musicType = object.categoryName ?? ""
            let thumbnailImageString = object.thumbnail ?? ""
            if object.demoTrack == ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else if object.demoTrack != "" && object.audioLocation != ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object.isOwner ?? false
            let audioId = object.audioID ?? ""
            let likeCount = object.countLikes?.intValue ?? 0
            let favoriteCount = object.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object.countViews?.intValue ?? 0
            let sharedCount = object.countShares?.intValue ?? 0
            let commentCount = object.countComment?.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment?.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? DashboardNewRelease_CollectionCell
                                           popupContentController!.popupItem.image = cell?.thumbnailimage.image
                                                     
                                                     AppInstance.instance.popupPlayPauseSong = false
                                           SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object.id ?? 0)
           
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.storeMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                 self.popupContentController?.setup()
                
            })
        }
    }
}
extension UserInfoVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activitiesArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Activities_TableCell.identifier) as? Activities_TableCell
        //        cell?.delegate = self
        //        cell?.IndexPath = indexPath.row
        cell?.userInfoVC = self 
        let object = self.activitiesArray[indexPath.row]
        cell?.userInfoBind(object, index: indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.activitiesArray[indexPath.row]
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        self.activitiesArray.forEach({ (it) in
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = it.userData?.name ?? ""
            let time = it.trackData?.timeFormatted ?? ""
            let title = it.trackData?.title ?? ""
            let musicType = it.trackData?.categoryName ?? ""
            let thumbnailImageString = it.trackData?.thumbnail ?? ""
            if it.trackData?.demoTrack == ""{
                audioString = it.trackData?.audioLocation ?? ""
                isDemo = false
            }else if it.trackData?.demoTrack != "" && it.trackData?.audioLocation != ""{
                audioString = it.trackData?.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = it.trackData?.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = it.trackData?.isOwner ?? false
            let audioId = it.trackData?.audioID ?? ""
            let likeCount = it.trackData?.countLikes?.intValue ?? 0
            let favoriteCount = it.trackData?.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = it.trackData?.countViews?.intValue ?? 0
            let sharedCount = it.trackData?.countShares?.intValue ?? 0
            let commentCount = it.trackData?.countComment?.intValue ?? 0
            let trackId = it.trackData?.id ?? 0
            let isLiked = it.trackData?.isLiked ?? false
            let isFavorited = it.trackData?.isFavoriated ?? false
            
            let likecountString = it.trackData?.countLikes?.stringValue ?? ""
            let favoriteCountString = it.trackData?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = it.trackData?.countViews?.stringValue ?? ""
            let sharedCountString = it.trackData?.countShares?.stringValue ?? ""
            let commentCountString = it.trackData?.countComment?.stringValue ?? ""
            
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
            
            self.activitesMusicArray.append(musicObject)
        })
        var audioString:String? = ""
        var isDemo:Bool? = false
        let name = object.trackData?.title ?? ""
        let time = object.trackData?.timeFormatted ?? ""
        let title = object.trackData?.title ?? ""
        let musicType = object.trackData?.categoryName ?? ""
        let thumbnailImageString = object.trackData?.thumbnail ?? ""
        if object.trackData?.demoTrack == ""{
            audioString = object.trackData?.audioLocation ?? ""
            isDemo = false
        }else if object.trackData?.demoTrack != "" && object.trackData?.audioLocation != ""{
            audioString = object.trackData?.audioLocation ?? ""
            isDemo = false
        }else{
            audioString = object.trackData?.demoTrack ?? ""
            isDemo = true
        }
        let isOwner = object.trackData?.isOwner ?? false
        let audioId = object.trackData?.audioID ?? ""
        let likeCount = object.trackData?.countLikes?.intValue ?? 0
        let favoriteCount = object.trackData?.countFavorite?.intValue ?? 0
        let recentlyPlayedCount = object.trackData?.countViews?.intValue ?? 0
        let sharedCount = object.trackData?.countShares?.intValue ?? 0
        let commentCount = object.trackData?.countComment?.intValue ?? 0
        let trackId = object.trackData?.id ?? 0
        let isLiked = object.trackData?.isLiked ?? false
        let isFavorited = object.trackData?.isFavoriated ?? false
        
        let likecountString = object.trackData?.countLikes?.stringValue ?? ""
        let favoriteCountString = object.trackData?.countFavorite?.stringValue ?? ""
        let recentlyPlayedCountString = object.trackData?.countViews?.stringValue ?? ""
        let sharedCountString = object.trackData?.countShares?.stringValue ?? ""
        let commentCountString = object.trackData?.countComment?.stringValue ?? ""
        let duration = object.trackData?.duration ?? "0:0"
        let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
        popupContentController!.popupItem.title = object.userData?.name ?? ""
        popupContentController!.popupItem.subtitle = object.trackData?.title?.htmlAttributedString ?? ""
        self.addToRecentlyWatched(trackId: object.trackData?.id ?? 0)
        
        AppInstance.instance.popupPlayPauseSong = false
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = musicObject
            self.popupContentController!.musicArray = self.activitesMusicArray
            self.popupContentController!.currentAudioIndex = indexPath.row
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
extension UserInfoVC:showToastStringForBlockUserDelegate{
    func showToastStringForBlockUser(string: String, status: Bool) {
        if status{
            self.view.makeToast(string)
            self.navigationController?.popViewController(animated: true)
        }else{
            self.view.makeToast(string)
        }
    }
}
extension
UserInfoVC:showReportScreenDelegate{
    func showReportScreen(Status: Bool, IndexPath: Int, songLink: String) {
        if Status{
            let vc = R.storyboard.popups.reportVC()
            vc?.Id = self.activitiesArray[IndexPath].trackData?.id ?? 0
            vc?.songLink = self.activitiesArray[IndexPath].trackData?.audioLocation ?? ""
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
}
extension UserInfoVC:showToastStringDelegate{
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
}
