//
//  ForgetPasswordVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SkyFloatingLabelTextField
import Async
class ForgetPasswordVC: BaseVC {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: BorderedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendButton.backgroundColor = .ButtonColor
        self.sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        self.descriptionLabel.text = NSLocalizedString("Please enter your email address. We will send you a link to reset password. ", comment: "")
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.transparentNavigationBar()
    }
    

    @IBAction func sendPressed(_ sender: Any) {
        if self.emailTextField.text!.isEmpty{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Please enter email."
            self.present(securityAlertVC!, animated: true, completion: nil)

        }else if !self.emailTextField.text!.isEmail{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Email is badly formatted."
            self.present(securityAlertVC!, animated: true, completion: nil)
          
        }else{
            self.send()
        }
    }
    
    private func send(){
        self.showProgressDialog(text: "Loading...")
        let email = emailTextField.text ?? ""
        Async.background({
            UserManager.instance.ForgetPassword(Email: email, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.message ?? "")")
                             self.view.makeToast(success?.message ?? "")
                            
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
    }
}
