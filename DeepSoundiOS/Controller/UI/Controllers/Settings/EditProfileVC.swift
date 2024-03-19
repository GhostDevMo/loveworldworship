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
import Toast_Swift

class EditProfileVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var websiteTextFieldView: UIView!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var facebookTextFieldView: UIView!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
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
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Save Button Action
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.updateProfile()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
    }
    
    func textFieldSetUp() {
        self.nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Full Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.nameTextField.delegate = self
        self.facebookTextField.attributedPlaceholder = NSAttributedString(
            string: "Facebook",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.facebookTextField.delegate = self
        self.websiteTextField.attributedPlaceholder = NSAttributedString(
            string: "Website",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.websiteTextField.delegate = self
    }
    
    private func setUpUI() {
        self.aboutMeTextView.addPlaceholder("About", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        self.aboutMeTextView.delegate = self
        let name = AppInstance.instance.userProfile?.data?.name ?? ""
        let aboutMe = AppInstance.instance.userProfile?.data?.about ?? ""
        let facebook = AppInstance.instance.userProfile?.data?.facebook ?? ""
        let website = AppInstance.instance.userProfile?.data?.website ?? ""
        self.nameTextField.text = name
        self.aboutMeTextView.text = aboutMe
        self.facebookTextField.text = facebook
        self.websiteTextField.text = website
    }
    
    private func updateProfile() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let name = nameTextField.text ?? ""
            let aboutMe = aboutMeTextView.text ?? ""
            let facebook = self.facebookTextField.text ?? ""
            let website = self.websiteTextField.text ?? ""
            Async.background {
                ProfileManger.instance.editProfile(UserId: userId, AccessToken: accessToken, Name: name, About_me: aboutMe, Facebook: facebook, Website: website, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile { _ in }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UITextFieldDelegate Methods
extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.nameTextFieldView.borderColorV = .mainColor
        case facebookTextField:
            self.facebookTextFieldView.borderColorV = .mainColor
        case websiteTextField:
            self.websiteTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.nameTextFieldView.borderColorV = .clear
        case facebookTextField:
            self.facebookTextFieldView.borderColorV = .clear
        case websiteTextField:
            self.websiteTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: UITextViewDelegate Methods
extension EditProfileVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case aboutMeTextView:
            self.aboutMeView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case aboutMeTextView:
            self.aboutMeView.borderColorV = .clear
        default:
            break
        }
    }
    
}
