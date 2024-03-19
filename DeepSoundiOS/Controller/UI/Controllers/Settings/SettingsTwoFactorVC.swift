//
//  SettingsTwoFactorVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import Toast_Swift
import DeepSoundSDK

protocol TwoFactorAuthDelegate {
    func getTwoFactorUpdateString(type:String)
}

class SettingsTwoFactorVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var twoFactorTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextFieldView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    
    // var bannerView: GADBannerView!
    var typeString: String? = ""
    var isConfirmCode = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Two Factor Button Action
    @IBAction func twoFactorButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.twoFactorUpdatePopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true, completion: nil)
        }
    }
    
    // Save Button Action
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isConfirmCode {
            self.verifyCode(code: self.confirmationCodeTextField.text ?? "")
        } else {
            let type = self.typeString ?? ""
            self.updateTwoFactorSendCode(type: type)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setData()
    }
    
    func textFieldSetUp() {
        self.confirmationCodeTextField.attributedPlaceholder = NSAttributedString(
            string: "Confirmation Code",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
    }
    
    func setData() {
        if AppInstance.instance.userProfile?.data?.two_factor == 0 {
            self.typeString = "disable"
            self.twoFactorTextField.text = "Disable"
        } else {
            self.typeString = "enable"
            self.twoFactorTextField.text = "Enable"
        }
    }
    
    private func updateTwoFactorSendCode(type: String) {
        if Connectivity.isConnectedToNetwork() {
            // self.showProgressDialog(text: "Loading")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                TwoFactorManager.instance.updateTwoFactor(AccessToken: accessToken, userId: userId, twoFactor: type, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                if success?.data == (NSLocalizedString("Settings successfully updated!", comment: "")) {
                                    self.view.makeToast(success?.data ?? "")
                                    AppInstance.instance.fetchUserProfile { success in
                                        self.setData()
                                    }
                                } else {
                                    self.isConfirmCode = true
                                    self.confirmationCodeTextFieldView.isHidden = false
                                    self.saveButton.setTitle("Send", for: .normal)
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription)
                                log.error("error = \(error?.localizedDescription ?? "")")
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
    
    private func verifyCode(code: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString(("Loading"), comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                TwoFactorManager.instance.verifyTwoFactor(AccessToken: accessToken, userId: userId, code: code) { (success, sessionError, error) in
                    if success != nil{
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(success?.data ?? "")
                                self.dismiss(animated: true) {
                                    AppInstance.instance.fetchUserProfile { success in
                                        self.isConfirmCode = false
                                        self.confirmationCodeTextFieldView.isHidden = true
                                        self.saveButton.setTitle("Save", for: .normal)
                                        self.setData()
                                    }
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription)
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: - Extensions

// MARK: TwoFactorAuthDelegate Methods
extension SettingsTwoFactorVC: TwoFactorAuthDelegate {
    
    func getTwoFactorUpdateString(type: String) {
        if type == "enable" {
            self.twoFactorTextField.text = "Enable"
        } else {
            self.twoFactorTextField.text = "Disable"
            self.confirmationCodeTextFieldView.isHidden = true
            self.saveButton.setTitle("Save", for: .normal)
            self.isConfirmCode = false
        }
        self.typeString = type
    }
    
}
