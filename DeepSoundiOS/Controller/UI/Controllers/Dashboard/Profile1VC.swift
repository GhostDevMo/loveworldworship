//
//  Profile1VC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DeepSoundSDK
import JGProgressHUD
import DropDown
import Async
//import Floaty
import MediaPlayer
class Profile1VC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleNavLabel: UINavigationItem!
    
    @IBOutlet weak var editProfile: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var follovers1: UILabel!
    
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil
    private let moreDropdown = DropDown()
    var userID:Int? = 0
    private var storeArray = [ProfileModel.Latestsong]()
    private var stationArray = [ProfileModel.Latestsong]()
    private var albumArray = [ProfileModel.AlbumElement]()
    private var likeArray = [ProfileModel.Latestsong]()
    private var songArray = [ProfileModel.Latestsong]()
    private var playlistArray = [ProfileModel.Playlist]()
    private var latestMusicArray = [MusicPlayerModel]()
    private var topMusicArray = [MusicPlayerModel]()
    private var storeMusicArray = [MusicPlayerModel]()
    private var activitesMusicArray = [MusicPlayerModel]()
    private var activitiesArray = [ProfileModel.Activity]()
    private var userProfileModel:ProfileModel.DataElement?
    private var details = [String:Int]()
    private var status:Bool? = false
    var hud : JGProgressHUD?
    private var floaty = Floaty()
    
    
    
   
    override func viewDidLoad() {
        
        self.setupUI()
       // self.fetchUserProfile()
        self.profileImage.borderColorV = .mainColor
        self.editProfileView.borderColorV = .mainColor
        self.titleNavLabel.title = (NSLocalizedString("Profile", comment: ""))
        super.viewDidLoad()
        self.customizeDropdown()
      //  self.showFloatButtons()
        self.titleLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.editProfile.text = (NSLocalizedString("EDIT PROFILE INFO", comment: ""))
        self.followers.text = (NSLocalizedString("Followers", comment: "Followers"))
        self.followingCountLabel.text =   "\(AppInstance.instance.userProfile?.details!["following"] ?? 0)"
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.details!["followers"] ?? 0)"
        let profileImage1 = AppInstance.instance.userProfile?.data?.avatar ?? ""
        let coverImage = AppInstance.instance.userProfile?.data?.cover ?? ""
        let profileImageURL = URL.init(string:profileImage1)
        let coverImageURL = URL.init(string:coverImage)
        self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.profile())
        self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.profilecover())
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.ProfileImageHandleTap(_:)))
        profileImage.addGestureRecognizer(profileImageTap)
        
        let editView = UITapGestureRecognizer(target: self, action: #selector(self.editView))
        editProfileView.addGestureRecognizer(editView)
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(self.followerView))
               followersStack.addGestureRecognizer(followerTap)
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(self.followingView))
                     followingStack.addGestureRecognizer(followingTap)
        
    }
   
    
    private func fetchUserProfile(){
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let userId = AppInstance.instance.userId ?? 0
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
//                                self.followImage.image = R.image.ic_tick()
//                                self.folllowLabel.text = (NSLocalizedString("FOLLOWING", comment: ""))
                            }else{
                                self.status = success?.data?.isFollowing
//                                self.followImage.image = R.image.ic_add()
//                                self.folllowLabel.text = (NSLocalizedString("FOLLOW", comment: ""))
                            }
                            
                            self.songArray = success?.data?.topSongs ?? []
                            self.albumArray = success?.data?.albums ?? []
                            self.storeArray = success?.data?.store ?? []
                            self.stationArray = success?.data?.stations ?? []
                            self.playlistArray = success?.data?.playlists ?? []
                            self.likeArray = success?.data?.liked ?? []
                            self.activitiesArray = success?.data?.activities ?? []
