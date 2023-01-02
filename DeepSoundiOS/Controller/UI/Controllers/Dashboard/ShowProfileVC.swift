//
//  ShowProfileVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.


import UIKit
import XLPagerTabStrip
import DeepSoundSDK
import JGProgressHUD
import DropDown
import Async
//import Floaty
import MediaPlayer
class ShowProfileVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var folllowLabel: UILabel!
    @IBOutlet weak var followImage: UIImageView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIBarButtonItem!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var followingButton: UILabel!
    @IBOutlet weak var followerButton: UILabel!
    private var  userProfileModel:ProfileModel.DataElement?
    private var details = [String:Int]()
    private var storeArray = [ProfileModel.Latestsong]()
    private var stationArray = [ProfileModel.Latestsong]()
    private var albumArray = [ProfileModel.AlbumElement]()
    private var likeArray = [LikedModel.Datum]()
    private var songArray = [ProfileModel.Latestsong]()
    private var playlistArray = [ProfileModel.Playlist]()
    private var latestMusicArray = [MusicPlayerModel]()
    private var topMusicArray = [MusicPlayerModel]()
    private var storeMusicArray = [MusicPlayerModel]()
    private var activitesMusicArray = [MusicPlayerModel]()
    private var activitiesArray = [ProfileModel.Activity]()
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil
    private let moreDropdown = DropDown()
    var userID:Int? = 0
    var profileUrl:String? = ""
    private var status:Bool? = false
    let appdelegate = UIApplication.shared.delegate as? AppDelegate
    var hud : JGProgressHUD?
    private var floaty = Floaty()
    
    override func viewDidLoad() {
        self.setupUI()
        self.messageView.borderColorV = .mainColor
        self.profileImage.borderColorV = .mainColor
        super.viewDidLoad()
        self.followView.backgroundColor = .mainColor
        self.followingButton.text = (NSLocalizedString(("Followers"), comment: ""))
        self.followingButton.text = (NSLocalizedString(("Followers"), comment: ""))
        self.fetchUserProfile()
        self.customizeDropdown()
        self.titleLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.followingCountLabel.text =   "\(AppInstance.instance.userProfile?.details!["following"] ?? 0) Followings"
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.details!["followers"] ?? 0) Followers"
        let profileImage1 = AppInstance.instance.userProfile?.data?.avatar ?? ""
        let coverImage = AppInstance.instance.userProfile?.data?.cover ?? ""
        let profileImageURL = URL.init(string:profileImage1)
        let coverImageURL = URL.init(string:coverImage)
        self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
        self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.imagePlacholder())
        
        
        let messageViewTap = UITapGestureRecognizer(target: self, action: #selector(self.messageViewTapped))
        
        messageView.addGestureRecognizer(messageViewTap)
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(self.followerView))
        followersStack.addGestureRecognizer(followerTap)
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(self.followingView))
        followingStack.addGestureRecognizer(followingTap)
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(self.followViewTapped))
        followView.addGestureRecognizer(followTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func messageViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        if AppInstance.instance.getUserSession(){
            let vc = R.storyboard.chat.chatScreenVC()
            vc?.toUserId  = userProfileModel?.id ?? 0
            vc?.usernameString = userProfileModel?.username ?? ""
            vc?.lastSeenString =  userProfileModel?.lastActive ?? 0
            vc?.profileImageString = userProfileModel?.avatar ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            self.loginAlert()
        }
        
    }
    @objc func followerView(_ sender: UITapGestureRecognizer? = nil) {
        let vc = R.storyboard.settings.followersVC()
        vc?.userID = self.userID ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func followingView(_ sender: UITapGestureRecognizer? = nil) {
        let vc = R.storyboard.settings.followingsVC()
        vc?.userID = self.userID ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func followViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        if AppInstance.instance.getUserSession(){
            self.status  = !self.status!
            if self.status!{
                followImage.image = R.image.ic_tick()
                self.folllowLabel.text  = (NSLocalizedString("FOLLOWING", comment: ""))
                self.followUser()
                
            }else{
                followImage.image = R.image.ic_add()
                self.folllowLabel.text = (NSLocalizedString("FOLLOW", comment: ""))
                self.unFollowUser()
            }
        }else{
            self.loginAlert()
        }
        
    }
    
    @IBAction func showProfilePressed(_ sender: Any) {
        let vc = R.storyboard.discover.discoverShowInfoVC()
        vc?.userProfileModel = self.userProfileModel ?? nil
        vc?.details = self.details
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func morePressed(_ sender: Any) {
        self.moreDropdown.show()
    }
    
    private func setupUI(){
        let lineColor = UIColor.mainColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = lineColor
        settings.style.buttonBarItemFont =  UIFont(name: "Poppins-Medium", size: 15)!
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor.hexStringToUIColor(hex: "FFFFFF")
        let newCellColor = UIColor.mainColor
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = newCellColor
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
        
    }
    func customizeDropdown(){
        moreDropdown.dataSource = [
            (NSLocalizedString("Block User", comment: "")),
            (NSLocalizedString("Copy profile link", comment: ""))
        ]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                if AppInstance.instance.getUserSession(){
                    self.blockUser()
                }else{
                    self.loginAlert()
                }
                
            }else{
                UIPasteboard.general.string = self.profileUrl ?? ""
                self.view.makeToast((NSLocalizedString("Text Copied to clipboard", comment: "")))
            }
        }
    }
    func loginAlert(){
        let alert = UIAlertController(title: (NSLocalizedString("Login", comment: "")), message: (NSLocalizedString("Sorry you can not continue, you must log in and enjoy access to everything you want", comment: "")), preferredStyle: .alert)
        let yes = UIAlertAction(title: (NSLocalizedString("YES", comment: "")), style: .default) { (action) in
            
            self.appdelegate!.window?.rootViewController = R.storyboard.login.main()
        }
        let no = UIAlertAction(title: (NSLocalizedString("NO", comment: "")), style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let activitiesVC = R.storyboard.dashboard.activitiesVC()
        
        
        let albumsVC = R.storyboard.dashboard.albumsVC()
        
        
        let profileLikedVC = R.storyboard.dashboard.profileLikedVC()
        
        
        let profilePlaylistVC = R.storyboard.dashboard.profilePlaylistVC()
        
        
        let songVC = R.storyboard.dashboard.songVC()
        
        
        let storeVC = R.storyboard.dashboard.storeVC()
        
        
        let stationsVC = R.storyboard.dashboard.stationsVC()
    
        
        
        
        return [activitiesVC!,albumsVC!,profileLikedVC!,profilePlaylistVC!,songVC!,storeVC!,stationsVC!]
        
    }
    
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        hud?.dismiss()
        completionBlock()
        
    }
    private func fetchUserProfile(){
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let userId = self.userID ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            ProfileManger.instance.getProfile(UserId: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.userProfileModel = success?.data ?? nil
                            self.details = success?.details ?? [:]
                            self.titleLabel.text = success?.data?.name ?? ""
                            self.followingCountLabel.text = "\(success?.details!["following"] ?? 0)"
                            self.followersCountLabel.text = "\(success?.details!["followers"] ?? 0)"
                            
                            let profileImage = success?.data?.avatar ?? ""
                            let coverImage = success?.data?.cover ?? ""
                            let profileImageURL = URL.init(string:profileImage)
                            let coverImageURL = URL.init(string:coverImage)
                            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
                            self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.imagePlacholder())
                            if (success?.data?.isFollowing)!{
                                self.status = success?.data?.isFollowing
                                self.followImage.image = R.image.ic_tick()
                                self.folllowLabel.text = (NSLocalizedString("FOLLOWING", comment: ""))
                            }else{
                                self.status = success?.data?.isFollowing
                                self.followImage.image = R.image.ic_add()
                                self.folllowLabel.text = (NSLocalizedString("FOLLOW", comment: ""))
                            }
                            
                            self.songArray = success?.data?.topSongs ?? []
                            self.albumArray = success?.data?.albums ?? []
                            self.storeArray = success?.data?.store ?? []
                            self.stationArray = success?.data?.stations ?? []
                            self.playlistArray = success?.data?.playlists ?? []
                            //self.likeArray = success?.data?.liked ?? []
                            self.activitiesArray = success?.data?.activities ?? []
                            self.reloadPagerTabStripView()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                        }
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    })
                }
            })
        })
        
    }
    private func blockUser(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                BlockUsersManager.instance.blockUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
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
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
    func followUser() {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString("You have successfully followed the user!", comment: ""))
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
    
    
    func unFollowUser() {
        if Connectivity.isConnectedToNetwork(){
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString("User has been unfollowed", comment: ""))
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString((sessionError?.error ?? ""), comment: ""))
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(NSLocalizedString((error?.localizedDescription ?? ""), comment: ""))
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(NSLocalizedString((InterNetError), comment: ""))
        }
    }
    
}


