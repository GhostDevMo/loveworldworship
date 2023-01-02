//
//  BlockUserPopUpVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 09/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class BlockUserPopUpVC: BaseVC {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var copLink: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    
    var id:Int? = 0
     var delegate:showToastStringForBlockUserDelegate?
    var urlString:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.copLink.setTitle((NSLocalizedString("Copy Profile's lInk", comment: "")), for: .normal)
        self.blockButton.setTitle((NSLocalizedString("Block", comment: "")), for: .normal)
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
    
    
    @IBAction func blockUserPressed(_ sender: Any) {
        blockUser()
        
    }
    
    @IBAction func closedPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func copyLinkToProfilePressed(_ sender: Any) {
        UIPasteboard.general.string = urlString ?? ""
        self.delegate?.showToastStringForBlockUser(string: "Copied text to Clipboard", status: false)
        self.dismiss(animated: true, completion: nil)
        
    }
    private func blockUser(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.id ?? 0
            Async.background({
                BlockUsersManager.instance.blockUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.delegate?.showToastStringForBlockUser(string: "Blocked Successfully", status: true)
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
