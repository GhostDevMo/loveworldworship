//
//  ImportURLVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
class ImportURLVC: BaseVC {
    
    @IBOutlet weak var urlTextFIeld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UIPasteboard.general.string {
            if data.contains("https") {
                self.urlTextFIeld.text = data
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        if self.urlTextFIeld.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.view.makeToast("Please Enter Your URL")
            return
        }else{
            self.importURL()
        }
    }
    
    private func importURL(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let trackURL = self.urlTextFIeld.text ?? ""
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            Async.background({
                TrackManager.instance.importTrack(TrackURL: trackURL, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast("Playlist has been created")
                                self.navigationController?.popViewController(animated: true)
                                
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
                }
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }    
}
