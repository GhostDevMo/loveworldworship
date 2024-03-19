//
//  ChangePasswordVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import Toast_Swift

class ChangePasswordVC: BaseVC {
    
    // MARK: - IBOutlets

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var currentPasswordTextFieldView: UIView!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextFieldView: UIView!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextFieldView: UIView!
    @IBOutlet weak var lblReset: UILabel!
    
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
        if self.currentPasswordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            log.verbose("Please enter Current Password.")
            self.view.makeToast("Please enter Current Password.")
            return
        }
        if self.newPasswordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            log.verbose("Please enter New Password.")
            self.view.makeToast("Please enter New Password.")
            return
        }
        if self.repeatPasswordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            log.verbose("Please enter Repeat Password.")
            self.view.makeToast("Please enter Repeat Password.")
            return
        }
        if self.newPasswordTextField.text != self.repeatPasswordTextField.text {
            log.verbose("Password do not match.")
            self.view.makeToast("Password do not match.")
            return
        }
        self.updatePassword()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        var str = NSMutableAttributedString(string: "If you forget your password, you can reset it", attributes: [.foregroundColor: UIColor.textColor])
        str.append(NSMutableAttributedString(string: " from here.", attributes: [.foregroundColor: UIColor.systemBlue]))
        self.lblReset.attributedText = str
        
        self.lblReset.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        tapGes.numberOfTapsRequired = 1
        self.lblReset.addGestureRecognizer(tapGes)
    }
    
    @objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let text = self.lblReset.text else { return }
        let rangeTXT = (text as NSString).range(of: " from here.")
        if sender.didTapAttributedTextInLabel(label: self.lblReset, inRange: rangeTXT) {
            let newVC = R.storyboard.login.forgetPasswordVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
    
    func textFieldSetUp() {
        self.currentPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Current Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.currentPasswordTextField.delegate = self
        self.newPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "New Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.newPasswordTextField.delegate = self
        self.repeatPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Repeat Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.repeatPasswordTextField.delegate = self
    }
    
    private func updatePassword() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let currentPassword = currentPasswordTextField.text ?? ""
            let newPassword = newPasswordTextField.text ?? ""
            let repeatPassword = self.repeatPasswordTextField.text ?? ""
            Async.background {
                ProfileManger.instance.changePasswrod(UserId: userId, AccessToken: accessToken, Current_Password: currentPassword, New_Password: newPassword, Repeat_Password: repeatPassword, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile { success in
                                    print(success)
                                }
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
extension ChangePasswordVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case currentPasswordTextField:
            self.currentPasswordTextFieldView.borderColorV = .mainColor
        case newPasswordTextField:
            self.newPasswordTextFieldView.borderColorV = .mainColor
        case repeatPasswordTextField:
            self.repeatPasswordTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case currentPasswordTextField:
            self.currentPasswordTextFieldView.borderColorV = .clear
        case newPasswordTextField:
            self.newPasswordTextFieldView.borderColorV = .clear
        case repeatPasswordTextField:
            self.repeatPasswordTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}
