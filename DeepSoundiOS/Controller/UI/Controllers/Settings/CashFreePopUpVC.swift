//
//  CashfreePopupVC.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Toast_Swift

protocol CashfreePopupVCDelegate {
    func handleCashfreePayNowButtonTap(name: String, email: String, phone: String)
}

class CashfreePopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var nameTextView: UIView!
    @IBOutlet weak var emailTextView: UIView!
    @IBOutlet weak var phoneTextView: UIView!
    
    // MARK: - Properties
    
    var delegate: CashfreePopupVCDelegate?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    // Pay Now Button Action
    @IBAction func payNowButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if nameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter your name")
            return
        }
        if emailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter your email")
            return
        }
        if phoneTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter your phone number")
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.handleCashfreePayNowButtonTap(name: (self.nameTextField.text ?? ""), email: (self.emailTextField.text ?? ""), phone: (self.phoneTextField.text ?? ""))
        }
    }
    
    // MARK: - Helper Functions -
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        self.setUserData()
        self.configView()
    }
    
    //MARK:- Methods
    func configView() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        nameTextField.tintColor = .mainColor
        emailTextField.tintColor = .mainColor
        phoneTextField.tintColor = .mainColor
                
        nameTextView.borderWidthV = 1
        emailTextView.borderWidthV = 1
        phoneTextView.borderWidthV = 1
        
        nameTextView.borderColorV = .clear
        emailTextView.borderColorV = .clear
        phoneTextView.borderColorV = .clear
        
    }
    
    // Set User Data
    func setUserData() {
        self.nameTextField.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.emailTextField.text = AppInstance.instance.userProfile?.data?.email ?? ""
        self.phoneTextField.text = AppInstance.instance.userProfile?.data?.phone_number ?? ""
    }
}

extension CashfreePopupVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            nameTextView.borderColorV = .mainColor
        } else if textField == emailTextField {
            emailTextView.borderColorV = .mainColor
        } else if textField == phoneTextField {
            phoneTextView.borderColorV = .mainColor
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
//        let isEmpty = textField.text?.trimmingCharacters(in: .whitespaces).count == 0
        if textField == nameTextField {
            nameTextView.borderColorV = .clear
        } else if textField == emailTextField {
            emailTextView.borderColorV = .clear
        } else if textField == phoneTextField {
            phoneTextView.borderColorV = .clear
        }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
