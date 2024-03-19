//
//  CreateAddressVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Toast_Swift
import Async
import DeepSoundSDK

protocol CreateAddressVCDelegate {
    func refreshAddressData()
}

class CreateAddressVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneTextFieldView: UIView!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var countryTextFieldView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityTextFieldView: UIView!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var postcodeTextFieldView: UIView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: - Properties
    
    var headerTitle = ""
    var isEditAddress = false
    var address: AddressData?
    var delegate: CreateAddressVCDelegate?
    var isUpdate = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isUpdate {
            self.delegate?.refreshAddressData()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // Country Button Action
    @IBAction func countryButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.countryPopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    // Create Button Action
    @IBAction func createButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.nameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter Name")
            return
        }
        if self.phoneTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter Phonenumber")
            return
        }
        if self.countryTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select country")
            return
        }
        if self.cityTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter City")
            return
        }
        if self.postcodeTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter Postcode / Zip")
            return
        }
        if self.addressTextView.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter Address")
            return
        }
        let name = self.nameTextField.text ?? ""
        let phone = self.phoneTextField.text ?? ""
        let addressString = self.addressTextView.text ?? ""
        let city = self.cityTextField.text ?? ""
        let zip = self.postcodeTextField.text ?? ""
        let country = self.countryTextField.text ?? ""
        if !isEditAddress {
            self.addAddress(name: name, phone: phone, address: addressString, city: city, country: country, zip: zip)
        } else {
            let id = self.address?.id ?? 0
            self.editAddress(id: id, name: name, phone: phone, address: addressString, city: city, country: country, zip: zip)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
        if self.isEditAddress {
            self.setData()
        }
    }
    
    func textFieldSetUp() {
        self.nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.nameTextField.delegate = self
        self.phoneTextField.attributedPlaceholder = NSAttributedString(
            string: "Phone",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.phoneTextField.delegate = self
        self.countryTextField.attributedPlaceholder = NSAttributedString(
            string: "Country",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.countryTextField.delegate = self
        self.cityTextField.attributedPlaceholder = NSAttributedString(
            string: "City",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.cityTextField.delegate = self
        self.postcodeTextField.attributedPlaceholder = NSAttributedString(
            string: "Postcode / Zip",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.postcodeTextField.delegate = self
    }
    
    private func setUpUI() {
        self.headerLabel.text = headerTitle
        self.addressTextView.addPlaceholder("Address", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        self.addressTextView.delegate = self
    }
    
    func setData() {
        self.nameTextField.text = self.address?.name ?? ""
        self.phoneTextField.text = self.address?.phone ?? ""
        self.countryTextField.text = self.address?.country ?? ""
        self.cityTextField.text = self.address?.city ?? ""
        self.postcodeTextField.text = self.address?.zip ?? ""
        self.addressTextView.text = self.address?.address ?? ""
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension CreateAddressVC {
    
    private func addAddress(name: String, phone: String, address: String, city: String, country: String, zip: String) {
        if Connectivity.isConnectedToNetwork() {
            let access_token = AppInstance.instance.accessToken ?? ""
            let params = [
                API.Params.AccessToken: access_token,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key,
                API.Params.Name: name,
                API.Params.phone: phone,
                API.Params.address: address,
                API.Params.city: city,
                API.Params.country: country,
                API.Params.zip: zip
            ] as JSON
            
            Async.background {
                AddressManger.instance.addAddress(params: params) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message)
                                self.delegate?.refreshAddressData()
                                self.navigationController?.popViewController(animated: true)
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
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func editAddress(id: Int, name: String, phone: String, address: String, city: String, country: String, zip: String) {
        if Connectivity.isConnectedToNetwork() {
            let access_token = AppInstance.instance.accessToken ?? ""
            
            let params = [
                API.Params.AccessToken: access_token,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key,
                API.Params.Id: id,
                API.Params.Name: name,
                API.Params.phone: phone,
                API.Params.address: address,
                API.Params.city: city,
                API.Params.country: country,
                API.Params.zip: zip
            ] as JSON
            
            Async.background {
                AddressManger.instance.editAddress(params: params) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message)
                                self.getByIdAddress(id: self.address?.id ?? 0)
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
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getByIdAddress(id: Int) {
        if Connectivity.isConnectedToNetwork() {
            let access_token = AppInstance.instance.accessToken ?? ""
            Async.background {
                AddressManger.instance.getByIdAddress(access_token: access_token, id: id, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.isUpdate = true
                                self.address = success?.data
                                self.setData()
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
extension CreateAddressVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.nameTextFieldView.borderColorV = .mainColor
        case phoneTextField:
            self.phoneTextFieldView.borderColorV = .mainColor
        case countryTextField:
            self.countryTextFieldView.borderColorV = .mainColor
        case cityTextField:
            self.cityTextFieldView.borderColorV = .mainColor
        case postcodeTextField:
            self.postcodeTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.nameTextFieldView.borderColorV = .clear
        case phoneTextField:
            self.phoneTextFieldView.borderColorV = .clear
        case countryTextField:
            self.countryTextFieldView.borderColorV = .clear
        case cityTextField:
            self.cityTextFieldView.borderColorV = .clear
        case postcodeTextField:
            self.postcodeTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: UITextViewDelegate Methods
extension CreateAddressVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case addressTextView:
            self.addressView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case addressTextView:
            self.addressView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: CountryPopupVCDelegate Methods
extension CreateAddressVC: CountryPopupVCDelegate {
    
    func handleCountrySelection(countryName: String) {
        self.countryTextField.text = countryName
    }
    
}
