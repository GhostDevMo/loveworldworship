//
//  LoginVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import FBSDKLoginKit
import GoogleSignIn
import DeepSoundSDK
import AuthenticationServices

class LoginVC: BaseVC {
    //MARK: - Properties -
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var wowonderBtn: UIButton!
    @IBOutlet weak var btnRememberMe: UIButton!
    @IBOutlet weak var usernameTextField: BorderedTextField!
    @IBOutlet weak var passwordTextField: BorderedTextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var FBSDKButton: UIButton!
    
    private var appdelegate = UIApplication.shared.delegate as? AppDelegate
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        log.verbose("Device Id = \(self.deviceID ?? "")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Selectors -
    @IBAction func backButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgetPasswordPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.login.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.login.registerVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func facebookPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        facebookLogin()
    }
    
    @IBAction func loginWithWowonderPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.login.loginWithWoWonderVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func googlePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        loginPressed()
    }
    
    @IBAction func loginWithApplePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    @IBAction func didTapRememberMe(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected.toggle()
    }
}

//MARK: - Helper Functions -
extension LoginVC {
    private func setupUI() {
        self.signInBtn.tintColor = .ButtonColor
        self.loginLabel.text = NSLocalizedString("Log in to Your Account", comment: "")
        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        self.signUpButton.setTitle(NSLocalizedString("Sign up", comment: ""), for: .normal)
        self.passwordButton.setTitle(NSLocalizedString("Forget the Password?", comment: ""), for: .normal)
        self.signInBtn.cornerRadiusV = self.signInBtn.frame.height / 2
        self.passwordTextField.textField.isSecureTextEntry = true
        self.usernameTextField.textField.delegate = self
        self.passwordTextField.textField.delegate = self
        self.usernameTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.passwordTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.passwordTextField.updateRightImageTint(tintColor: .unselectedTextFieldTintColor)
        self.usernameTextField.textField.tag = 0
        self.passwordTextField.textField.tag = 1
        self.usernameTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        passwordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        passwordTextField.rightButtonHandler = { sender, imageView in
            self.passwordTextField.textField.isSecureTextEntry = !self.passwordTextField.textField.isSecureTextEntry
            let image = self.passwordTextField.textField.isSecureTextEntry ? "icn_eye_off" : "icn_eye_on"
            imageView.image = UIImage(named: image)
        }
        let username = UserDefaults.standard.getUserName(Key: "userName")
        let userpassword = UserDefaults.standard.getPassword(Key: "userPassword")
        if  username != "" && userpassword != "" {
            self.usernameTextField.text = username
            self.passwordTextField.text = userpassword
            self.btnRememberMe.isSelected = true
        }
        if ControlSettings.hideGoogleLogin {
            self.googleBtn.isHidden = true
        }else{
            self.googleBtn.isHidden = false
        }
        if ControlSettings.hideFacebookLogin {
            self.FBSDKButton.isHidden = true
        } else {
            self.FBSDKButton.isHidden = false
        }
        if ControlSettings.hideWoWonderLogin {
            self.wowonderBtn.isHidden = true
        }else {
            self.wowonderBtn.isHidden = false
        }
    }
    
