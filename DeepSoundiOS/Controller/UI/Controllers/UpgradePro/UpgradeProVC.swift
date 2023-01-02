//
//  UpgradeProVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 04/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
import BraintreeDropIn
import Braintree
import PassKit
import StoreKit

class UpgradeProVC: BaseVC {
    
    @IBOutlet weak var topLabel: UILabel!
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var paymentRequest = PKPaymentRequest()
    
    @IBOutlet weak var downloadSongsLabel: UILabel!
    @IBOutlet weak var spotlightLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var upgradeNowBtn: UIButton!
    
    var status:Bool? = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLabel.text = NSLocalizedString("Dicover more features with \(ControlSettings.appName) Pro Package", comment: "Dicover more features with DeepSound Pro Package")
        self.proLabel.text = NSLocalizedString("Pro Member", comment: "Pro Member")
        self.uploadLabel.text = NSLocalizedString("Upload unlimited songs", comment: "Upload unlimited songs")
        self.proLabel.text = NSLocalizedString("Pro badge", comment: "Pro badge")
        self.spotlightLabel.text = NSLocalizedString("Spotlight your songs(featured)", comment: "Spotlight your songs(featured)")
        self.downloadSongsLabel.text = NSLocalizedString("Download Songs", comment: "Download Songs")
        self.upgradeNowBtn.setTitle(NSLocalizedString("UPGRADE NOW", comment: "UPGRADE NOW"), for: .normal) 
        self.upgradeNowBtn.backgroundColor = .ButtonColor
        self.moneyLabel.textColor = .mainColor
        self.moneyLabel.text = "$\(ControlSettings.upgradeProAmount ?? 0.0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.largeTitleDisplayMode = .automatic
    }
    @IBAction func upgradeNowPressed(_ sender: Any) {
        
        
            let alert = UIAlertController(title: "", message: NSLocalizedString("Go Pro", comment: ""), preferredStyle: .actionSheet)
            let wallet = UIAlertAction(title: NSLocalizedString("Wallet", comment: "Wallet"), style: .default) { (action) in
                if Double(AppInstance.instance.userProfile?.data?.wallet ?? "0.0")! < ControlSettings.upgradePaymentAmount ?? 0.0 ?? 0.0{
                    self.view.makeToast("Sorry You cannot buy because there is not enough balance in the wallet")
                }else{
                    self.purchaseGOPro()
                }
            }
          
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
            alert.addAction(wallet)
           
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        
       
    }
    private func purchaseGOPro(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                UpgradeMemberShipManager.instance.purchase(AccessToken: accessToken, type: "go_pro") { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.upgradeMemberShip()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
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
   
    private func upgradeMemberShip(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                UpgradeMemberShipManager.instance.upgradeMemberShip(userId: userid, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? "")")
                                self.navigationController?.popViewController(animated: true)
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

