//
//  WidthdrawalsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
import Toast_Swift

class WidthdrawalsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myBalanceLabel: UILabel!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountTextFieldView: UIView!
    @IBOutlet weak var payPalEmailTextField: UITextField!
    @IBOutlet weak var payPalEmailTextFieldView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
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
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.amountTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter amount")
            return
        }
        if self.payPalEmailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter email")
            return
        }
        if !(payPalEmailTextField.text?.isEmail ?? false) {
            self.view.makeToast("Email is badly formatted")
            return
        }
        let email = self.payPalEmailTextField.text ?? ""
        let amount = Int(self.amountTextField.text ?? "") ?? 0
        self.widthdraw(amount: amount, email: email)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
    }
    
    func textFieldSetUp() {
        self.amountTextField.attributedPlaceholder = NSAttributedString(
            string: "Amount",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.amountTextField.delegate = self
        self.payPalEmailTextField.attributedPlaceholder = NSAttributedString(
            string: "PayPal E-mail",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.payPalEmailTextField.delegate = self
    }
    
    private func setUpUI() {
        self.balanceAmountLabel.text = AppInstance.instance.userProfile?.data?.balance ?? "0 $"
    }
    
    private func widthdraw(amount: Int, email: String) {
        if Connectivity.isConnectedToNetwork() {
            let access_token = AppInstance.instance.accessToken ?? ""
            Async.background {
                WidthdrawalManager.instance.Widthdraw(AccessToken: access_token, amount: amount, email: email, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? "")")
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
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UITextFieldDelegate Methods
extension WidthdrawalsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case amountTextField:
            self.amountTextFieldView.borderColorV = .mainColor
        case payPalEmailTextField:
            self.payPalEmailTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case amountTextField:
            self.amountTextFieldView.borderColorV = .clear
        case payPalEmailTextField:
            self.payPalEmailTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}
