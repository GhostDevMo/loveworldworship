//
//  DeletePlaylistPopUpVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 09/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class DeletePlaylistPopUpVC: BaseVC {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var DeletePlaylist: UILabel!
    @IBOutlet weak var descpLabel: UILabel!
    
    var playlistId:Int? = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noButton.setTitle((NSLocalizedString("NO", comment: "")), for: .normal)
        self.yesButton.setTitle((NSLocalizedString("YES", comment: "")), for: .normal)
        self.DeletePlaylist.text = (NSLocalizedString("Delete Playlist", comment: ""))
        self.descpLabel.text = (NSLocalizedString("Are you sure you want to delete this playlist ?", comment: ""))
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
        self.deletePlaylist()
    }
    private func deletePlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let playlistId = self.playlistId ?? 0
            Async.background({
                PlaylistManager.instance.deletePlaylist(playlistId: playlistId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
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
