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
class CreateEventVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    var object = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    private func setupUI(){
        self.tableView.register(CreateEventTableItem.nib, forCellReuseIdentifier: CreateEventTableItem.identifier)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateEventTableItem
        if cell?.image == nil {
            self.view.makeToast("Please select Image")
        }else if cell?.nameTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter name")
        }else if cell?.descriptionTextView.text.isEmpty ?? false{
            self.view.makeToast("Please enter description")
        }else if cell?.locationSTring == nil{
         self.view.makeToast("Please select location")
        }else if cell?.startDateTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please select start date")
        }else if cell?.endDateTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please select end date")
        }else if cell?.startTimeTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please select start time")
        }else if cell?.endTimeTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please select end time")
        }else if cell?.sellTicketString == nil{
            self.view.makeToast("Please select sell Ticket")
        }else{
            if cell?.sellTicketString == "yes"{
                if cell?.ticketAvailableTextField.text?.isEmpty ?? false{
                    self.view.makeToast("Please add ticket available")
                }else if cell?.ticketPriceTextField.text?.isEmpty ?? false{
                    self.view.makeToast("Please add ticket price")
                }else{
                    if cell?.locationSTring == "online"{
                        if cell?.addressTextVIew.text.isEmpty ?? false{
                            self.view.makeToast("Please add Url")
                        }else {
                            if self.object != nil{
                                self.updateEvent(id:cell?.id ?? 0,name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: cell?.addressTextVIew.text ?? "", ImageData: cell?.image ?? Data(),address:"",ticketAvailable: cell?.ticketAvailableTextField.text ?? "",ticketPrice: cell?.ticketPriceTextField.text ?? "")
                            }else{
                                self.createEvent(name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: cell?.addressTextVIew.text ?? "", ImageData: cell?.image ?? Data(),address:"",ticketAvailable: cell?.ticketAvailableTextField.text ?? "",ticketPrice: cell?.ticketPriceTextField.text ?? "")
                            }
                           
                        }
                    }
                    else if cell?.locationSTring == "real"{
                        if cell?.addressTextVIew.text.isEmpty ?? false{
                            self.view.makeToast("Please add address")
                        }else{
                            if self.object != nil{
                                self.updateEvent(id:cell?.id ?? 0,name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: "", ImageData: cell?.image ?? Data(),address:cell?.addressTextVIew.text ?? "",ticketAvailable: cell?.ticketAvailableTextField.text ?? "",ticketPrice: cell?.ticketPriceTextField.text ?? "")
                            }else{
                                self.createEvent(name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: "", ImageData: cell?.image ?? Data(),address:cell?.addressTextVIew.text ?? "",ticketAvailable: cell?.ticketAvailableTextField.text ?? "",ticketPrice: cell?.ticketPriceTextField.text ?? "")
                            }
                          
                        }
                    }
                }
            }else{
                if cell?.locationSTring == "online"{
                    if cell?.addressTextVIew.text.isEmpty ?? false{
                        self.view.makeToast("Please add Url")
                    }else {
                        if self.object != nil{
                            self.updateEvent(id:cell?.id ?? 0,name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: cell?.addressTextVIew.text ?? "", ImageData: cell?.image ?? Data(),address:"",ticketAvailable:  "",ticketPrice:  "")
                        }else{
                            self.createEvent(name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: cell?.addressTextVIew.text ?? "", ImageData: cell?.image ?? Data(),address:"",ticketAvailable:  "",ticketPrice:  "")
                        }
                       
                    }
                }
                else if cell?.locationSTring == "real"{
                    if cell?.addressTextVIew.text.isEmpty ?? false{
                        self.view.makeToast("Please add address")
                    }else{
                        if self.object != nil{
                            self.updateEvent(id:cell?.id ?? 0,name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: "", ImageData: cell?.image ?? Data(),address:cell?.addressTextVIew.text ?? "",ticketAvailable: "",ticketPrice: "")
                        }else{
                            self.createEvent(name: cell?.nameTextField.text ?? "", location: cell?.locationSTring ?? "", desc: cell?.descriptionTextView.text ?? "", startDate: cell?.startDateTextField.text ?? "", startTime: cell?.startTimeTextField.text ?? "", endDate: cell?.endDateTextField.text ?? "", endTime: cell?.endTimeTextField.text ?? "", timezone: cell?.timeZoneString ?? "", sellTicket: cell?.sellTicketString ?? "", onlineURL: "", ImageData: cell?.image ?? Data(),address:cell?.addressTextVIew.text ?? "",ticketAvailable: "",ticketPrice: "")
                        }
                      
                    }
                }
            }
        }
    }
    private func createEvent(name:String,location:String,desc:String,startDate:String,startTime:String,endDate:String,endTime:String,timezone:String,sellTicket:String,onlineURL:String,ImageData:Data,address:String,ticketAvailable:String,ticketPrice:String){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.createEvent(AccessToken: accessToken, name: name, location: location, Desc: desc, Startdate: startDate, startTime: startTime, endDate: endDate, endTime: endTime, timezone: timezone, SellTicket: sellTicket, onlineURL: onlineURL, image: ImageData,address: address,ticketAvailable: ticketAvailable,ticketPrice: ticketPrice) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                               let message = success?["message"] as? String
                                self.view.makeToast(message ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }

            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func updateEvent(id:Int,name:String,location:String,desc:String,startDate:String,startTime:String,endDate:String,endTime:String,timezone:String,sellTicket:String,onlineURL:String,ImageData:Data,address:String,ticketAvailable:String,ticketPrice:String){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.updateEvent(AccessToken: accessToken, id: id,name: name, location: location, Desc: desc, Startdate: startDate, startTime: startTime, endDate: endDate, endTime: endTime, timezone: timezone, SellTicket: sellTicket, onlineURL: onlineURL, image: ImageData,address: address,ticketAvailable: ticketAvailable,ticketPrice: ticketPrice) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                               let message = success?["message"] as? String
                                self.view.makeToast(message ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }

            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

extension CreateEventVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateEventTableItem.identifier) as? CreateEventTableItem
        cell?.vc = self
        cell?.bind(object)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
