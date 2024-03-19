//
//  RegisterVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class RegisterVC: BaseVC {
    
    //MARK: - Properties -
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var passwordTextField: BorderedTextField!
    @IBOutlet weak var confirmPasswordTextField: BorderedTextField!
    @IBOutlet weak var usernameTextField: BorderedTextField!
    @IBOutlet weak var emailTextField: BorderedTextField!
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Selectors -
    @IBAction func backButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsOFServicePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let url = URL(string: ControlSettings.termsOfUse)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.registerPressed()
    }
    @IBAction func didTapSignin(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.login.loginVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

//MARK: - Helper Functions -
extension RegisterVC {
    private func setupUI() {
        self.emailTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.usernameTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.passwordTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.passwordTextField.updateRightImageTint(tintColor: .unselectedTextFieldTintColor)
        self.confirmPasswordTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.confirmPasswordTextField.updateRightImageTint(tintColor: .unselectedTextFieldTintColor)
        
        self.emailTextField.textField.delegate = self
        self.usernameTextField.textField.delegate = self
        self.passwordTextField.textField.delegate = self
        self.confirmPasswordTextField.textField.delegate = self
        self.emailTextField.textField.tag = 0
        self.usernameTextField.textField.tag = 1
        self.passwordTextField.textField.tag = 2
        self.confirmPasswordTextField.textField.tag = 3
        
        self.passwordTextField.textField.isSecureTextEntry = true
        self.confirmPasswordTextField.textField.isSecureTextEntry = true
        
        self.usernameTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        self.passwordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        self.emailTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        self.confirmPasswordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        
        passwordTextField.rightButtonHandler = { sender, imageView in
            self.passwordTextField.textField.isSecureTextEntry = !self.passwordTextField.textField.isSecureTextEntry
            let image = self.passwordTextField.textField.isSecureTextEntry ? "icn_eye_off" : "icn_eye_on"
            imageView.image = UIImage(named: image)
        }
        
        confirmPasswordTextField.rightButtonHandler = { sender, imageView in
            self.confirmPasswordTextField.textField.isSecureTextEntry = !self.confirmPasswordTextField.textField.isSecureTextEntry
            let image = self.confirmPasswordTextField.textField.isSecureTextEntry ? "icn_eye_off" : "icn_eye_on"
            imageView.image = UIImage(named: image)
        }
        
        self.signUpLabel.text = NSLocalizedString("Create Your Account", comment: "")
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        self.confirmPasswordTextField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        self.createAccount.setTitle(NSLocalizedString("Sign up", comment: ""), for: .normal)
        self.policyLabel.text = NSLocalizedString("BY REGISTERING YOU AGREE TO OUR ", comment: "")
    }
}

//MARK: - API Services -
extension RegisterVC {
    private func registerPressed() {
        if appDelegate.isInternetConnected {
            if (self.emailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (self.usernameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter email.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (self.passwordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (self.confirmPasswordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter confirm password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (self.passwordTextField.text != self.confirmPasswordTextField.text) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Password do not match.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if !((emailTextField.text?.isEmail)!) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Email is badly formatted.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "", message: NSLocalizedString("By registering you agree to our terms of service", comment: ""), preferredStyle: .alert)
                let okay = UIAlertAction(title: NSLocalizedString("OKAY", comment: ""), style: .default) { (action) in
                    self.registerPressedfunc()
                }
                let termsOfService = UIAlertAction(title: NSLocalizedString("TERMS OF SERVICE", comment: ""), style: .default) { (action) in
                    let url = URL(string: ControlSettings.termsOfUse)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                }
                let privacy = UIAlertAction(title: NSLocalizedString("PRIVACY", comment: ""), style: .default) { (action) in
                    let url = URL(string: ControlSettings.privacyPolicy)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                }
                alert.addAction(termsOfService)
                alert.addAction(privacy)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error ", comment: "")
                securityAlertVC?.errorText = NSLocalizedString(InterNetError , comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    private func registerPressedfunc() {
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
        let name = self.usernameTextField.text ?? ""
        let username = self.usernameTextField.text ?? ""
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.confirmPasswordTextField.text ?? ""
        let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
        Async.background({            
            UserManager.instance.registerUser(Name: name, Email: email, UserName: username, Password: password, ConfirmPassword: confirmPassword, DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.dismissProgressDialog{
                            if success?.waitValidation == 1{
                                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                securityAlertVC?.status = true
                                securityAlertVC?.titleText  = NSLocalizedString("Success", comment: "Success")
                                securityAlertVC?.errorText = NSLocalizedString("Please Verify your email" , comment: "Please Verify your email")
                                self.present(securityAlertVC!, animated: true, completion: nil)
                            }else{
                                log.verbose("Success = \(success?.accessToken ?? "")")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile(isNew: true) { isSuccess in
                                    let User_Session = [Local.USER_SESSION.Access_token:success?.accessToken as Any,Local.USER_SESSION.User_id:success?.data?.id as Any] as [String : Any]
                                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                                    UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                    let vc = R.storyboard.dashboard.tabBarNav()
                                    self.appDelegate.window?.rootViewController = vc
                                }
                                self.view.makeToast(NSLocalizedString("Login Successfull!!", comment: ""))
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose("session Error = \(sessionError?.error ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                            securityAlertVC?.errorText = NSLocalizedString(sessionError?.error ?? "", comment: "")
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                            securityAlertVC?.errorText = NSLocalizedString(error?.localizedDescription ?? "", comment: "")
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    })
                }
            })
        })
    }
}

//MARK: - TextField delegate Methods -
extension RegisterVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            emailTextField.backgroundColor = .selectedTextFieldBackGroundColor
            emailTextField.borderColorV = .ButtonColor
            emailTextField.updateLeftImageTint(tintColor: .ButtonColor)
        } else if textField.tag == 1 {
            usernameTextField.backgroundColor = .selectedTextFieldBackGroundColor
            usernameTextField.borderColorV = .ButtonColor
            usernameTextField.updateLeftImageTint(tintColor: .ButtonColor)
        } else if textField.tag == 2 {
            passwordTextField.backgroundColor = .selectedTextFieldBackGroundColor
            passwordTextField.borderColorV = .ButtonColor
            passwordTextField.updateLeftImageTint(tintColor: .ButtonColor)
            passwordTextField.updateRightImageTint(tintColor: .ButtonColor)
        } else if textField.tag == 3 {
            confirmPasswordTextField.backgroundColor = .selectedTextFieldBackGroundColor
            confirmPasswordTextField.borderColorV = .ButtonColor
            confirmPasswordTextField.updateLeftImageTint(tintColor: .ButtonColor)
            confirmPasswordTextField.updateRightImageTint(tintColor: .ButtonColor)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespaces).count == 0
        if textField.tag == 0 {
            self.emailTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            self.emailTextField.borderColorV = .clear
            self.emailTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        } else if textField.tag == 1 {
            usernameTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            usernameTextField.borderColorV = .clear
            usernameTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        } else if textField.tag == 2 {
            passwordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            passwordTextField.borderColorV = .clear
            passwordTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
            passwordTextField.updateRightImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        } else if textField.tag == 3 {
            confirmPasswordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            confirmPasswordTextField.borderColorV = .clear
            confirmPasswordTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
            confirmPasswordTextField.updateRightImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        }
    }
}

