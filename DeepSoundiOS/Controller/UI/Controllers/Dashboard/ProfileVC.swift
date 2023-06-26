//
//  ProfileVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
//import Floaty
import DropDown
import Async
import Foundation
import AVFoundation
import MediaPlayer
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds

class ProfileVC: BaseVC {
    
    @IBOutlet weak var scrollViewShowImage: UIImageView!
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
    @IBOutlet weak var topSongLabel: UILabel!
    @IBOutlet weak var latestSongLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var topSongsCollectionView: UICollectionView!
    @IBOutlet weak var latestSongsCollectionView: UICollectionView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var profileImageView: UIView!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    
    private var floaty = Floaty()
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil
    private var latestSongArray = [ProfileModel.Latestsong]()
    private var topSongArray = [ProfileModel.Latestsong]()
    private var storeSongsArray = [ProfileModel.Latestsong]()
    private var activitiesArray = [ProfileModel.Activity]()
    private var latestMusicArray = [MusicPlayerModel]()
    private var topMusicArray = [MusicPlayerModel]()
    private var storeMusicArray = [MusicPlayerModel]()
    private var activitesMusicArray = [MusicPlayerModel]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.customizeDropdown()
        
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
    
    @IBAction func morePressed(_ sender: Any) {
        moreDropdown.show()
    }
    
    @IBAction func editProfilePressed(_ sender: Any) {
        let vc = R.storyboard.settings.editProfileVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func showInfoPressed(_ sender: Any) {
        let vc = R.storyboard.settings.myInfoVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func customizeDropdown(){
        moreDropdown.dataSource = [
            "Change cover image",
            "Settings",
            "copy Link To Profile"
        ]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.coverImageHandleTap()
            }else if index == 1{
                let vc = R.storyboard.settings.settingsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
            }
            print("Index = \(index)")
        }
    }
    private func setupUI(){
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
        self.storeShowLabel.isHidden = false
        self.activitiesShowLabel.isHidden = true
        self.scrollViewShowImage.isHidden = true
        self.scrollViewShowLabel.isHidden = true
        
        self.nameLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.usernameLabel.text = "@\(AppInstance.instance.userProfile?.data?.username ?? "")"
        self.followingCount.text = "\(AppInstance.instance.userProfile?.details!["following"] ?? 0)"
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.details!["followers"] ?? 0)"
        
        let profileImage = AppInstance.instance.userProfile?.data?.avatar ?? ""
        let coverImage = AppInstance.instance.userProfile?.data?.cover ?? ""
        let profileImageURL = URL.init(string:profileImage)
        let coverImageURL = URL.init(string:coverImage)
        self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
        self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.imagePlacholder())
        let img = R.image.ic_more()!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        moreBtn.setImage(img, for: .normal)
        moreBtn.tintColor = .white
        self.editBtn.cornerRadiusV = self.editBtn.frame.height / 2
        self.navigationController?.isNavigationBarHidden = false
        floaty.buttonColor = UIColor.mainColor
        floaty.itemImageColor = .white
        let uploadItem = FloatyItem()
        uploadItem.hasShadow = true
        uploadItem.buttonColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
        uploadItem.circleShadowColor = UIColor.black
        uploadItem.titleShadowColor = UIColor.black
        uploadItem.titleLabelPosition = .left
        uploadItem.title = "upload Single Song"
        uploadItem.iconImageView.image = R.image.ic_action_upload()
        uploadItem.handler = { item in
            let mediaPicker = MPMediaPickerController(mediaTypes: .music)
            mediaPicker.delegate = self
            mediaPicker.allowsPickingMultipleItems = false
            self.present(mediaPicker, animated: true, completion: nil)
            
        }
        
        floaty.addItem(item: uploadItem)
