//
//  EventDetailTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class EventDetailTableItem: UITableViewCell {
    
    @IBOutlet weak var buyTicketBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var joinTicketStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ticketsAvailableLAbel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var fromToDate: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var detailEventImage: UIImageView!
    @IBOutlet weak var eventdetailDesctionLabel: UILabel!
    @IBOutlet weak var locationImg: UIImageView!
    @IBOutlet weak var calenderImg: UIImageView!
    @IBOutlet weak var ticketImg: UIImageView!
    
    var vc:EventDetailVC?
    var userID:Int? = 0
    var object = [String:Any]()
    var isJoined:Bool? = false
    var id:Int? = 0
    var ticketPrice: Double? = 0
    var url:String? = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        calenderImg.tintColor = .ButtonColor
        locationImg.tintColor = .ButtonColor
        ticketImg.tintColor = .ButtonColor
        joinBtn.backgroundColor = .ButtonColor
        ticketsAvailableLAbel.textColor = .ButtonColor
        fromToDate.textColor = .ButtonColor
        urlLabel.textColor = .ButtonColor
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(object:[String:Any]) {
        self.object = object
        let id = object["id"] as? Int
        let eventName = object["name"] as? String
        let userData = object["user_data"] as? [String:Any]
        let userName = userData?["username"] as? String
        let description = object["desc"] as? String
        let eventStartDate = object["start_date"] as? String
        let eventStartTime = object["start_time"] as? String
        let eventEndDate = object["end_date"] as? String
        let availableTickets = object["available_tickets"] as? Int
        let ticketPrice = object["ticket_price"] as? Int
        let onlineUrl = object["online_url"] as? String
        let address = object["real_address"] as? String
        let image = object["image"] as? String
        let urlStr = object["url"] as? String
        
        let isJoined = object["is_joined"] as? Int
        let userdata = object["user_data"] as? [String:Any]
        let profileImage = userdata?["avatar"] as? String
      let userID = userdata?["id"] as? Int
        self.id = id ?? 0
        self.userID = userID ?? 0
        self.url = urlStr ?? ""
        self.ticketPrice = Double(ticketPrice ?? 0)
        if self.userID == AppInstance.instance
            .userId ?? 0{
            self.joinTicketStack.isHidden = true
        }else{
            self.joinTicketStack.isHidden = false
        }
        self.titleLabel.text = eventName
        self.userNameLabel.text = "@\(userName ?? "")"
        self.eventdetailDesctionLabel.text = description
        self.fromToDate.text = "\(eventStartDate ?? "")(\(eventStartTime ?? "")) - \(eventEndDate ?? "")"
        self.ticketsAvailableLAbel.text = "\(availableTickets ?? 0) Tickets Available"
        if onlineUrl == nil{
            self.urlLabel.text = address
        }else{
            self.urlLabel.text = onlineUrl
        }
        

        let url = URL.init(string:image ?? "")
        let ProfileIamgeURL = URL.init(string:profileImage ?? "")
        self.detailEventImage.sd_setImage(with:  ProfileIamgeURL , placeholderImage:R.image.imagePlacholder())
        self.bannerImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if isJoined == 0{
            self.joinBtn.setTitle("Join", for: .normal)
            self.joinBtn.backgroundColor = .white
            self.joinBtn.borderColorV = .ButtonColor
            self.joinBtn.borderWidthV = 1.5
            self.joinBtn.setTitleColor(.ButtonColor, for: .normal)
            self.isJoined = false
        }else{
            self.joinBtn.setTitle("Joined", for: .normal)
            self.joinBtn.backgroundColor = .ButtonColor
            self.joinBtn.borderColorV = .clear
            self.joinBtn.setTitleColor(.white, for: .normal)
            self.isJoined = true
        }
        if ticketPrice == 0{
            self.buyTicketBtn.isHidden = true
        }else{
            self.buyTicketBtn.isHidden = false
        }
    
    }
    
    
    @IBAction func morePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Event", message: "", preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "Share", style: .default) { action in
            log.verbose("Share")
            let myWebsite = NSURL(string:self.url ?? "")
                let shareAll = [ myWebsite]
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.vc?.view
            self.vc?.present(activityViewController, animated: true, completion: nil)
            
        }
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            log.verbose("Copy")
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.url ?? ""
            self.vc?.view.makeToast("Copied!!")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let edit = UIAlertAction(title: "Edit", style: .default) { action in
            log.verbose("Edit")
            let vc = R.storyboard.events.createEventVC()
            vc?.object = self.object
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
            
        }
        if userID ?? 0 == AppInstance.instance.userId ?? 0{
            alert.addAction(edit)
        }
        alert.addAction(share)
        alert.addAction(copy)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buyTicketPressed(_ sender: Any) {
        if Double(AppInstance.instance.userProfile?.data?.wallet ?? "0.0")! < self.ticketPrice ?? 0.0{
            self.vc?.view.makeToast("Sorry You cannot buy because there is not enough balance in the wallet")
        }else{
            self.buyTicket(id: self.id ?? 0)
        }
        
    }
    
    @IBAction func joinedPressed(_ sender: Any) {
        self.isJoined = !self.isJoined!
        if self.isJoined ?? false{
            self.joinBtn.setTitle("Join", for: .normal)
            self.joinBtn.backgroundColor = .white
            self.joinBtn.borderColorV = .systemOrange
            self.joinBtn.borderWidthV = 1.5
            self.joinBtn.setTitleColor(.systemOrange, for: .normal)
            self.isJoined = false
            self.joinUnjoin(id:self.id ?? 0, type: "unjoin")
        }else{
            self.joinBtn.setTitle("Joined", for: .normal)
            self.joinBtn.backgroundColor = .systemOrange
            self.joinBtn.borderColorV = .clear
            self.joinBtn.setTitleColor(.white, for: .normal)
            self.isJoined = true
            self.joinUnjoin(id:self.id ?? 0, type: "join")
        }
    }
    private func joinUnjoin(id:Int,type:String){
        if Connectivity.isConnectedToNetwork(){
            self.vc?.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.joinUnjoin(AccessToken: accessToken, id: id, type: type) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
                              
                                self.vc?.view.makeToast(success ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                
                                self.vc?.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                
                                self.vc?.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }

            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.vc?.view.makeToast(InterNetError)
        }
    }
    private func buyTicket(id:Int){
        if Connectivity.isConnectedToNetwork(){
            self.vc?.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.buyTicket(AccessToken: accessToken, id: id) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
                              
                                self.vc?.view.makeToast(success ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                
                                self.vc?.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                
                                self.vc?.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }

            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.vc?.view.makeToast(InterNetError)
        }
    }
}
    
   
