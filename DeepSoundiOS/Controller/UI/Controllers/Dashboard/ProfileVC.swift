//
//  ProfileVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import JGProgressHUD
import DropDown
import Async
import MediaPlayer
import SDWebImage

class ProfileVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    
    private let imagePickerController = UIImagePickerController()
    private var imageStatus = false
    private var avatarImage: UIImage? = nil
    private var coverImageVar: UIImage? = nil
    var userID: Int? = 0
    private var userProfileModel: Publisher?
    private var details: Details?
    private var status: Bool = false
    var controllerArray: [UIViewController] = []
    var profileTabArray = ["Songs", "Albums", "PlayLists", "Liked", "Activities", "Store", "Stations", "Event"]
    var selectedIndex = 0
    let songVC = R.storyboard.dashboard.songVC()
    let albumsVC = R.storyboard.dashboard.albumsVC()
    let profilePlaylistVC = R.storyboard.dashboard.profilePlaylistVC()
    let profileLikedVC = R.storyboard.dashboard.profileLikedVC()
    let activitiesVC = R.storyboard.dashboard.activitiesVC()
    let storeVC = R.storyboard.dashboard.storeVC()
    let stationsVC = R.storyboard.dashboard.stationsVC()
    let profileEventsVC = R.storyboard.events.profileEventsVC()
    
    var selectedViewController: UIViewController?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
        self.fetchUserProfile()
        self.setupPageMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setData()
    }
    
    // MARK: - Selectors
    
    // Show Profile Button Action
    @IBAction func showProfileButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.settings.myInfoVC() {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    // More Button Action
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.profilePopupVC() {
            newVC.delegate = self
            self.tabBarController?.present(newVC, animated: true)
        }
    }
    
    @IBAction func settingButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.settings.settingsVC() {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @objc func handleProfileImageTap(_ sender: UITapGestureRecognizer) {
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
    
    @objc func handleEditProfileViewTap(_ sender: UITapGestureRecognizer) {
        if let newVC = R.storyboard.settings.editProfileVC() {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @objc func handleFollowersStackTapView(_ sender: UITapGestureRecognizer) {
        if let newVC = R.storyboard.settings.followersVC() {
            newVC.userID = AppInstance.instance.userId ?? 0
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @objc func handleFollowingStackTap(_ sender: UITapGestureRecognizer) {
        if let newVC = R.storyboard.settings.followingsVC() {
            newVC.userID = AppInstance.instance.userId ?? 0
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupTapGesture()
        // self.setData()
        self.collectionViewSetup()
        self.fetchUserProfile()
    }
    
    // CollectionView Setup
    func collectionViewSetup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.profileTabOptionCell), forCellWithReuseIdentifier: R.reuseIdentifier.profileTabOptionCell.identifier)
    }
    
    func setupTapGesture() {
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileImageTap))
        self.profileImage.addGestureRecognizer(profileImageTap)
        
        let editProfileViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleEditProfileViewTap))
        self.editProfileView.addGestureRecognizer(editProfileViewTap)
        
        let followersStackTap = UITapGestureRecognizer(target: self, action: #selector(self.handleFollowersStackTapView))
        self.followersStack.addGestureRecognizer(followersStackTap)
        
        let followingStackTap = UITapGestureRecognizer(target: self, action: #selector(self.handleFollowingStackTap))
        self.followingStack.addGestureRecognizer(followingStackTap)
    }
    
    func setData() {
        self.titleLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.followingCountLabel.text = "\(AppInstance.instance.userProfile?.details?.details?.following ?? 0)"
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.details?.details?.followers ?? 0)"
        let profileImageUrl = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        let coverImageUrl = URL(string: AppInstance.instance.userProfile?.data?.cover ?? "")
        self.profileImage.sd_setImage(with: profileImageUrl, placeholderImage: R.image.profile())
        self.coverImage.sd_setImage(with: coverImageUrl, placeholderImage: R.image.profilecover())
    }
    
    // setup Pagemenu
    func setupPageMenu() {
        self.controllerArray.removeAll()
        self.songVC?.parentVC = self
        self.controllerArray.append(self.songVC!)
        
        self.albumsVC?.parentVC = self
        self.controllerArray.append(self.albumsVC!)
        
        self.profilePlaylistVC?.parentVC = self
        self.controllerArray.append(self.profilePlaylistVC!)
        
        self.profileLikedVC?.parentVC = self
        self.controllerArray.append(self.profileLikedVC!)
        
        self.activitiesVC?.parentVC = self
        self.controllerArray.append(self.activitiesVC!)
        
        self.storeVC?.parentVC = self
        self.controllerArray.append(self.storeVC!)
        
        self.stationsVC?.parentVC = self
        self.controllerArray.append(self.stationsVC!)
        
        self.profileEventsVC?.parentVC = self
        self.controllerArray.append(profileEventsVC!)
        
        let newVC = self.controllerArray[0]
        self.selectedViewController = newVC
        self.setViewControllers(oldVC: newVC, NewVC: newVC)
    }
    
}

// MARK: - Extensions

// MARK: API Call
extension ProfileVC {
    