    private func loginPressed(){
        if appDelegate.isInternetConnected {
            if (self.usernameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else if (passwordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0) {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else {
                self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
                let username = self.usernameTextField.text ?? ""
                let password = self.passwordTextField.text ?? ""
                let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
                if self.btnRememberMe.isSelected {
                    UserDefaults.standard.setUserName(value: username, ForKey: "userName")
                    UserDefaults.standard.setPassword(value: password, ForKey: "userPassword")
                }
                Async.background {
                    UserManager.instance.authenticateUser(UserName: username, Password: password, DeviceId: deviceId) { (success,twoFactorSuccess, sessionError, error) in
                        if success != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.verbose(NSLocalizedString("Success = \(success?.accessToken ?? "")", comment: ""))
                                    AppInstance.instance.isLoginUser = AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile(isNew: true) { isSuccess in
                                        print(isSuccess)
                                        if isSuccess {
                                            UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                            let vc = R.storyboard.dashboard.tabBarNav()
                                            self.appDelegate.window?.rootViewController = vc
                                        }
                                    }
                                    self.view.makeToast(NSLocalizedString("Login Successfull!!", comment: ""))
                                }
                            }
                        }else if twoFactorSuccess != nil {
                            let vc = R.storyboard.login.twoFactorVerifyVC()
                            vc?.userID = twoFactorSuccess?.userID ?? 0
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }else if sessionError != nil {
                            Async.main{
                                self.dismissProgressDialog {
                                    log.verbose("session Error = \(sessionError?.error ?? "")")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                                    securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            }
                        } else {
                            Async.main{
                                self.dismissProgressDialog {
                                    log.verbose("error = \(error?.localizedDescription ?? "")")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                                    securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "")
                securityAlertVC?.errorText = (NSLocalizedString(InterNetError, comment: ""))
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    private func google(accessToken:String){
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        Async.background({
            UserManager.instance.socialLogin(Provider: "google", AccessToken: accessToken, DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
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
                }else if sessionError != nil{
                    Async.main{
                        self.dismissProgressDialog {
                            log.verbose("session Error = \(sessionError?.error ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                            securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                            securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    })
                }
            })
        })
    }
    
    private func facebookLogin(){
        if Connectivity.isConnectedToNetwork(){
            let fbLoginManager : LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
                if (error == nil){
                    self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
                    let fbloginresult : LoginManagerLoginResult = result!
                    if (result?.isCancelled)!{
                        self.dismissProgressDialog{
                            log.verbose("result.isCancelled = \(result?.isCancelled ?? false)")
                        }
                        return
                    }
                    if fbloginresult.grantedPermissions != nil {
                        if(fbloginresult.grantedPermissions.contains("email")) {
                            if((AccessToken.current) != nil){
                                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completion: { (connection, result, error) -> Void in
                                    if (error == nil){
                                        let dict = result as! [String : AnyObject]
                                        log.debug("result = \(dict)")
                                        guard (dict["first_name"] as? String) != nil else {return}
                                        guard (dict["last_name"] as? String) != nil else {return}
                                        guard (dict["email"] as? String) != nil else {return}
                                        let accessToken = AccessToken.current?.tokenString
                                        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
                                        Async.background({
                                            UserManager.instance.socialLogin(Provider: "facebook", AccessToken: accessToken ?? "", DeviceId: deviceId) { (success, sessionError, error) in
                                                if success != nil{
                                                    Async.main{
                                                        self.dismissProgressDialog{
                                                            log.verbose("Success = \(success?.accessToken ?? "")")
                                                            AppInstance.instance.getUserSession()
                                                            AppInstance.instance.fetchUserProfile(isNew: true) { isSuccess in
                                                                print(isSuccess)
                                                                if isSuccess {
                                                                    let vc = R.storyboard.dashboard.tabBarNav()
                                                                    self.appDelegate.window?.rootViewController = vc
                                                                }
                                                            }
                                                            self.view.makeToast((NSLocalizedString("Login Successfull!!", comment: "")))
                                                        }
                                                    }
                                                }else if sessionError != nil{
                                                    Async.main{
                                                        self.dismissProgressDialog {
                                                            log.verbose("session Error = \(sessionError?.error ?? "")")
                                                            
                                                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                                                            securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                                            self.present(securityAlertVC!, animated: true, completion: nil)
                                                            
                                                        }
                                                    }
                                                }else {
                                                    Async.main({
                                                        self.dismissProgressDialog {
                                                            log.verbose("error = \(error?.localizedDescription ?? "")")
                                                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                                            securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                                                            securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                                            self.present(securityAlertVC!, animated: true, completion: nil)
                                                        }
                                                    })
                                                }
                                            }
                                        })
                                        log.verbose("FBSDKAccessToken.current() = \(AccessToken.current?.tokenString ?? "")")
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = (NSLocalizedString("Internet Error", comment: ""))
                securityAlertVC?.errorText = (NSLocalizedString(InterNetError, comment: ""))
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    // MARK: Apple Login
    func appleLogin(access_Token: String) {
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        if Connectivity.isConnectedToNetwork() {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
            Async.background {
                UserManager.instance.applelogin(Provider: "apple", AccessToken: access_Token, DeviceID: deviceId) { (success, sessionError, error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog{
                                log.verbose("Success = \(success?.accessToken ?? "")")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile(isNew: true) { (success) in
                                    if success {
                                        let vc = R.storyboard.dashboard.tabBarNav()
                                        self.appDelegate.window?.rootViewController = vc
                                    } else {
                                        print(false)
                                    }
                                }
                                self.view.makeToast((NSLocalizedString("Login Successfull!!", comment: "")))
                            }
                        }
                    }else if sessionError != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                log.verbose("session Error = \(sessionError?.error ?? "")")
                                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                                securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                self.present(securityAlertVC!, animated: true, completion: nil)                                
                            }
                        }
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("error = \(error?.localizedDescription ?? "")")
                                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                securityAlertVC?.titleText  = (NSLocalizedString("Security", comment: ""))
                                securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                self.present(securityAlertVC!, animated: true, completion: nil)
                            }
                        })
                    }
                }
            }
        } else {
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "Internet Error")
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
}

extension LoginVC: GIDSignInDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            log.verbose("user auth = \(user.authentication.accessToken ?? "")")
            let accessToken = user.authentication.idToken ?? ""
            self.google(accessToken: accessToken)
        } else {
            log.error(error.localizedDescription)
        }
    }
}

//MARK: - Apple Login Setup -
extension LoginVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(authorization.credential)
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.authorizationCode
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let authorizationCode = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
            print("authorizationCode: \(authorizationCode)")
            self.appleLogin(access_Token: authorizationCode)
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension LoginVC:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0{
            usernameTextField.backgroundColor = .selectedTextFieldBackGroundColor
            usernameTextField.borderColorV = .ButtonColor
            usernameTextField.updateLeftImageTint(tintColor: .ButtonColor)
        } else {
            passwordTextField.backgroundColor = .selectedTextFieldBackGroundColor
            passwordTextField.borderColorV = .ButtonColor
            passwordTextField.updateLeftImageTint(tintColor: .ButtonColor)
            passwordTextField.updateRightImageTint(tintColor: .ButtonColor)
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespaces).count == 0
        if textField.tag == 0 {
            usernameTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            usernameTextField.borderColorV = .clear
            usernameTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        } else {
            passwordTextField.backgroundColor = .unselectedTextFieldBackGroundColor
            passwordTextField.borderColorV = .clear
            passwordTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
            passwordTextField.updateRightImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
        }        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
