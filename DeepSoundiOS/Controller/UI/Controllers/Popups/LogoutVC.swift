//
//  LogoutVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 02/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class LogoutVC: BaseVC {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var warning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yesButton.setTitle((NSLocalizedString("YES", comment: "")), for: .normal)
        self.noButton.setTitle((NSLocalizedString("NO", comment: "")), for: .normal)
        self.descripLabel.text = (NSLocalizedString("Are you sure you want to log out?", comment: ""))
        self.warning.text = (NSLocalizedString("Warning", comment: ""))
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
    
    @IBAction func noPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func yesPressed(_ sender: Any) {
        logoutUser()
    }
    private func logoutUser(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            Async.background({
                UserManager.instance.LogoutUser(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
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
    @objc func update() {
        UserDefaults.standard.clearUserDefaults()
        let vc = R.storyboard.login.main()
        appDelegate.window?.rootViewController = vc
        self.dismiss(animated: true, completion: nil)
        
    }
}
