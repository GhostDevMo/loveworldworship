import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import Async
import Toast_Swift
import SDWebImage
import GoogleSignIn

struct SettingsModel {
    let title: String?
    let image: UIImage?
}

class SettingsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var settingsArray: [SettingsModel] = []
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
//    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setUserData()
        self.tableViewSetup()
        self.setData()
    }
    
    // Table View Setup
    private func tableViewSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.settingsTableViewCell), forCellReuseIdentifier: R.reuseIdentifier.settingsTableViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.premiumSubcriptionCell), forCellReuseIdentifier: R.reuseIdentifier.premiumSubcriptionCell.identifier)
    }
    
    // Set Data
    private func setData() {
        self.settingsArray = [
            SettingsModel(title: "Edit Profile Info", image: R.image.icProfileDark()),
            SettingsModel(title: "My Account", image: R.image.icon_account_my()),
            SettingsModel(title: "Become an artist", image: R.image.shieldDone()),
            SettingsModel(title: "Notifications", image: R.image.icNotification()),
            SettingsModel(title: "Blocked Users", image: R.image.icBlockBs()),
            SettingsModel(title: "My Addresses", image: R.image.icon_address()),
            SettingsModel(title: "Withdrawals", image: R.image.icon_withdraw()),
            SettingsModel(title: "Wallet", image: R.image.icon_wallet()),
            SettingsModel(title: "My Affiliates", image: R.image.icon_affilliates()),
            SettingsModel(title: "Password", image: R.image.icon_password()),
            SettingsModel(title: "Two-factor authentication", image: R.image.icon_two_factor()),
            SettingsModel(title: "Manage Sessions", image: R.image.icon_manage_session()),
            SettingsModel(title: "Theme", image: UIImage(named: "Show")),
            SettingsModel(title: "Interest", image: R.image.category()),
            SettingsModel(title: "Rate our App", image: R.image.icon_rate()),
            SettingsModel(title: "Invite Friends", image: R.image.icon_invite_frds()),
            SettingsModel(title: "Term of use", image: R.image.shieldDone()),
            SettingsModel(title: "Help", image: UIImage(named: "DangerCircle")),
            SettingsModel(title: "Delete Acoount", image: R.image.icon_delete_ac()),
            SettingsModel(title: "Logout", image: R.image.icon_logout())
        ]
        if AppInstance.instance.userProfile?.data?.src != "" {
            let index = settingsArray.firstIndex(where: { $0.title == "Password" }) ?? 0
            settingsArray.remove(at: index)
        }
        self.tableView.reloadData()
    }
    
    // Set User Data
    func setUserData() {
        self.userNameLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.userEmailLabel.text = AppInstance.instance.userProfile?.data?.email ?? ""
        let profileImage = AppInstance.instance.userProfile?.data?.avatar ?? ""
        let profileImageURL = URL.init(string: profileImage)
        self.userImageView.sd_setImage(with: profileImageURL, placeholderImage: R.image.imagePlacholder())
    }
    
    private func logout() {
        let newVC = R.storyboard.popups.logoutPopupVC()
        newVC?.delegate = self
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        self.present(newVC!, animated: true)
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ControlSettings.isGoProEnabled && (AppInstance.instance.userProfile?.data?.is_pro ?? 0) == 0 {
            return self.settingsArray.count + 1
        } else {
            return self.settingsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ControlSettings.isGoProEnabled && (AppInstance.instance.userProfile?.data?.is_pro ?? 0) == 0 && indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.premiumSubcriptionCell.identifier, for: indexPath) as! PremiumSubcriptionCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
            let setting = ControlSettings.isGoProEnabled && (AppInstance.instance.userProfile?.data?.is_pro ?? 0) == 0 ? self.settingsArray[indexPath.row - 1] : self.settingsArray[indexPath.row]
            cell.settingImage.image = setting.image
            cell.titleLabel.text = setting.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if ControlSettings.isGoProEnabled && (AppInstance.instance.userProfile?.data?.is_pro ?? 0) == 0 && indexPath.row == 0 {
            if let newVC = R.storyboard.upgrade.upgradeProVC() {
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        } else {
            let setting = ControlSettings.isGoProEnabled && (AppInstance.instance.userProfile?.data?.is_pro ?? 0) == 0 ? self.settingsArray[indexPath.row - 1] : self.settingsArray[indexPath.row]
            switch setting.title {
            case "Edit Profile Info":
                if let newVC = R.storyboard.settings.editProfileVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "My Account":
                if let newVC = R.storyboard.settings.myAccountVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Become an artist":
                if let newVC = R.storyboard.settings.becomeAnArtistVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Notifications":
                if let newVC = R.storyboard.settings.settingNotificationVC() {
                    navigationController?.pushViewController(newVC, animated: true)
                }
            case "Blocked Users":
                if let newVC = R.storyboard.settings.blockUsersVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "My Addresses":
                if let newVC = R.storyboard.settings.myAddressesVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Withdrawals":
                if let newVC = R.storyboard.upgrade.widthdrawalsVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Wallet":
                if let newVC = R.storyboard.settings.settingWalletVC() {
                    navigationController?.pushViewController(newVC, animated: true)
                }
            case "My Affiliates":
                if let newVC = R.storyboard.settings.myAffliatesVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Password":
                if let newVC = R.storyboard.settings.changePasswordVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Two-factor authentication":
                if let newVC = R.storyboard.settings.settingsTwoFactorVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Manage Sessions":
                if let newVC = R.storyboard.settings.manageSessionsVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Theme":
                if let newVC = R.storyboard.popups.themePopupVC() {
                    self.present(newVC, animated: true, completion: nil)
                }
            case "Interest":
                if let newVC = R.storyboard.login.genresVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Rate our App":
                let appStoreID = 1111111111
                if let appStoreReviewURL = URL(string: "https://itunes.apple.com/app/id\(appStoreID)?mt=8&action=write-review") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appStoreReviewURL, options: [:], completionHandler: nil)
                    } else {
                        // Earlier versions
                        if UIApplication.shared.canOpenURL(appStoreReviewURL) {
                            UIApplication.shared.openURL(appStoreReviewURL)
                        }
                    }
                }
            case "Invite Friends":
                if let newVC = R.storyboard.settings.inviteFriendsVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Term of use":
                if let newVC = R.storyboard.settings.settingsWebViewVC() {
                    newVC.headerText = "Terms of use"
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Help":
                if let newVC = R.storyboard.settings.settingsWebViewVC() {
                    newVC.headerText = "Help"
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Delete Acoount":
                if let newVC = R.storyboard.settings.deleteAccountVC() {
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "Logout":
                self.logout()
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension SettingsVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

// MARK: LogoutPopupVCDelegate
extension SettingsVC: LogoutPopupVCDelegate {
    
    func handleLogoutButtonTap() {
        self.logoutUser()
    }
    
    private func logoutUser() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                UserManager.instance.LogoutUser(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                self.updateLogout()
                            }
                        })
                    } else if sessionError != nil {
                        Async.main{
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
    
    func updateLogout() {
        GIDSignIn.sharedInstance().signOut()
        UserDefaults.standard.removeValuefromUserdefault(Key: Local.USER_SESSION.User_Session)
        UserDefaults.standard.clearUserDefaults()
        AppInstance.instance.userProfile = nil
        AppInstance.instance.accessToken = nil
        AppInstance.instance.userId = nil
        let vc = R.storyboard.login.loginVC()
        appDelegate.window?.rootViewController = vc
    }
    
}