//                            self.reloadPagerTabStripView()
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
    
 
    
    @objc func ProfileImageHandleTap(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: "", message: (NSLocalizedString("Select Source", comment: "")), preferredStyle: .alert)
        let camera = UIAlertAction(title: (NSLocalizedString("Camera", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: (NSLocalizedString("Gallery", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    private func coverImageHandleTap(){
        let alert = UIAlertController(title: "", message: (NSLocalizedString("Select Source", comment: "")), preferredStyle: .alert)
        let camera = UIAlertAction(title: (NSLocalizedString("Camera", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: (NSLocalizedString("Gallery", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imageStatus = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func editView(_ sender: UITapGestureRecognizer? = nil) {
        let vc = R.storyboard.settings.editProfileVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func followerView(_ sender: UITapGestureRecognizer? = nil) {
        let vc = R.storyboard.settings.followersVC()
             vc?.userID = AppInstance.instance.userId ?? 0
             self.navigationController?.pushViewController(vc!, animated: true)
       }
    @objc func followingView(_ sender: UITapGestureRecognizer? = nil) {
           let vc = R.storyboard.settings.followingsVC()
                vc?.userID = AppInstance.instance.userId ?? 0
                self.navigationController?.pushViewController(vc!, animated: true)
       }
    
    @IBAction func showProfilePressed(_ sender: Any) {
        let vc = R.storyboard.settings.myInfoVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func morePressed(_ sender: Any) {
        self.moreDropdown.show()
    }
    
    private func setupUI(){
     
        let lineColor = UIColor.mainColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = lineColor
        settings.style.buttonBarItemFont =  R.font.urbanistMedium(size: 17)!
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
        AppInstance.instance.fetchUserProfile()
        AppInstance.instance.fetchLiked()
        AppInstance.instance.fetchMyPlaylist()
    }
//    private func showFloatButtons(){
//        let uploadItem = FloatyItem()
//        uploadItem.hasShadow = true
//        uploadItem.buttonColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
//        uploadItem.circleShadowColor = UIColor.black
//        uploadItem.titleShadowColor = UIColor.black
//        uploadItem.titleLabelPosition = .left
//        uploadItem.title = (NSLocalizedString("Upload Single Song", comment: ""))
//        uploadItem.iconImageView.image = R.image.ic_action_upload()
//        uploadItem.handler = { item in
//            let mediaPicker = MPMediaPickerController(mediaTypes: .music)
//            mediaPicker.delegate = self
//            mediaPicker.allowsPickingMultipleItems = false
//            self.present(mediaPicker, animated: true, completion: nil)
//
//        }
//        let uploadAlbum = FloatyItem()
//        uploadAlbum.hasShadow = true
//        uploadAlbum.buttonColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
//        uploadAlbum.circleShadowColor = UIColor.black
//        uploadAlbum.titleShadowColor = UIColor.black
//        uploadAlbum.titleLabelPosition = .left
//        uploadAlbum.title = (NSLocalizedString("Upload Album", comment: ""))
//        uploadAlbum.iconImageView.image = R.image.ic_action_upload()
//        uploadAlbum.handler = { item in
//
//            let vc = R.storyboard.album.uploadAlbumVC()
//                     self.navigationController?.pushViewController(vc!, animated: true)
//        }
//        let importItem = FloatyItem()
//        importItem.hasShadow = true
//        importItem.buttonColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
//        importItem.circleShadowColor = UIColor.black
//        importItem.titleShadowColor = UIColor.black
//        importItem.titleLabelPosition = .left
//        importItem.title = (NSLocalizedString("Import", comment: ""))
//        importItem.iconImageView.image = R.image.download()
//        importItem.handler = { item in
//            let vc = R.storyboard.track.importURLVC()
//            self.navigationController?.pushViewController(vc!, animated: true)
//        }
//        floaty.buttonColor = UIColor.ButtonColor
//        floaty.addItem(item: importItem)
//        floaty.addItem(item: uploadItem)
//        floaty.addItem(item: uploadAlbum)
//
//        self.view.addSubview(floaty)
//
//    }
    func customizeDropdown(){
        moreDropdown.dataSource = [
            (NSLocalizedString("Change cover image", comment: "")),
            (NSLocalizedString("Settings", comment: "")),
            (NSLocalizedString("Copy Profile Link", comment: ""))
        ]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.coverImageHandleTap()
                moreDropdown.hide()
            }else if index == 1{
                let vc = R.storyboard.settings.settingsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                moreDropdown.hide()
            }else{
            }
            print("Index = \(index)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
          self.tabBarController?.tabBar.isHidden = false
          navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
//        let activitiesVC = R.storyboard.dashboard.activitiesVC()
       
        let albumsVC = R.storyboard.dashboard.albumsVC()
      
        let profileLikedVC = R.storyboard.dashboard.profileLikedVC()
        
        
        let profilePlaylistVC = R.storyboard.dashboard.profilePlaylistVC()
        
        
//        let songVC = R.storyboard.dashboard.songVC()
       
        
//        let storeVC = R.storyboard.dashboard.storeVC()
        
        
//        let stationsVC = R.storyboard.dashboard.stationsVC()
        
        
        
        
//        return [songVC!,albumsVC!,profilePlaylistVC!,profileLikedVC!,activitiesVC!,storeVC!,stationsVC!]
        
        return [albumsVC!,profilePlaylistVC!,profileLikedVC!]
        
    }
    private func uploadImage(status:Bool){
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
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
                                    self.view.makeToast((NSLocalizedString("Cover has been uploaded successfully..", comment: "")))
                                    AppInstance.instance.fetchUserProfile()
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
                                    self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                }
                            })
                        }
                    })
                    
                })
            }else{
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(NSLocalizedString((InterNetError), comment: ""))
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
                                    self.view.makeToast(NSLocalizedString(("Profile Image has been uploaded successfully.."), comment: ""))
                                    AppInstance.instance.fetchUserProfile()
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
    
}
extension  Profile1VC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
extension Profile1VC:MPMediaPickerControllerDelegate{
    
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
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.filePath ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                vc?.songLink = success?.filePath ?? ""
                                self.navigationController?.pushViewController(vc!, animated: true)
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
}
