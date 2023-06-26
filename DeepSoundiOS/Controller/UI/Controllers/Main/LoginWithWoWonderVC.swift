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

class LoginWithWoWonderVC: BaseVC {
    
    @IBOutlet weak var userNameField: BorderedTextField!
    @IBOutlet weak var passwordField: BorderedTextField!
    
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func SignIn(_ sender: Any) {
        
        if self.userNameField.text?.isEmpty == true {
            self.view.makeToast("Error, Required Username")
        }
        else if self.passwordField.text?.isEmpty == true {
            
            self.view.makeToast("Error, Required Password")
            
        }
        else {
            self.loginAuthentication()
        }
        
    }
    
    private func loginAuthentication () {
        self.showProgressDialog(text: "Loading...")
        let username = self.userNameField.text ?? ""
        let password = self.passwordField.text ?? ""
        
        Async.background({
            UserManager.instance.loginWithWoWonder(userName: username, password: password) { (success, sessionError, error) in
                if success != nil {
                    self.dismissProgressDialog {
                        log.verbose("Login Succesfull =\(success?.accessToken)")
                        self.WowonderSignIn(userID: success?.userID ?? "", accessToken: success?.accessToken ?? "")
                    }
                }
                else if sessionError != nil {
                    self.dismissProgressDialog {
                        self.error = sessionError?.errors.errorText ?? ""
                        log.verbose(sessionError?.errors.errorText ?? "")
                        self.view.makeToast(sessionError?.errors.errorText ?? "")
                    }
                }
                else if error != nil{
                    self.dismissProgressDialog {
                        print("error - \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        })
    }
    private func WowonderSignIn (userID:String, accessToken:String) {
        self.showProgressDialog(text: "Loading...")
        let username = self.userNameField.text ?? ""
        let password = self.passwordField.text ?? ""
        let deviceID = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? ""

        Async.background({
            WoWProfileManager.instance.WoWonderUserData(userId: userID, access_token: accessToken) { (success, sessionError, error) in
                if success != nil {
                    self.dismissProgressDialog {
                        log.verbose("Login Succesfull =\(success?.accessToken)")
                        log.verbose("Success = \(success?.accessToken ?? "")")
                        AppInstance.instance.getUserSession()
                        AppInstance.instance.fetchUserProfile()
                              let vc = R.storyboard.dashboard.dashBoardTabbar()
                                                                              vc?.modalPresentationStyle = .fullScreen
                                                                              self.present(vc!, animated: true, completion: nil)
                        self.view.makeToast("Login Successfull!!")
                    }
                }
                else if sessionError != nil {
                    self.dismissProgressDialog {
                        self.error = sessionError?.error ?? ""
                        log.verbose(sessionError?.error ?? "")
                        self.view.makeToast(sessionError?.error ?? "")
                    }
                }
                else if error != nil{
                    self.dismissProgressDialog {
                        print("error - \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        })
    }
    
}

