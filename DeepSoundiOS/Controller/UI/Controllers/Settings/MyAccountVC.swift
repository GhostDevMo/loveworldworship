//
//  MyAccountVC.swift
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

class MyAccountVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameTextFieldView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldView: UIView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageTextFieldView: UIView!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var countryTextFieldView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var paypalEmailTextField: UITextField!
    @IBOutlet weak var paypalEmailTextFieldView: UIView!
    
    // MARK: - Properties
    
    private var gender: String? = ""
    
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
    
    // Male Button Action
    @IBAction func maleButtonAction(_ sender: UIButton) {
        self.maleButton.setImage(R.image.ic_check_radio(), for: .normal)
        self.femaleButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.gender = "male"
    }
    
    // Female Button Action
    @IBAction func femaleButtonAction(_ sender: UIButton) {
        self.femaleButton.setImage(R.image.ic_check_radio(), for: .normal)
        self.maleButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.gender = "female"
    }
    
    // Country Button Action
    @IBAction func countryButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.countryPopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    // Save Button Action
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.save()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
    }
    
    func textFieldSetUp() {
        self.userNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.userNameTextField.delegate = self
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.emailTextField.delegate = self
        self.ageTextField.attributedPlaceholder = NSAttributedString(
            string: "Choose your age",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.ageTextField.delegate = self
        self.countryTextField.attributedPlaceholder = NSAttributedString(
            string: "Choose your country",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.countryTextField.delegate = self
        self.paypalEmailTextField.attributedPlaceholder = NSAttributedString(
            string: "PayPal E-mail",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.paypalEmailTextField.delegate = self
    }
    
    private func setUpUI() {
        let username = AppInstance.instance.userProfile?.data?.username ?? ""
        let email = AppInstance.instance.userProfile?.data?.email ?? ""
        let age = AppInstance.instance.userProfile?.data?.age ?? 0
        let country = AppInstance.instance.userProfile?.data?.country_name ?? ""
        let gender = AppInstance.instance.userProfile?.data?.gender ?? ""
        if age == 0 {
            self.ageTextField.text = ""
        } else {
            self.ageTextField.text = "\(age)"
        }
        self.userNameTextField.text = username
        self.emailTextField.text = email
        self.countryTextField.text = country
        if gender == "male" {
            self.maleButton.setImage(R.image.ic_check_radio(), for: .normal)
            self.femaleButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        } else {
            self.femaleButton.setImage(R.image.ic_check_radio(), for: .normal)
            self.maleButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        }
    }
    
    private func save() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let username = self.userNameTextField.text ?? ""
            let email = self.emailTextField.text ?? ""
            let age = Int(self.ageTextField.text ?? "")
            let country = self.countryTextField.text ?? ""
            let gender = self.gender ?? ""
            Async.background {
                ProfileManger.instance.updateMyAccount(UserId: userId, AccessToken: accessToken, Username: username, Email: email, Country: country, Gender: gender, Age: age ?? 0, completionBlock: { (success, sessionError, error) in
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
extension MyAccountVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case userNameTextField:
            self.userNameTextFieldView.borderColorV = .mainColor
        case emailTextField:
            self.emailTextFieldView.borderColorV = .mainColor
        case ageTextField:
            self.ageTextFieldView.borderColorV = .mainColor
        case countryTextField:
            self.countryTextFieldView.borderColorV = .mainColor
        case paypalEmailTextField:
            self.paypalEmailTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case userNameTextField:
            self.userNameTextFieldView.borderColorV = .clear
        case emailTextField:
            self.emailTextFieldView.borderColorV = .clear
        case ageTextField:
            self.ageTextFieldView.borderColorV = .clear
        case countryTextField:
            self.countryTextFieldView.borderColorV = .clear
        case paypalEmailTextField:
            self.paypalEmailTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: CountryPopupVCDelegate Methods
extension MyAccountVC: CountryPopupVCDelegate {
    func handleCountrySelection(countryName: String) {
        self.countryTextField.text = countryName
    }
}