    private func fetchUserProfile() {
        let userId = AppInstance.instance.userId ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, fetch: "all", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.userProfileModel = success?.data ?? nil
                            self.details = success?.details?.details
                            self.titleLabel.text = success?.data?.name ?? ""
                            self.followingCountLabel.text = "\(success?.details?.details?.following ?? 0)"
                            self.followersCountLabel.text = "\(success?.details?.details?.followers ?? 0)"
                            let profileImage = success?.data?.avatar ?? ""
                            let coverImage = success?.data?.cover ?? ""
                            let profileImageURL = URL(string:profileImage)
                            let coverImageURL = URL(string:coverImage)
                            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
                            self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.imagePlacholder())
                            self.status = success?.data?.is_following ?? false
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
    
    private func uploadImage(status: Bool) {
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let accessToken = AppInstance.instance.accessToken ?? ""
        if status {
            if Connectivity.isConnectedToNetwork() {
                let coverImageData = self.coverImageVar?.jpegData(compressionQuality: 0.2)
                Async.background {
                    ProfileManger.instance.uploadCover(AccesToken: accessToken, cover_data: coverImageData, completionBlock: { (success, sessionError, error) in
                        if success != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.view.makeToast((NSLocalizedString("Cover has been uploaded successfully..", comment: "")))
                                    AppInstance.instance.fetchUserProfile { _ in }
                                }
                            }
                        } else if sessionError != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.view.makeToast(NSLocalizedString((sessionError?.error ?? ""), comment: ""))
                                }
                            }
                        } else {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                }
                            }
                        }
                    })
                }
            } else {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(NSLocalizedString((InterNetError), comment: ""))
            }
        } else {
            if Connectivity.isConnectedToNetwork() {
                let profileImageData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                Async.background {
                    ProfileManger.instance.uploadProfileImage(AccesToken: accessToken, profileImage_data: profileImageData, completionBlock: { (success, sessionError, error) in
                        if success != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.view.makeToast(NSLocalizedString(("Profile Image has been uploaded successfully.."), comment: ""))
                                    AppInstance.instance.fetchUserProfile { _ in }
                                }
                            }
                        } else if sessionError != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                }
                            }
                        } else {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                }
                            }
                        }
                    })
                }
            } else {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
            }
        }
    }
    
    private func uploadTrack(TrackData: Data) {
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.file_path ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                vc?.uploadTrackModel = success
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
    
}

// MARK: Collection View Setup
extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileTabArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profileTabOptionCell.identifier, for: indexPath) as! ProfileTabOptionCell
        cell.titleLabel.text = self.profileTabArray[indexPath.row]
        if self.selectedIndex == indexPath.row {
            cell.titleLabel.font = R.font.urbanistSemiBold(size: 18.0)
            cell.titleLabel.textColor = UIColor.mainColor
            cell.bottomBorder.backgroundColor = UIColor.mainColor
        } else {
            cell.titleLabel.font = R.font.urbanistMedium(size: 18.0)
            cell.titleLabel.textColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
            cell.bottomBorder.backgroundColor = .clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.collectionView.reloadData()
        let newVC = self.controllerArray[indexPath.row]
        self.setViewControllers(oldVC: self.selectedViewController!, NewVC: newVC)
        self.selectedViewController = newVC
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndex == indexPath.row {
            return CGSize(width: getWidthFromItem(title: self.profileTabArray[indexPath.row], font:R.font.urbanistSemiBold(size: 18.0) ?? UIFont()).width + 25, height: 48)
        } else {
            return CGSize(width: getWidthFromItem(title: self.profileTabArray[indexPath.row], font: R.font.urbanistMedium(size: 18.0) ?? UIFont()).width + 25, height: 48)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    // Get Width From String
    func getWidthFromItem(title: String, font: UIFont) -> CGSize {
        let itemSize = title.size(withAttributes: [
            NSAttributedString.Key.font: font
        ])
        return itemSize
    }
    
    func setViewControllers(oldVC: UIViewController, NewVC: UIViewController) {
        remove(asChildViewController: oldVC)
        add(asChildViewController: NewVC)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        self.containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        // viewController.view.bindFrameToSuperviewBounds() //gogole this extension if botton edge not fit
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
}

// MARK: ProfilePopupVCDelegate Methods
extension ProfileVC: ProfilePopupVCDelegate {
    
    func handleChangeCoverImageTap(_ sender: UIButton) {
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
    
    func handleSettingsTap(_ sender: UIButton) {
        if let newVC = R.storyboard.settings.settingsVC() {
            self.tabBarController?.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func handleCopyLinkToProfileTap(_ sender: UIButton) {
        self.view.endEditing(true)
        UIPasteboard.general.string = AppInstance.instance.userProfile?.data?.url
        self.view.makeToast("Link Copied Successfully!")
    }
    
}

// MARK: UIImagePickerControllerDelegate Methods
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if self.imageStatus {
            self.coverImage.image = image
            self.coverImageVar = image
        } else {
            self.profileImage.image = image
            self.avatarImage  = image
        }
        self.uploadImage(status: self.imageStatus)
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: MPMediaPickerControllerDelegate Methods
extension ProfileVC: MPMediaPickerControllerDelegate {
    
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
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background {
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                if exportSession!.status == AVAssetExportSession.Status.completed {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                    Async.main {
                        self.uploadTrack(TrackData: data)
                    }
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
}
