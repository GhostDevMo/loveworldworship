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
    var object: Events?
    var isJoined = false
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
    
    func bind(object: Events) {
        self.object = object
        self.id = object.id
        self.userID = object.user_data?.dataValue?.id
        self.url = object.url
        self.ticketPrice = Double(object.ticket_price ?? 0)
        if self.userID == AppInstance.instance
            .userId ?? 0 {
            self.joinTicketStack.isHidden = true
        }else{
            self.joinTicketStack.isHidden = false
        }
        self.titleLabel.text = object.name
        self.userNameLabel.text = "@\(object.user_data?.dataValue?.username ?? "")"
        self.eventdetailDesctionLabel.text = object.desc?.htmlAttributedString
        self.fromToDate.text = "\(object.start_date ?? "")(\(object.start_time ?? "")) - \(object.end_time ?? "")"
        self.ticketsAvailableLAbel.text = "\(object.available_tickets ?? 0) Tickets Available"
        if object.online_url == nil {
            self.urlLabel.text = object.real_address?.htmlAttributedString?.replacingOccurrences(of: "<br>", with: "")
        }else{
            self.urlLabel.text = object.online_url
        }
        
        let url = URL.init(string: object.image ?? "")
        let ProfileIamgeURL = URL.init(string: object.user_data?.dataValue?.avatar ?? "")
        self.detailEventImage.sd_setImage(with:  ProfileIamgeURL, placeholderImage:R.image.imagePlacholder())
        self.bannerImage.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
        if object.is_joined == 0 {
            self.joinBtn.setTitle("Join", for: .normal)
            self.joinBtn.backgroundColor = .ButtonColor.withAlphaComponent(0.25)
            self.joinBtn.setTitleColor(.mainColor, for: .normal)
            self.isJoined = false
        }else{
            self.joinBtn.setTitle("Joined", for: .normal)
            self.joinBtn.backgroundColor = .ButtonColor
            self.joinBtn.setTitleColor(.white, for: .normal)
            self.isJoined = true
        }
        if object.ticket_price == 0 {
            self.buyTicketBtn.isHidden = true
        }else{
            self.buyTicketBtn.isHidden = false
        }
    }
    
    @IBAction func buyTicketPressed(_ sender: UIButton) {
        if Double(AppInstance.instance.userProfile?.data?.wallet ?? "0.0")! < self.ticketPrice ?? 0.0 {
            self.vc?.view.makeToast("Sorry You cannot buy because there is not enough balance in the wallet")
        }else{
            self.buyTicket(id: self.id ?? 0)
        }
        
    }
    
    @IBAction func joinedPressed(_ sender: UIButton) {
        if self.isJoined {
            self.joinBtn.setTitle("Join", for: .normal)
            self.joinBtn.backgroundColor = .ButtonColor.withAlphaComponent(0.25)
            self.joinBtn.setTitleColor(.mainColor, for: .normal)
            self.isJoined = false
            self.joinUnjoin(id:self.id ?? 0, type: "unjoin")
        }else{
            self.joinBtn.setTitle("Joined", for: .normal)
            self.joinBtn.backgroundColor = .ButtonColor
            self.joinBtn.setTitleColor(.white, for: .normal)
            self.isJoined = true
            self.joinUnjoin(id:self.id ?? 0, type: "join")
        }
    }
    
    private func joinUnjoin(id: Int, type: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
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
    
   
