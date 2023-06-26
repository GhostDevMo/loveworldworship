//
//  EditProfileVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class EditProfileVC: BaseVC {

    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.nameTextField.placeholder = NSLocalizedString("Full Name", comment: "Full Name")
        self.facebookTextField.placeholder = NSLocalizedString("Kingschat", comment: "Kingschat")
        self.websiteTextField.placeholder = NSLocalizedString("Website", comment: "Website")
        self.saveButton.backgroundColor = .ButtonColor
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
    
        self.navigationController?.isNavigationBarHidden = false
 
    }
  
    @IBAction func savePressed(_ sender: Any) {
        updateProfile()
    }
    private func setupUI(){
        self.nameTextField.placeholder = (NSLocalizedString("Edit Profile", comment: ""))
        self.saveButton.setTitle((NSLocalizedString("SAVE", comment: "")), for: .normal)
        self.websiteTextField.placeholder = (NSLocalizedString("Website", comment: ""))
        self.websiteTextField.placeholder = (NSLocalizedString("Kingschat", comment: ""))
        self.title = (NSLocalizedString("Edit Profile", comment: ""))
        let name = AppInstance.instance.userProfile?.data?.name ?? ""
        let aboutMe = AppInstance.instance.userProfile?.data?.about ?? ""
        let facebook = AppInstance.instance.userProfile?.data?.facebook ?? ""
        let website = AppInstance.instance.userProfile?.data?.website ?? ""
        self.nameTextField.text = name
        self.aboutMeTextView.text = aboutMe
        self.facebookTextField.text = facebook
        self.websiteTextField.text = website
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    private func updateProfile(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let name = nameTextField.text ?? ""
            let aboutMe = aboutMeTextView.text ?? ""
            let facebook = self.facebookTextField.text ?? ""
            let website = self.websiteTextField.text ?? ""
            Async.background({
                ProfileManger.instance.editProfile(UserId: userId, AccessToken: accessToken, Name: name, About_me: aboutMe, Facebook: facebook, Website: website, completionBlock: { (success, sessionError, error) in
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
                                log.error("sessionError = \(sessionError?.error)")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
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
