//
//  ForgetPasswordVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async

class ForgetPasswordVC: BaseVC {
    //MARK: - Properties -
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: BorderedTextField!
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Selectors -
    @IBAction func backButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.emailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Please enter email."
            self.present(securityAlertVC!, animated: true, completion: nil)
            return
        } else if !self.emailTextField.text!.isEmail {
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Email is badly formatted."
            self.present(securityAlertVC!, animated: true, completion: nil)
            return
        } else {
            self.send()
        }
    }
}

//MARK: - Helper Functions -
extension ForgetPasswordVC {
    func setupUI() {
        self.sendButton.backgroundColor = .ButtonColor
        self.sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.emailTextField.textField.delegate = self
        self.emailTextField.updateLeftImageTint(tintColor: .unselectedTextFieldTintColor)
        self.emailTextField.backgroundColor = .unselectedTextFieldBackGroundColor
    }
}

//MARK: - API Services -
extension ForgetPasswordVC {
    private func send(){
        self.showProgressDialog(text: "Loading...")
        let email = emailTextField.text ?? ""
        Async.background({
            UserManager.instance.ForgetPassword(Email: email, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(sessionError?.error ?? "")
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
            
        })
    }
}

//MARK: - TextField Delegate Methods -
extension ForgetPasswordVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextField.backgroundColor = .selectedTextFieldBackGroundColor
        emailTextField.borderColorV = .ButtonColor
        emailTextField.updateLeftImageTint(tintColor: .ButtonColor)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespaces).count == 0
        emailTextField.backgroundColor = .unselectedTextFieldBackGroundColor
        emailTextField.borderColorV = .clear
        emailTextField.updateLeftImageTint(tintColor: !isEmpty ? .textColor : .unselectedTextFieldTintColor)
    }
}

