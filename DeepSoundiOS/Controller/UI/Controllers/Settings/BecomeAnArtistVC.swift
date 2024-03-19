//
//  BecomeAnArtistVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 25/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import Toast_Swift
import DeepSoundSDK

class BecomeAnArtistVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var personalImageView: UIImageView!
    @IBOutlet weak var personalPlaceholderView: UIView!
    @IBOutlet weak var passportImageView: UIImageView!
    @IBOutlet weak var passportPlaceholderView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var genresTextFieldView: UIView!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var websiteTextFieldView: UIView!
    
    // MARK: - Properties
    
    private let imagePickerController = UIImagePickerController()
    var isPassportImage = false
    private var passportImage: UIImage? = nil
    private var personalImage: UIImage? = nil
    private var genresId = 0
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Personal Button Action
    @IBAction func personalButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Select Source", message: "", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.view.makeToast("Sorry camera not found...")
                return
            }
            self.imagePickerController.delegate = self
            self.isPassportImage = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.isPassportImage = false
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Passport Button Action
    @IBAction func passportButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Select Source", message: "", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.view.makeToast("Sorry camera not found...")
                return
            }
            self.imagePickerController.delegate = self
            self.isPassportImage = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.isPassportImage = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Genres Button Action
    @IBAction func genresButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.genresPopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true, completion: nil)
        }
    }
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.nameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter name")
            return
        }
        if self.genresTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select Genres")
            return
        }
        if passportImage == nil {
            self.view.makeToast("Please select passport image")
            return
        }
        if self.personalImage == nil {
            self.view.makeToast("Please select personal photo")
            return
        }
        let passport_data = self.passportImage?.jpegData(compressionQuality: 0.2)
        let photo_data = self.personalImage?.jpegData(compressionQuality: 0.2)
        self.becomeAnArtist(name: self.nameTextField.text ?? "", category_id: self.genresId, passport_data: passport_data, photo_data: photo_data)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
    }
    
    private func setUpUI() {
        self.descriptionTextView.addPlaceholder("Description", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        self.descriptionTextView.delegate = self
    }
    
    func textFieldSetUp() {
        self.nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.nameTextField.delegate = self
        self.genresTextField.attributedPlaceholder = NSAttributedString(
            string: "Genres",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.genresTextField.delegate = self
        self.websiteTextField.attributedPlaceholder = NSAttributedString(
            string: "Website",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.websiteTextField.delegate = self
    }

}

// MARK: - Extensions

// MARK: Api Call
extension BecomeAnArtistVC {
    
    private func becomeAnArtist(name: String, category_id: Int, passport_data: Data?, photo_data: Data?) {
        self.showProgressDialog(text: "Loading...")
        let access_token = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                ProfileManger.instance.becomeAnArtist(access_token: access_token, name: name, category_id: category_id, passport_data: passport_data, photo_data: photo_data, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(success?.message ?? "")
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
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate Methods
extension BecomeAnArtistVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if self.isPassportImage {
            self.passportImageView.image = image
            self.passportImage = image
            self.passportPlaceholderView.isHidden = true
        } else {
            self.personalImageView.image = image
            self.personalImage  = image
            self.personalPlaceholderView.isHidden = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: getGenresStringDelegate Methods
extension BecomeAnArtistVC: GenresPopupVCDelegate {
    
    func handleGenresSelection(id: Int, cateogryName: String) {
        self.genresId = id
        self.genresTextField.text = cateogryName
        log.verbose("String to send on =\(cateogryName)")
    }
    
}

// MARK: UITextFieldDelegate Methods
extension BecomeAnArtistVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.nameTextFieldView.borderColorV = .mainColor
        case genresTextField:
            self.genresTextFieldView.borderColorV = .mainColor
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
        case genresTextField:
            self.genresTextFieldView.borderColorV = .clear
        case websiteTextField:
            self.websiteTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: UITextViewDelegate Methods
extension BecomeAnArtistVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            self.descriptionView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            self.descriptionView.borderColorV = .clear
        default:
            break
        }
    }
    
}
