//
//  CreateEventVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 22/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import Toast_Swift
import MobileCoreServices
import AVFoundation

class CreateEventVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverPlusImageView: UIImageView!
    @IBOutlet weak var uploadCoverLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoPlusImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var timezoneButton: UIButton!
    @IBOutlet weak var timezoneTextField: UITextField!
    @IBOutlet weak var sellTicketButton: UIButton!
    @IBOutlet weak var sellTicketTextField: UITextField!
    @IBOutlet weak var sellTicketsStackView: UIStackView!
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var ticketAvailableTextField: UITextField!
    
    // MARK: - Properties
    
    var object: Events?
    var imageData: Data?
    var videoData: Data?
    var locationString: String?
    var timeZoneString: String?
    var sellTicketString: String?
    var id: Int?
    private let imagePicker = UIImagePickerController()
    let datePicker = UIDatePicker()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Cover Image Button Action
    @IBAction func coverImageButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Select Source", message: "", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.view.makeToast("Sorry Camera is not found...")
                return
            }
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Video Image Button Action
    @IBAction func videoImageButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Select Video From", message: "", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Record Video from camera", style: .default) { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.view.makeToast("Sorry Camera is not found...")
                return
            }
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Video Gallery", style: .default) { (action) in
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Location Button Action
    @IBAction func locationButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Location", message: "", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Online", style: .default) { action in
            log.verbose("YEs")
            self.locationString = "online"
            self.locationTextField.text = "Online"
            self.addressTextView.addPlaceholder("url", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        }
        let no = UIAlertAction(title: "Real Location", style: .default) { action in
            log.verbose("No")
            self.locationString = "real"
            self.locationTextField.text = "Real Location"
            self.addressTextView.addPlaceholder("Address", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Start Date Button Action
    @IBAction func startDateButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.setDatePickerView(tag: sender.tag)
    }
    
    // End Date Button Action
    @IBAction func endDateButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.setDatePickerView(tag: sender.tag)
    }
    
    // Start Time Button Action
    @IBAction func startTimeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.setTimePickerView(tag: sender.tag)
    }
    
    // End Time Button Action
    @IBAction func endTimeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.setTimePickerView(tag: sender.tag)
    }
    
    
    // Timezone Button Action
    @IBAction func timezoneButtonAction(_ sender: UIButton) {
        if let newVC = R.storyboard.popups.selectTimeZoneVC() {
            newVC.delegate = self
            self.present(newVC, animated: true, completion: nil)
        }
    }
    
    // Sell Ticket Button Action
    @IBAction func sellTicketButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sell Tickets", message: "", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Yes", style: .default) { action in
            log.verbose("Yes")
            self.sellTicketString = "yes"
            self.sellTicketTextField.text = "Yes"
            self.sellTicketsStackView.isHidden = false
        }
        let no = UIAlertAction(title: "No", style: .default) { action in
            log.verbose("No")
            self.sellTicketString = "no"
            self.sellTicketTextField.text = "No"
            self.sellTicketsStackView.isHidden = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Save Button Action
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if self.imageData == nil {
            self.view.makeToast("Please select Image")
            return
        }
        if self.videoData == nil {
            self.view.makeToast("Please select video")
            return
        }
        if self.nameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter name")
            return
        }
        if self.descriptionTextView.text.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please enter description")
            return
        }
        if self.locationString == nil {
            self.view.makeToast("Please select location")
            return
        }
        if self.addressTextView.text.trimmingCharacters(in: .whitespaces).count == 0 {
            if self.locationString == "online" {
                self.view.makeToast("Please add Url")
            } else {
                self.view.makeToast("Please add address")
            }
            return
        }
        if self.startDateTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select start date")
            return
        }
        if self.endDateTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select end date")
            return
        }
        if self.startTimeTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select start time")
            return
        }
        if self.endTimeTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select end time")
            return
        }
        if self.timezoneTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please select Timezone")
            return
        }
        if self.sellTicketString == nil {
            self.view.makeToast("Please select sell Ticket")
            return
        }
        if self.sellTicketString == "yes" {
            if self.ticketAvailableTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
                self.view.makeToast("Please add ticket available")
                return
            }
            if self.ticketPriceTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
                self.view.makeToast("Please add ticket price")
                return
            }
        }
        var address = ""
        var onlineURL = ""
        if locationString == "online" {
            onlineURL = self.addressTextView.text
        } else {
            address = self.addressTextView.text
        }
        if let object = self.object {
            self.updateEvent(id: self.object?.id ?? 0, name: self.nameTextField.text ?? "", location: self.locationString ?? "", desc: self.descriptionTextView.text ?? "", startDate: self.startDateTextField.text ?? "", startTime: self.startTimeTextField.text ?? "", endDate: self.endDateTextField.text ?? "", endTime: self.endTimeTextField.text ?? "", timezone: self.timeZoneString ?? "", sellTicket: self.sellTicketString ?? "", onlineURL: onlineURL, ImageData: self.imageData ?? Data(), address: address, ticketAvailable: self.ticketAvailableTextField.text ?? "", ticketPrice: self.ticketPriceTextField.text ?? "")
        } else {
            self.createEvent(name: self.nameTextField.text ?? "", location: self.locationString ?? "", desc: self.descriptionTextView.text ?? "", startDate: self.startDateTextField.text ?? "", startTime: self.startTimeTextField.text ?? "", endDate: self.endDateTextField.text ?? "", endTime: self.endTimeTextField.text ?? "", timezone: self.timeZoneString ?? "", sellTicket: self.sellTicketString ?? "", onlineURL: onlineURL, ImageData: self.imageData ?? Data(), address: address, ticketAvailable: self.ticketAvailableTextField.text ?? "", ticketPrice: self.ticketPriceTextField.text ?? "")
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUpUI()
        if let object = self.object {
            self.setData(object)
        }
    }
    
    func setUpUI() {
        self.descriptionTextView.addPlaceholder("Description", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        self.addressTextView.addPlaceholder("Address", with: UIColor.hexStringToUIColor(hex: "9E9E9E"))
        self.sellTicketString = "no"
        self.sellTicketTextField.text = "No"
        self.sellTicketsStackView.isHidden = true
    }
    
    func textFieldSetUp() {
        self.nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.locationTextField.attributedPlaceholder = NSAttributedString(
            string: "Location",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.startDateTextField.attributedPlaceholder = NSAttributedString(
            string: "Start Date",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.endDateTextField.attributedPlaceholder = NSAttributedString(
            string: "End Date",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.startTimeTextField.attributedPlaceholder = NSAttributedString(
            string: "Start Time",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.endTimeTextField.attributedPlaceholder = NSAttributedString(
            string: "End Time",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.timezoneTextField.attributedPlaceholder = NSAttributedString(
            string: "Timezone",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.sellTicketTextField.attributedPlaceholder = NSAttributedString(
            string: "Sell Tickets",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.ticketAvailableTextField.attributedPlaceholder = NSAttributedString(
            string: "Tickets available",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.ticketPriceTextField.attributedPlaceholder = NSAttributedString(
            string: "Ticket Price",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
    }
    
    // Set Data
    func setData(_ object: Events) {
        self.timezoneTextField.text = object.timezone ?? ""
        let imageURL = URL.init(string: object.image ?? "")
        self.coverImageView.sd_setImage(with: imageURL, placeholderImage: R.image.imagePlacholder())
        self.imageData = self.coverImageView.image?.pngData()
        self.coverPlusImageView.isHidden = true
        self.uploadCoverLabel.isHidden = true
        self.nameTextField.text  = object.name ?? ""
        self.descriptionTextView.text = object.desc ?? ""
        self.startDateTextField.text = object.start_date ?? ""
        self.endDateTextField.text = object.end_date ?? ""
        self.startTimeTextField.text = object.start_time ?? ""
        self.endTimeTextField.text = object.end_time ?? ""
        self.id = object.id ?? 0
        if object.online_url == nil {
            self.addressTextView.text = object.real_address ?? ""
            self.locationString = "real"
            self.locationTextField.text = "Real Location"
        } else {
            self.addressTextView.text = object.online_url ?? ""
            self.locationString = "online"
            self.locationTextField.text = "Online"
        }
        if object.available_tickets == 0 {
            self.sellTicketString = "no"
            self.sellTicketTextField.text = "No"
        } else {
            self.sellTicketsStackView.isHidden = false
            self.sellTicketString = "yes"
            self.sellTicketTextField.text = "Yes"
            self.ticketAvailableTextField.text = "\(object.available_tickets ?? 0)"
            self.ticketPriceTextField.text =  "\(object.ticket_price ?? 0)"
        }
    }
    
    // Set Date Picker View
    func setDatePickerView(tag: Int) {
        let datePickerView = DatePickerView.init(frame: self.view.bounds)
        datePickerView.tag = tag
        datePickerView.delegate = self
        self.view.addSubview(datePickerView)
        self.view.bringSubviewToFront(datePickerView)
    }
    
    // Set Time Picker View
    func setTimePickerView(tag: Int) {
        let timePickerView = TimePickerView.init(frame: self.view.bounds)
        timePickerView.tag = tag
        timePickerView.delegate = self
        self.view.addSubview(timePickerView)
        self.view.bringSubviewToFront(timePickerView)
    }
    
    // removeSubView
    func removeSubView(tag: Int) {
        for subview in (self.view.subviews) {
            if subview.tag == tag {
                subview.removeFromSuperview()
            }
        }
    }
    
    private func createEvent(name: String, location: String, desc: String, startDate: String, startTime: String, endDate: String, endTime: String, timezone: String, sellTicket: String, onlineURL: String, ImageData: Data, address: String, ticketAvailable: String, ticketPrice: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let params = [
                API.Params.AccessToken: accessToken,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key,
                API.Params.Name: name,
                API.Params.location: location,
                API.Params.desc: desc,
                API.Params.start_date:startDate,
                API.Params.start_time:startTime,
                API.Params.end_date:endDate,
                API.Params.end_time : endTime,
                API.Params.timezone:timezone,
                API.Params.sell_tickets:sellTicket,
                API.Params.online_url:onlineURL,
                API.Params.real_address:address,
                API.Params.ticket_price: ticketPrice,
                API.Params.available_tickets: ticketAvailable
            ] as [String : Any]
            
            Async.background {
                EventManager.instance.createEvent(params: params, image: ImageData) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                let message = success?["message"] as? String
                                self.view.makeToast(message ?? "")
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func updateEvent(id: Int, name: String, location: String, desc: String, startDate: String, startTime: String, endDate: String, endTime: String, timezone: String, sellTicket: String, onlineURL: String, ImageData: Data, address: String, ticketAvailable: String, ticketPrice: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            let params = [
                
                API.Params.AccessToken: accessToken,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key,
                API.Params.Id: id,
                API.Params.Name: name,
                API.Params.location: location,
                API.Params.desc: desc,
                API.Params.start_date:startDate,
                API.Params.start_time:startTime,
                API.Params.end_date:endDate,
                API.Params.end_time : endTime,
                API.Params.timezone:timezone,
                API.Params.sell_tickets:sellTicket,
                API.Params.online_url:onlineURL,
                API.Params.real_address:address,
                API.Params.ticket_price: ticketPrice,
                API.Params.available_tickets: ticketAvailable
            ] as [String : Any]
            
            Async.background {
                EventManager.instance.updateEvent(params: params, image: ImageData) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                let message = success?["message"] as? String
                                self.view.makeToast(message ?? "")
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: UIImagePickerControllerDelegate Methods
extension CreateEventVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String, mediaType == kUTTypeMovie as String, let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let thumbnailImage = self.thumbnailImageForVideo(url: videoURL)
            self.videoImageView.image = thumbnailImage
            self.videoPlusImageView.isHidden = true
            do {
                let videoData = try Data(contentsOf: videoURL)
                self.videoData = videoData
            } catch {
                print("Error getting video data: \(error)")
            }
        } else {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.coverImageView.image = image
            self.imageData = image.pngData() ?? Data()
            self.coverPlusImageView.isHidden = true
            self.uploadCoverLabel.isHidden = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageForVideo(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let time = CMTime(seconds: 2, preferredTimescale: 1)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            return thumbnailImage
        } catch {
            print("Error getting thumbnail image: \(error)")
            return nil
        }
    }
    
}

// MARK: DatePickerViewDelegate Methods
extension CreateEventVC: DatePickerViewDelegate {
    
    func datePickerOkButtonAction(view: DatePickerView, sender: UIButton, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if view.tag == 1001 {
            self.startDateTextField.text = formatter.string(from: date)
        } else {
            self.endDateTextField.text = formatter.string(from: date)
        }
        self.removeSubView(tag: view.tag)
    }
    
    func datePickerCancelButtonAction(view: DatePickerView, sender: UIButton) {
        self.removeSubView(tag: view.tag)
    }
    
}

// MARK: TimePickerViewDelegate Methods
extension CreateEventVC: TimePickerViewDelegate {
    
    func timePickerOkButtonAction(view: TimePickerView, sender: UIButton, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if view.tag == 1002 {
            self.startTimeTextField.text = formatter.string(from: date)
        } else {
            self.endTimeTextField.text = formatter.string(from: date)
        }
        self.removeSubView(tag: view.tag)
    }
    
    func timePickerCancelButtonAction(view: TimePickerView, sender: UIButton) {
        self.removeSubView(tag: view.tag)
    }
    
}

// MARK: didSelectTimeZoneDelegate Methods
extension CreateEventVC: didSelectTimeZoneDelegate {
    
    func didSelectTimeZone(timeZone: String, name: String, index: Int) {
        self.timezoneTextField.text = name
        self.timeZoneString = timeZone
    }
    
}