//        self.view.addSubview(floaty)
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.ProfileImageHandleTap(_:)))
        profileImageView.addGestureRecognizer(profileImageTap)
        
        let followersLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.followersLabelTap(_:)))
        followersLabel?.isUserInteractionEnabled = true
        followersLabel?.addGestureRecognizer(followersLabelTap)
        let followingLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.followingLabelTap(_:)))
        followingLabel?.isUserInteractionEnabled = true
        followingLabel?.addGestureRecognizer(followingLabelTap)
        
        
        self.aboutLabel.text = AppInstance.instance.userProfile?.data?.about ?? "Has not any info"
        tableView.separatorStyle = .none
        storeCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        topSongsCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        latestSongsCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        tableView.register(Activities_TableCell.nib, forCellReuseIdentifier: Activities_TableCell.identifier)
        
        self.latestSongArray = AppInstance.instance.userProfile?.data?.latestsongs ?? []
        self.topSongArray = AppInstance.instance.userProfile?.data?.topSongs ?? []
        self.storeSongsArray = AppInstance.instance.userProfile?.data?.store ?? []
        self.activitiesArray = AppInstance.instance.userProfile?.data?.activities ?? []
        
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
        
    }
    
    @objc func followersLabelTap(_ sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.followersVC()
        vc?.userID = AppInstance.instance.userId ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func followingLabelTap(_ sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.followingsVC()
        vc?.userID = AppInstance.instance.userId ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func coverImageHandleTap(){
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func ProfileImageHandleTap(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func uploadImage(status:Bool){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if status{
            if Connectivity.isConnectedToNetwork(){
                
                let coverImageData = self.coverImageVar?.jpegData(compressionQuality: 0.2)
                Async.background({
                    ProfileManger.instance.uploadCover(AccesToken: accessToken, cover_data: coverImageData, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.view.makeToast("Cover has been uploaded successfully..")
                                    AppInstance.instance.fetchUserProfile()
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
        }else{
            if Connectivity.isConnectedToNetwork(){
                
                let profileImageData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                Async.background({
                    ProfileManger.instance.uploadProfileImage(AccesToken: accessToken, profileImage_data: profileImageData, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.view.makeToast("Profile Image has been uploaded successfully..")
                                    AppInstance.instance.fetchUserProfile()
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
}
extension ProfileVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
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
        if collectionView == latestSongsCollectionView{
            
            let object = self.latestSongArray[indexPath.row]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
            
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
                let commentCount = it.countComment.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
               
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment.stringValue ?? ""
                
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
            let commentCount = object.countComment.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
           
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.latestMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
            
        }else if collectionView == topSongsCollectionView{
            
            let object = self.topSongArray[indexPath.row]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
            
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
                let commentCount = it.countComment.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
                
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment.stringValue ?? ""
                
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
            let commentCount = object.countComment.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            popupContentController!.popupItem.image = R.image.imagePlacholder()
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
           
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.topMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
            
        }else if collectionView == storeCollectionView{
            
            let object = self.storeSongsArray[indexPath.row]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
            
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
                let commentCount = it.countComment.intValue ?? 0
                let trackId = it.id ?? 0
                let isLiked = it.isLiked ?? false
                let isFavorited = it.isFavoriated ?? false
                let likecountString = it.countLikes?.stringValue ?? ""
                let favoriteCountString = it.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                let sharedCountString = it.countShares?.stringValue ?? ""
                let commentCountString = it.countComment.stringValue ?? ""
                
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
            let commentCount = object.countComment.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
            
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment.stringValue ?? ""
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            popupContentController!.popupItem.image = R.image.imagePlacholder()
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
           
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.storeMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
        }
    }
}
extension ProfileVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activitiesArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Activities_TableCell.identifier) as? Activities_TableCell
//        cell?.delegate = self
//        cell?.IndexPath = indexPath.row
        let object = self.activitiesArray[indexPath.row]
        let thumbnailURL = URL.init(string:object.trackData?.thumbnail ?? "")
        cell?.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        let profileURL = URL.init(string:object.trackData?.publisher?.avatar ?? "")
        cell?.profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
        cell?.nameLabel.text = object.trackData?.publisher?.name ?? ""
        cell?.activityTextLabel.text = "\(object.activityText?.htmlAttributedString ?? "")\(object.activityTimeFormatted ?? "")"
        cell?.actionTextLabel.text = object.trackData?.title?.htmlAttributedString ?? ""
        cell?.timeLabel.text = object.trackData?.duration ?? ""
        
        cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
        
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
            let commentCount = it.trackData?.countComment.intValue ?? 0
            let trackId = it.trackData?.id ?? 0
            let isLiked = it.trackData?.isLiked ?? false
            let isFavorited = it.trackData?.isFavoriated ?? false
            
            let likecountString = it.trackData?.countLikes?.stringValue ?? ""
            let favoriteCountString = it.trackData?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = it.trackData?.countViews?.stringValue ?? ""
            let sharedCountString = it.trackData?.countShares?.stringValue ?? ""
            let commentCountString = it.trackData?.countComment.stringValue ?? ""
            
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
        let commentCount = object.trackData?.countComment.intValue ?? 0
        let trackId = object.trackData?.id ?? 0
        let isLiked = object.trackData?.isLiked ?? false
        let isFavorited = object.trackData?.isFavoriated ?? false
        
        let likecountString = object.trackData?.countLikes?.stringValue ?? ""
        let favoriteCountString = object.trackData?.countFavorite?.stringValue ?? ""
        let recentlyPlayedCountString = object.trackData?.countViews?.stringValue ?? ""
        let sharedCountString = object.trackData?.countShares?.stringValue ?? ""
        let commentCountString = object.trackData?.countComment.stringValue ?? ""
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
        return 180.0
    }
    
    
}
extension ProfileVC:showToastStringForBlockUserDelegate{
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
ProfileVC:showReportScreenDelegate{
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
extension ProfileVC:showToastStringDelegate{
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
}

extension ProfileVC:MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do
        {
            try FileManager.default.removeItem(at: outputURL)
        }
        catch let error as NSError
        {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background({
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                
                if exportSession!.status == AVAssetExportSession.Status.completed
                {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                  Async.main({
                    self.uploadTrack(TrackData: data)
                  })
                }
            })
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    private func uploadTrack(TrackData:Data){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.filePath ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
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
extension  ProfileVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if imageStatus!{
            self.coverImage.image = image
            self.coverImageVar = image
            
        }else{
            self.profileImage.image = image
            self.avatarImage  = image
        }
        self.uploadImage(status: self.imageStatus!)
        self.dismiss(animated: true, completion: nil)
        
    }
}
