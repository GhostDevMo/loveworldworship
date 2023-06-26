//
//  TwoFactorVerifyVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/2/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import UIKit
import Async
import DeepSoundSDK
class TwoFactorVerifyVC: BaseVC {
    @IBOutlet weak var verifyCodeTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    var code:String? = ""
    var userID : Int? = 0
    var error = ""
    var password:String?  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLabel.text = NSLocalizedString("To log in, you need to verify  your identity.", comment: "To log in, you need to verify  your identity.")
        self.bottomLabel.text = NSLocalizedString("We have sent you the confirmation code to your email address.", comment: "We have sent you the confirmation code to your email address.")
        self.verifyCodeTextField.placeholder = NSLocalizedString("Add code number", comment: "Add code number")
        self.verifyBtn.setTitle(NSLocalizedString("VERIFY", comment: "VERIFY"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func verifyPressed(_ sender: Any) {
        if self.verifyCodeTextField.text!.isEmpty{
            self.view.makeToast("Please enter Code")
        }else{
            self.verifyTwoFactor()
        }
    }
    private func verifyTwoFactor(){
        
        if appDelegate.isInternetConnected{
            if (self.verifyCodeTextField.text!.isEmpty){
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter Code."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                self.showProgressDialog(text: "Loading...")
                let userID = self.userID ?? 0
                let code = self.verifyCodeTextField.text ?? ""
                
                Async.background({
                    UserManager.instance.verifyTwoFactor(userID: userID, code: code) { (success, sessionError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    log.verbose("Success = \(success?.accessToken)")
                                    log.verbose("Success = \(success?.accessToken ?? "")")
                                    AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile()
                                    UserDefaults.standard.setPassword(value: self.password ?? "", ForKey: Local.USER_SESSION.Current_Password)
                                    let vc = R.storyboard.dashboard.dashBoardTabbar()
                                    vc?.modalPresentationStyle = .fullScreen
                                    self.present(vc!, animated: true, completion: nil)
                                    self.view.makeToast("Login Successfull!!")
                                }
                            }
                        }else if sessionError != nil{
                            Async.main{
                                self.dismissProgressDialog {
                                    log.verbose("session Error = \(sessionError?.error ?? "")")
                                    
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = sessionError?.error ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                    
                                }
                            }
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.verbose("error = \(error?.localizedDescription)")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = error?.localizedDescription ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                    
                })
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
}
