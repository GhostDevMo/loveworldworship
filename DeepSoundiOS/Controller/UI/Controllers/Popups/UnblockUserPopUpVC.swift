//
//  UnblockUserPopUpVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 01/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class UnblockUserPopUpVC: BaseVC {
    
    var id:Int? = 0

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var warning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yesButton.setTitle((NSLocalizedString("YES", comment: "")), for: .normal)
        self.noButton.setTitle((NSLocalizedString("NO", comment: "")), for: .normal)
        self.descripLabel.text = (NSLocalizedString("Do you want to unblock this user", comment: ""))
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
    
    @IBAction func yesPressed(_ sender: Any) {
        self.unblockUser()
    }
    
    @IBAction func noPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func unblockUser(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.id ?? 0
            Async.background({
                BlockUsersManager.instance.unBlockUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.dismiss(animated: true, completion: nil)
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
