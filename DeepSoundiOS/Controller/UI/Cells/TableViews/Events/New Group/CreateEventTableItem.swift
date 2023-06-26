//
//  CreateEventTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 23/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CreateEventTableItem: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var ticketAvailableTextField: UITextField!
    @IBOutlet weak var sellTicketsStackView: UIStackView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var sellTicketBtn: UIButton!
    @IBOutlet weak var timezoneBtn: UIButton!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addressTextVIew: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var image:Data?
    var locationSTring:String?
    var timeZoneString:String?
    var sellTicketString:String?
    var vc: CreateEventVC?
    var id:Int?
    private let imagePickerController = UIImagePickerController()
    let datePicker = UIDatePicker()
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        eventImage.addGestureRecognizer(tap)
        self.startDateTextField.delegate = self
        self.endDateTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.endTimeTextField.delegate = self
//        startTimePicker()
    }
    func bind(_ object:[String:Any]?){
        if object != nil{
            let id = object?["id"] as? Int
            let image = object?["image"] as? String
            let name = object?["name"] as? String
            let desc = object?["desc"] as? String
            let address = object?["real_address"] as? String
            let onlineURL = object?["online_url"] as? String
            let startDate = object?["start_date"] as? String
            let startTime = object?["start_time"] as? String
            let endDate = object?["end_date"] as? String
            let endTime = object?["end_time"] as? String
            let timeZone = object?["timezone"] as? String
            let availableTickets = object?["available_tickets"] as? Int
            let ticketPrice = object?["ticket_price"] as? Int
            let ImageURL = URL.init(string: image ?? "")
            self.eventImage!.sd_setImage(with: ImageURL , placeholderImage:R.image.imagePlacholder())
            self.image = self.eventImage.image?.pngData()
            self.nameTextField.text  = name ?? ""
            self.descriptionTextView.text = desc ?? ""
            self.startDateTextField.text = startDate ?? ""
            self.endDateTextField.text = endDate ?? ""
            self.startTimeTextField.text = startTime ?? ""
            self.endTimeTextField.text = endTime ?? ""
            self.id = id ?? 0
           
            if onlineURL == nil{
                self.addressTextVIew.text = address ?? ""
                self.locationSTring = "real"
                self.locationBtn.setTitle("Real Location", for: .normal)
                
            }else{
                self.addressTextVIew.text = onlineURL ?? ""
                self.locationSTring = "online"
                self.locationBtn.setTitle("Online", for: .normal)
            }
            if availableTickets == 0{
                self.sellTicketString = "no"
                self.sellTicketBtn.setTitle("No", for: .normal)
                
            }else{
                self.sellTicketString = "yes"
                self.sellTicketBtn.setTitle("Yes", for: .normal)
                self.ticketAvailableTextField.text = "\(availableTickets ?? 0)"
                self.ticketPriceTextField.text =  "\(ticketPrice ?? 0)"
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.startDateTextField{
            startDatePicker()
        }else if textField == self.endDateTextField{
            endDatePicker()
        }else if textField == self.startTimeTextField{
            startTimePicker()
        }else if textField == self.endTimeTextField{
            endTimePicker()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.SelectImage()
    }
    func startDatePicker(){
       datePicker.datePickerMode = .date
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneStartDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

     startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = datePicker

    }
    func endDatePicker(){
       datePicker.datePickerMode = .date

      //ToolBar
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEndDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

     endDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = datePicker

    }
    func startTimePicker(){
       datePicker.datePickerMode = .time

      //ToolBar
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneStartTimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

     startTimeTextField.inputAccessoryView = toolbar
        startTimeTextField.inputView = datePicker

    }
    func endTimePicker(){
       datePicker.datePickerMode = .time

      //ToolBar
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEndTimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

     endTimeTextField.inputAccessoryView = toolbar
        endTimeTextField.inputView = datePicker

    }

     @objc func doneStartDatePicker(){

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
        startDateTextField.text = formatter.string(from: datePicker.date)
        self.vc?.view.endEditing(true)
    }
    @objc func doneEndDatePicker(){

     let formatter = DateFormatter()
     formatter.dateFormat = "yyyy-MM-dd"
       endDateTextField.text = formatter.string(from: datePicker.date)
       self.vc?.view.endEditing(true)
   }
    @objc func doneStartTimePicker(){

     let formatter = DateFormatter()
     formatter.dateFormat = "HH:mm:ss"
       startTimeTextField.text = formatter.string(from: datePicker.date)
       self.vc?.view.endEditing(true)
   }
    @objc func doneEndTimePicker(){

     let formatter = DateFormatter()
     formatter.dateFormat = "HH:mm:ss"
       endTimeTextField.text = formatter.string(from: datePicker.date)
       self.vc?.view.endEditing(true)
   }

    @objc func cancelDatePicker(){
        self.vc?.view.endEditing(true)
     }
    
    @IBAction func timezonePressed(_ sender: Any) {
        let vc = R.storyboard.popups.selectTimeZoneVC()
        vc?.delegate = self
        self.vc?.present(vc!, animated: true, completion: nil)
    }
    @IBAction func sellTicketPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Sell Tickets", message: "", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Yes", style: .default) { action in
            log.verbose("YEs")
            self.sellTicketString = "yes"
            self.sellTicketBtn.setTitle("Yes", for: .normal)
            self.sellTicketsStackView.isHidden = false
        }
        let no = UIAlertAction(title: "No", style: .default) { action in
            log.verbose("No")
            self.sellTicketString = "no"
            self.sellTicketBtn.setTitle("No", for: .normal)
            self.sellTicketsStackView.isHidden = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func locationPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Location", message: "", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Online", style: .default) { action in
            log.verbose("YEs")
            self.locationSTring = "online"
            self.locationBtn.setTitle("Online", for: .normal)
            self.addressTextVIew.placeholder = "url"
        }
        let no = UIAlertAction(title: "Real Location", style: .default) { action in
            log.verbose("No")
            self.locationSTring = "real"
            self.locationBtn.setTitle("Real Location", for: .normal)
            self.addressTextVIew.placeholder = "Address"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
    }
    private func SelectImage(){
        let alert = UIAlertController(title: "", message: (NSLocalizedString("Select Source", comment: "")), preferredStyle: .alert)
        let camera = UIAlertAction(title: (NSLocalizedString("Camera", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.vc?.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: (NSLocalizedString("Gallery", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.vc?.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
    }
}
extension  CreateEventTableItem:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.eventImage.image = image
        self.image = image.pngData() ?? Data()
        self.vc?.dismiss(animated: true, completion: nil)
    }
}

extension  CreateEventTableItem:didSelectTimeZoneDelegate {
    func didSelectTimeZone(timeZone: String, name: String, index: Int) {
        self.timezoneBtn.setTitle(name, for: .normal)
        self.timeZoneString = timeZone
    }
}
