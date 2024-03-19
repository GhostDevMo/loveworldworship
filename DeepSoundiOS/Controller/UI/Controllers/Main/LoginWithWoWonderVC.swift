//
//  LoginWithWoWonderVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
import Toast_Swift

class LoginWithWoWonderVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Sign In Button Action
    @IBAction func signInButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.userNameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Error, Required Username")
            return
        }
        if self.passwordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Error, Required Password")
            return
        }
        self.loginAuthentication()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
    }
    
    func textFieldSetUp() {
        self.userNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white as Any]
        )
        self.passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white as Any]
        )
    }
    
    private func loginAuthentication () {
        self.showProgressDialog(text: "Loading...")
        let username = self.userNameTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        Async.background {
            UserManager.instance.loginWithWoWonder(userName: username, password: password) { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        log.verbose("Login Succesfull =\(success?.access_token ?? "")")
                        self.wowonderSignIn(userID: success?.user_id ?? "", accessToken: success?.access_token ?? "")
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose(sessionError?.errors?.error_text ?? "")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    }
                } else if error != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            print("error - \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func wowonderSignIn(userID: String, accessToken: String) {
        Async.background {
            WoWProfileManager.instance.WoWonderUserData(userId: userID, access_token: accessToken) { (success, sessionError, error) in
                if let success = success {
                    Async.main {
                        self.wowonder(accessToken: success)
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose(sessionError?.errors?.error_text ?? "")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    }
                } else if error != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            print("error - \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func wowonder(accessToken: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        Async.background {
            UserManager.instance.socialLogin(Provider: "wowonder", AccessToken: accessToken, DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.dismissProgressDialog{
                            log.verbose("Success = \(success?.accessToken ?? "")")
                            AppInstance.instance.isLoginUser = AppInstance.instance.getUserSession()
                            AppInstance.instance.fetchUserProfile(isNew: true) { isSuccess in
                                print(isSuccess)
                                if isSuccess {
                                    let vc = R.storyboard.dashboard.tabBarNav()
                                    self.appDelegate.window?.rootViewController = vc
                                }
                            }
                            self.view.makeToast(NSLocalizedString("Login Successfull!!", comment: ""))
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose("session Error = \(sessionError?.error ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                            securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                            securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
}

