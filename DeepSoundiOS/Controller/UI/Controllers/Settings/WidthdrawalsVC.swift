//
//  WidthdrawalsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import  Async
class WidthdrawalsVC: BaseVC {
    
    @IBOutlet weak var amountShowLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    @IBOutlet weak var balanceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.sendCheck()
    }
    private func setupUI(){
        
        self.title = NSLocalizedString("Widthdrawals", comment: "Widthdrawals")
        
        self.balanceLabel.text = NSLocalizedString("MY BALANCE", comment: "MY BALANCE")
        self.amountTextField.placeholder = NSLocalizedString("Amount", comment: "Amount")
        self.emailTextField.placeholder = NSLocalizedString("PayPal E=mail", comment: "PayPal E=mail")
        self.amountShowLabel.text = AppInstance.instance.userProfile?.data?.balance ?? "0 $"
    }
    private func sendCheck(){
        if appDelegate.isInternetConnected{
            if (self.amountTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter amount."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.emailTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter email."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.emailTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter username."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if !((emailTextField.text?.isEmail)!){
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Email is badly formatted."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else{
                self.widthdraw()
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error "
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    private func widthdraw(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let email = self.emailTextField.text ?? ""
            let amount = Int(self.amountTextField.text ?? "") ?? 0
            Async.background({
                WidthdrawalManager.instance.Widthdraw(AccessToken: accessToken, amount: amount, email: email, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? "")")
                               
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}
