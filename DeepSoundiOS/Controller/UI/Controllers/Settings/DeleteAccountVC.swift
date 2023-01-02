//
//  DeleteAccountVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class DeleteAccountVC: BaseVC {

    @IBOutlet weak var removeAcc: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    private var status:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.textLabel.text = NSLocalizedString("Yes, I want to delete username parmanently from DeepSound Account.", comment: "Yes, I want to delete username parmanently from DeepSound Account.")
        
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password")
        self.removeAcc.backgroundColor = .ButtonColor
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
   
    @IBAction func cechkBoxPressed(_ sender: Any) {
        self.status = !status!
        if status!{
            self.checkBoxBtn.setImage(R.image.ic_checked(), for: .normal)
        }else{
            self.checkBoxBtn.setImage(R.image.ic_checked(), for: .normal)
        }
    }
    
    @IBAction func removeAccountPressed(_ sender: Any) {
        deleteAccount()
    }
    private func setupUI(){
        self.title = (NSLocalizedString("Delete Account", comment: ""))
        self.textLabel.text = (NSLocalizedString("Yes, I want to delete \(AppInstance.instance.userProfile?.data?.username ?? "")permanently from DeepSound Account", comment: ""))
        self.removeAcc.setTitle((NSLocalizedString("REMOVE ACCOUNT", comment: "")), for: .normal)
    }
    private func deleteAccount(){
        if self.passwordTextField.text!.isEmpty{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = (NSLocalizedString("Warning", comment: ""))
            securityAlertVC?.errorText = (NSLocalizedString("Error.Please confirm your password.", comment: ""))
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else if status!{
            if self.passwordTextField.text!.isEmpty{
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = (NSLocalizedString("Warning", comment: ""))
                securityAlertVC?.errorText = (NSLocalizedString("Error.Please confirm your password.", comment: ""))
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                if Connectivity.isConnectedToNetwork(){
                    
                    self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
                    let accessToken = AppInstance.instance.accessToken ?? ""
                    let userId = AppInstance.instance.userId ?? 0
                    let password = self.passwordTextField.text ?? ""
                    Async.background({
                        
                        ProfileManger.instance.deleteAccount(UserId: userId, AccessToken: accessToken, Current_Password: password, completionBlock: { (success, sessionError, error) in
                            if success != nil{
                                Async.main({
                                    self.dismissProgressDialog {
                                        log.debug("success = \(success?.message ?? "")")
                                        self.view.makeToast(success?.message ?? "")
                                         let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
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
        }else{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = (NSLocalizedString("Warning", comment: ""))
            securityAlertVC?.errorText = (NSLocalizedString("You can not access your disapproval of the Terms and Conditions.", comment: ""))
            self.present(securityAlertVC!, animated: true, completion: nil)
            
        }
    }
    @objc func update() {
        UserDefaults.standard.clearUserDefaults()
        let vc = R.storyboard.login.main()
        appDelegate.window?.rootViewController = vc
    }
}
