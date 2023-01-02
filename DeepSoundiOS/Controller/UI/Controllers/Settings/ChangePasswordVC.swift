//
//  ChangePasswordVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class ChangePasswordVC: BaseVC {

    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomTextLabel.text = NSLocalizedString("If you forget your password you can reset from here.", comment: "If you forget your password you can reset from here.")
        self.currentPasswordTextField.placeholder = NSLocalizedString("Current Password", comment: "Current Password")
        self.newPasswordTextField.placeholder = NSLocalizedString("New Password", comment: "New Password")
        self.repeatPasswordTextField.placeholder = NSLocalizedString("Repeat Password", comment: "Repeat Password")
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
    }
//    private  func setupUI(){
//        self.title = (NSLocalizedString("Change Password", comment: ""))
//        let Save = UIBarButtonItem(title: (NSLocalizedString("Save", comment: "")), style: .done, target: self, action: Selector(("Save")))
//        self.navigationItem.rightBarButtonItem = Save
//    }
    
    
    @IBAction func save(_ sender: Any) {
        
        print("Saved Pressed!!")
        updatePassword()
    }
    private func updatePassword(){
        if (self.currentPasswordTextField.text?.isEmpty)!{
            log.verbose("Please enter Current Password.")
            self.view.makeToast(NSLocalizedString(("Please enter Current Password."), comment: ""))
        }else if (newPasswordTextField.text?.isEmpty)!{
            log.verbose("Please enter New Password.")
            self.view.makeToast(NSLocalizedString(("Please enter New Password."), comment: ""))
        }else  if (repeatPasswordTextField.text?.isEmpty)!{
            log.verbose("Please enter Repeat Password.")
            self.view.makeToast(NSLocalizedString(("Please enter Repeat Password."), comment: ""))
        }else if (currentPasswordTextField.text?.isEmpty)! != (repeatPasswordTextField.text?.isEmpty)!{
            log.verbose("Password do not match.")
            self.view.makeToast(NSLocalizedString(("Password do not match."), comment: ""))
        }else{
            if Connectivity.isConnectedToNetwork(){
                
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
                let accessToken = AppInstance.instance.accessToken ?? ""
                let userId = AppInstance.instance.userId ?? 0
                let currentPassword = currentPasswordTextField.text ?? ""
                let newPassword = newPasswordTextField.text ?? ""
                let repeatPassword = self.repeatPasswordTextField.text ?? ""
                
                Async.background({
                    
                    ProfileManger.instance.changePasswrod(UserId: userId, AccessToken: accessToken, Current_Password: currentPassword, New_Password: newPassword, Repeat_Password: repeatPassword, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile()
                                }
                            })
                        }else if sessionError != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.view.makeToast(sessionError?.error ?? "")
                                }
                            })
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                }
                            })
                        }
                    })
                })
            }else{
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
        }
    }
}
