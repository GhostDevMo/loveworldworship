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
    
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = .mainColor
        self.importBtn.backgroundColor = .ButtonColor
        self.title = "Import"
    }
    
    @IBAction func importPressed(_ sender: Any) {
        if self.urlTextFIeld.text!.isEmpty{
            self.view.makeToast("Please Enter URL ")
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
