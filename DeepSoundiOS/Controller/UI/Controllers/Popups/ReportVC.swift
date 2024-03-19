//
//  ReportVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class ReportVC: BaseVC {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var songsLabel: UILabel!
    var Id:Int? = 0
    var songLink:String? = ""
    var trackDescription:String? = (NSLocalizedString("I don't like this song!!", comment: ""))
    var delegate:showToastStringDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.copyButton.setTitle((NSLocalizedString("Copy", comment: "")), for: .normal)
        self.reportButton.setTitle((NSLocalizedString("Report This Song", comment: "")), for: .normal)
        self.songsLabel.text = (NSLocalizedString("Songs", comment: ""))
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportPressed(_ sender: UIButton) {
        if AppInstance.instance.getUserSession(){
            self.reportTrack()

        }else{
            let vc = R.storyboard.popups.loginPopupVC()
            self.present(vc!, animated: true, completion: nil)
        }
    }
    @IBAction func copyToClipBoardPressed(_ sender: UIButton) {
        UIPasteboard.general.string = songLink ?? ""
        self.delegate?.showToastString(string: "Copy to Clipboard")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func reportTrack(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.Id ?? 0
            let trackDes = self.trackDescription ?? ""
            Async.background({
                ReportManager.instance.report(Id: trackId, AccessToken: accessToken, ReportDescription: trackDes, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.delegate?.showToastString(string: "You reported song")
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
