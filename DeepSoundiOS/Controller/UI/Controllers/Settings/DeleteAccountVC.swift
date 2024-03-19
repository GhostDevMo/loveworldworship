//
//  DeleteAccountVC.swift
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

class DeleteAccountVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    // MARK: - Properties
    
    private var status: Bool = false
    
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
    
    // Check Box Button Action
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        self.status = !self.status
        if self.status {
            self.checkBoxButton.setImage(R.image.ic_checked(), for: .normal)
        } else {
            self.checkBoxButton.setImage(R.image.ic_uncheck(), for: .normal)
        }
    }
    
    // Remove Account Button Action
    @IBAction func removeAccountButtonAction(_ sender: UIButton) {
        if self.passwordTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter your password")
            return
        }
        if !self.status {
            self.view.makeToast("You can not access your disapproval of the Terms and Conditions.")
            return
        }
        let password = self.passwordTextField.text ?? ""
        self.deleteAccount(password: password)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.textLabel.text = "Yes, I want to delete \(AppInstance.instance.userProfile?.data?.username ?? "") parmanently from DeepSound Account."
    }
    
    func textFieldSetUp() {
        self.passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.passwordTextField.delegate = self
    }
    
    private func deleteAccount(password: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                ProfileManger.instance.deleteAccount(UserId: userId, AccessToken: accessToken, Current_Password: password, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
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
    
    @objc func update() {
        UserDefaults.standard.clearUserDefaults()
        let vc = R.storyboard.login.main()
        appDelegate.window?.rootViewController = vc
    }
    
}

// MARK: UITextFieldDelegate Methods
extension DeleteAccountVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case passwordTextField:
            self.passwordTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case passwordTextField:
            self.passwordTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}
