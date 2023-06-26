//
//  LoginVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Async
import FBSDKLoginKit
import GoogleSignIn
import DeepSoundSDK
import AuthenticationServices

class LoginVC: BaseVC {
    
    @IBOutlet weak var btnApple: ASAuthorizationAppleIDButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var wowonderBtn: UIButton!
    @IBOutlet weak var btnRememberMe: UIButton!
    @IBOutlet weak var usernameTextField: BorderedTextField!
    @IBOutlet weak var passwordTextField: BorderedTextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var FBSDKButton: FBButton!
    
    private var appdelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        log.verbose("Device Id = \(self.deviceID ?? "")")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func forgetPasswordPressed(_ sender: Any) {
        let vc = R.storyboard.login.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func registerPressed(_ sender: Any) {
        let vc = R.storyboard.login.registerVC()
        self.navigationController?.pushViewController(vc!, animated: true)
      
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        facebookLogin()
    }
    @IBAction func loginWithWowonderPressed(_ sender: Any) {
        let vc = R.storyboard.login.loginWithWoWonderVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func googlePressed(_ sender: Any) {
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        loginPressed()
        
    }
  @objc func loginWithApplePressed() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.performRequests()
        
    }
    
    
    private func setupUI(){
//        self.usernameTextField.selectedLineColor = .mainColor
//        self.passwordTextField.selectedLineColor = .mainColor
        
        self.signUpBtn.tintColor = .ButtonColor
        self.loginLabel.text = NSLocalizedString("Log in to Your Account", comment: "")
        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        self.registerButton.setTitle(NSLocalizedString("Sign up", comment: ""), for: .normal)
        self.passwordButton.setTitle(NSLocalizedString("Forget the Password?", comment: ""), for: .normal)
        self.signUpBtn.cornerRadiusV = self.signUpBtn.frame.height / 2
        self.passwordTextField.textField.isSecureTextEntry = true
        usernameTextField.textField.delegate = self
        passwordTextField.textField.delegate = self
        usernameTextField.updateLeftImageTint(tintColor: .lightGray)
        passwordTextField.updateLeftImageTint(tintColor: .lightGray)
        usernameTextField.textField.tag = 0
        passwordTextField.textField.tag = 1
        
        self.navigationController?.navigationBar.transparentNavigationBar()
        let username = UserDefaults.standard.getUserName(Key: "userName")
        let userpassword = UserDefaults.standard.getPassword(Key: "userPassword")
        
        if  username != "" && userpassword != "" {
            self.usernameTextField.text = username
            self.passwordTextField.text = userpassword
            self.btnRememberMe.isSelected = true
        }
        
        
    }
    @IBAction func didTapShowButton(_ sender: Any) {
        passwordTextField.textField.isSecureTextEntry = !passwordTextField.textField.isSecureTextEntry
        
    }
    @IBAction func didTapRememberMe(_ sender: UIButton) {
       
        sender.isSelected.toggle()
        
    }

    
    private func loginPressed(){
        if appDelegate.isInternetConnected{
            
            if (self.usernameTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (passwordTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else{
                
                self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
                let username = self.usernameTextField.text ?? ""
                let password = self.passwordTextField.text ?? ""
                let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? ""
                
                if self.btnRememberMe.isSelected {
                    UserDefaults.standard.setUserName(value: username, ForKey: "userName")
                    UserDefaults.standard.setPassword(value: password, ForKey: "userPassword")
                }
                Async.background({
                    UserManager.instance.authenticateUser(UserName: username, Password: password, DeviceId: deviceId, completionBlock: { (success,twoFactorSuccess, sessionError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    
                                    log.verbose(NSLocalizedString("Success = \(success?.accessToken ?? "")", comment: ""))
                                    AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile()
                                    UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                    UserDefaults.standard.setUserID(value: success?.data?.id ?? 0, ForKey: "userID")
                                    let vc = R.storyboard.dashboard.dashBoardTabbar()
                                    vc?.modalPresentationStyle = .fullScreen
                                    self.present(vc!, animated: true, completion: nil)
                                    self.view.makeToast(NSLocalizedString("Login Successfull!!", comment: ""))
                                }
                            }
                        }else if twoFactorSuccess != nil{
                            
                            let vc = R.storyboard.login.twoFactorVerifyVC()
                            vc?.userID = twoFactorSuccess?.userID ?? 0
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }else if sessionError != nil{
                            Async.main{
                                self.dismissProgressDialog {
                                    
                                    log.verbose("session Error = \(sessionError?.error ?? "")")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                                    securityAlertVC?.errorText = (NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            }
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.verbose("error = \(error?.localizedDescription ?? "")")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                                    securityAlertVC?.errorText = (NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            })
                        }
                    })
                })
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
        let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? ""
        Async.background({
            UserManager.instance.socialLogin(Provider: "google", AccessToken: accessToken , GoogleApiKey: ControlSettings.googleApiKey, DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.dismissProgressDialog{
                            log.verbose("Success = \(success?.accessToken ?? "")")
                            AppInstance.instance.getUserSession()
                            AppInstance.instance.fetchUserProfile()
                            let vc = R.storyboard.dashboard.dashBoardTabbar()
                            vc?.modalPresentationStyle = .fullScreen
                            self.present(vc!, animated: true, completion: nil)
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
                                        let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? ""
                                        Async.background({
                                            UserManager.instance.socialLogin(Provider: "facebook", AccessToken: accessToken ?? "", GoogleApiKey: "", DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
                                                if success != nil{
                                                    Async.main{
                                                        self.dismissProgressDialog{
                                                            log.verbose("Success = \(success?.accessToken ?? "")")
                                                            AppInstance.instance.getUserSession()
                                                            AppInstance.instance.fetchUserProfile()
                                                            let vc = R.storyboard.dashboard.dashBoardTabbar()
                                                            vc?.modalPresentationStyle = .fullScreen
                                                            self.present(vc!, animated: true, completion: nil)
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
                                            })
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
}

extension LoginVC:GIDSignInDelegate{
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            _ = user.userID ?? ""
            log.verbose("user auth = \(user.authentication.accessToken ?? "")")
            let accessToken = user.authentication.idToken ?? ""
            self.google(accessToken: accessToken)
            
        } else {
            log.error(error.localizedDescription)
            
        }
    }
}
extension LoginVC:ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
        let userIdentifier = appleIDCredential.authorizationCode
    let fullName = appleIDCredential.fullName
    let email = appleIDCredential.email
        let authorizationCode = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
        print("authorizationCode: \(authorizationCode)")
        //self.socialLogin(accesstoken: authorizationCode, provider: "apple", googleKey: "")
    
        
    print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
    }
}
extension LoginVC:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0{
            usernameTextField.borderColorV = .ButtonColor
            usernameTextField.updateLeftImageTint(tintColor: .ButtonColor)
        }
        else {
            passwordTextField.borderColorV = .ButtonColor
            passwordTextField.updateLeftImageTint(tintColor: .ButtonColor)
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0{
            usernameTextField.borderColorV = .lightGray
            usernameTextField.updateLeftImageTint(tintColor: .lightGray)
        }
        else {
            passwordTextField.borderColorV = .lightGray
            passwordTextField.updateLeftImageTint(tintColor: .lightGray)
        }
        
    }
}
