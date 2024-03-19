//
//  ShowProfile2VC.swift
//  DeepSoundiOS
//
//  Created by iMac on 22/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import DeepSoundSDK
import JGProgressHUD
import DropDown
import Async
import MediaPlayer
import SDWebImage
import Toast_Swift

class ShowProfile2VC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var followBtnImage: UIImageView!
    
    // MARK: - Properties
    
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
        self.setupPageMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Selectors
    
    // Show Profile Button Action
    @IBAction func showProfileButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.settings.myInfoVC() {
            newVC.userData = self.userProfileModel
            newVC.detailsDic = self.details
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
            self.tabBarController?.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @IBAction func followBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let userId = self.userProfileModel?.id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        if !self.status {
            self.followUser(userId: userId)
        }else {
            self.unFollowUser(userId: userId)
        }
        self.status = !self.status
    }
    
    @IBAction func messageBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let object = self.userProfileModel
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.userData  = object
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func handleFollowersStackTapView(_ sender: UITapGestureRecognizer) {
        if let newVC = R.storyboard.settings.followersVC() {
            newVC.userID = AppInstance.instance.userId ?? 0
            self.tabBarController?.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @objc func handleFollowingStackTap(_ sender: UITapGestureRecognizer) {
        if let newVC = R.storyboard.settings.followingsVC() {
            newVC.userID = AppInstance.instance.userId ?? 0
            self.tabBarController?.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupTapGesture()
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
        let followersStackTap = UITapGestureRecognizer(target: self, action: #selector(self.handleFollowersStackTapView))
        self.followersStack.addGestureRecognizer(followersStackTap)
        
        let followingStackTap = UITapGestureRecognizer(target: self, action: #selector(self.handleFollowingStackTap))
        self.followingStack.addGestureRecognizer(followingStackTap)
    }
    
    // setup Pagemenu
    func setupPageMenu() {
        self.controllerArray.removeAll()
        self.songVC?.parentVC = self
        self.songVC?.isOtherUser = true
        self.songVC?.userID = self.userID
        self.controllerArray.append(self.songVC!)
        
        self.albumsVC?.parentVC = self
        self.albumsVC?.isOtherUser = true
        self.albumsVC?.userID = self.userID
        self.controllerArray.append(self.albumsVC!)
        
        self.profilePlaylistVC?.parentVC = self
        self.profilePlaylistVC?.isOtherUser = true
        self.profilePlaylistVC?.userID = self.userID
        self.controllerArray.append(self.profilePlaylistVC!)
        
        self.profileLikedVC?.parentVC = self
        self.profileLikedVC?.isOtherUser = true
        self.profileLikedVC?.userID = self.userID
        self.controllerArray.append(self.profileLikedVC!)
        
        self.activitiesVC?.parentVC = self
        self.activitiesVC?.isOtherUser = true
        self.activitiesVC?.userID = self.userID
        self.controllerArray.append(self.activitiesVC!)
        
        self.storeVC?.parentVC = self
        self.storeVC?.isOtherUser = true
        self.storeVC?.userID = self.userID
        self.controllerArray.append(self.storeVC!)
        
        self.stationsVC?.parentVC = self
        self.stationsVC?.isOtherUser = true
        self.stationsVC?.userID = self.userID
        self.controllerArray.append(self.stationsVC!)
        
        self.profileEventsVC?.parentVC = self
        self.profileEventsVC?.isOtherUser = true
        self.profileEventsVC?.userID = self.userID
        self.controllerArray.append(profileEventsVC!)
        
        let newVC = self.controllerArray[0]
        self.selectedViewController = newVC
        self.setViewControllers(oldVC: newVC, NewVC: newVC)
    }
}

// MARK: - Extensions

// MARK: API Call
extension ShowProfile2VC {
    
    private func fetchUserProfile(fetch: String = "all") {
        let userId = userID ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, fetch: fetch, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.userProfileModel = success?.data ?? nil
                            self.details = success?.details?.details
                            self.titleLabel.text = success?.data?.name?.capitalized
                            self.followingCountLabel.text = "\(success?.details?.details?.following ?? 0)"
                            self.followersCountLabel.text = "\(success?.details?.details?.followers ?? 0)"
                            let profileImage = success?.data?.avatar ?? ""
                            let coverImage = success?.data?.cover ?? ""
                            let profileImageURL = URL.init(string:profileImage)
                            let coverImageURL = URL.init(string:coverImage)
                            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
                            self.coverImage.sd_setImage(with: coverImageURL , placeholderImage:R.image.imagePlacholder())
                            self.status = success?.data?.is_following ?? false
                            if self.status {
                                self.followBtnImage.image = R.image.ic_action_check_mark()
                            }else {
                                self.followBtnImage.image = R.image.ic_add()
                            }
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
                            self.fetchUserProfile(fetch: "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,store,events")
                            log.error("error = \(error?.localizedDescription ?? "")")
                            // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
    
    func followUser(userId: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.followBtnImage.image = R.image.ic_action_check_mark()
                                self.view.makeToast(NSLocalizedString(("User has been Followed"), comment: ""))
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func unFollowUser(userId: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.followBtnImage.image = R.image.ic_add()
                                self.view.makeToast(NSLocalizedString(("User has been unfollowed"), comment: ""))
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: Warning Popup Delegate Methods
extension ShowProfile2VC: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton,_ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        } else if sender.tag == 1003 {
            let newVC = R.storyboard.settings.settingWalletVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
    
}

// MARK: Collection View Setup
extension ShowProfile2VC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
extension ShowProfile2VC: ProfilePopupVCDelegate {
    
    func handleChangeCoverImageTap(_ sender: UIButton) {
        
    }
    
    func handleSettingsTap(_ sender: UIButton) {
        
    }
    
    func handleCopyLinkToProfileTap(_ sender: UIButton) {
        
    }
    
}
