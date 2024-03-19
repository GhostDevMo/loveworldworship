//
//  CreateAdVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 18/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class CreateAdVC: BaseVC {
    
    @IBOutlet weak var imageBGView: UIView!
    @IBOutlet weak var btnCreate: UIButton!
    
    @IBOutlet weak var thumbailImageView: UIImageView!
    @IBOutlet weak var descriptionTF: UITextView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var limitPerDayTF: UITextField!
    @IBOutlet weak var targetAudienceTF: UITextField!
    @IBOutlet weak var placementTF: UITextField!
    @IBOutlet weak var pricingTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var limitPerDayView: UIView!
    
    private let imagePickerController = UIImagePickerController()
    private var selectedImage:UIImage? = nil
    var selectedTragetAudience: String = ""
    var selectedPlacement: String = ""
    var selectedPricing: String = ""
    var selectedType: String = ""
    var selectedTargetAudienceData:[CountryList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.thumbailImageView.cornerRadiusV = 16.0
        self.imageBGView.addShadow(offset: .init(width: 0, height: 0), radius: 1, opacity: 0.5)
        self.btnCreate.addShadow(offset: .init(width: 0, height: 2), radius: 5, opacity: 0.5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func createBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.selectedImage == nil {
            self.view.makeToast("Please Select Thumbail Image")
            return
        }
        if self.nameTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter name")
            return
        }
        
        if self.titleTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter title")
            return
        }
        
        if self.urlTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter url")
            return
        }
        
        if self.descriptionTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter description")
            return
        }
        
        if self.selectedTragetAudience.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Select Target Audience")
            return
        }
        
        if self.selectedPlacement.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Select Placement")
            return
        }
        
        if self.selectedPricing.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Select Pricing")
            return
        }
        
        if self.limitPerDayTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter per day spending limit")
            return
        }
        
        if self.selectedType.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Select type")
            return
        }
        
        self.createAds()
    }
    
    @IBAction func uploadImageBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else {
                self.view.makeToast("Camera is not Supported!..")
            }
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func targetAudienceBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.targetAudiencePopupVC() {
            newVC.selectedCountry = self.selectedTargetAudienceData
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    @IBAction func placementBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.advertisementPopupVC() {
            newVC.isPlacement = true
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    @IBAction func pricingBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.advertisementPopupVC() {
            newVC.isPricing = true
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    @IBAction func typeBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.advertisementPopupVC() {
            newVC.isType = true
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
}

//MARK: - API Services -
extension CreateAdVC {
    private func createAds() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let thumbnailData = self.selectedImage?.jpegData(compressionQuality: 0.2)
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            
            let params: JSON = [
                API.Params.ServerKey : API.SERVER_KEY.Server_Key,
                API.Params.AccessToken : AppInstance.instance.accessToken ?? "",
                API.Params.Name : self.nameTF.text ?? "",
                API.Params.url : self.urlTF.text ?? "",
                API.Params.Title : self.titleTF.text ?? "",
                API.Params.desc : self.descriptionTF.text ?? "",
                API.Params.audience_list : self.selectedTragetAudience,
                API.Params.cost : self.selectedPricing,
                API.Params.placement : self.selectedPlacement,
                API.Params.type : self.selectedType
            ]
            
            Async.background({
                AdsManager.instance.addAdsAPI(params: params, Thumbnail_data: thumbnailData) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success ?? "")")
                                self.view.makeToast(success)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError ?? "")")
                                self.view.makeToast(sessionError)
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

//MARK: - Target Audience Delegate Methods -
extension CreateAdVC: TargetAudiencePopupDelegate {
    func selectdTargetAudience(_ selectedData: [CountryList]) {
        var selectedCountry = ""
        var selectedTargetID = ""
        selectedData.forEach { object in
            if selectedCountry == "" {
                selectedCountry = object.text
                selectedTargetID = object.value
            }else {
                let text = ","+object.value
                selectedTargetID += text
                let country = ", "+object.text
                selectedCountry += country
            }
        }
        self.targetAudienceTF.text = selectedCountry
        self.selectedTragetAudience = selectedTargetID
        self.selectedTargetAudienceData = selectedData
        print(self.selectedTragetAudience)
    }
}

//MARK: - Advertisement Delegate Methods -
extension CreateAdVC: AdvertisementPopupDelegate {
    func selectedPlacement(_ type: String, _ id: String) {
        self.placementTF.text = type
        self.selectedPlacement = id
    }
    
    func selectedPricing(_ type: String, _ id: String) {
        self.pricingTF.text = type
        self.selectedPricing = id
    }
    
    func selectedType(_ type: String) {
        self.typeTF.text = type
        self.selectedType = type
    }
}

extension CreateAdVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTF:
            self.nameView.borderColorV = .mainColor
        case urlTF:
            self.urlView.borderColorV = .mainColor
        case titleTF:
            self.titleView.borderColorV = .mainColor
        case limitPerDayTF:
            self.limitPerDayView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTF:
            self.nameView.borderColorV = .clear
        case urlTF:
            self.urlView.borderColorV = .clear
        case titleTF:
            self.titleView.borderColorV = .clear
        case limitPerDayTF:
            self.limitPerDayView.borderColorV = .clear
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension CreateAdVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.descriptionView.borderColorV = .mainColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.descriptionView.borderColorV = .clear
    }
}

extension CreateAdVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.thumbailImageView.image = image
            self.selectedImage = image
            self.dismiss(animated: true, completion: nil)
        }
    }
}
