//
//  PurchaseButtonTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree
import Async
import DeepSoundSDK
import PassKit

class PurchaseButtonTableItem: UITableViewCell {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var dollarImage: UIImageView!
    @IBOutlet weak var buyBtn: UIButton!
    var vc:ShowAlbumVC?
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var albumID:String? = ""
    var price:Double? = 0.0
    var paymentRequest = PKPaymentRequest()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buyBtn.setTitle(NSLocalizedString("BUY", comment: "BUY"), for: .normal)
        self.bottomLabel.text = NSLocalizedString("You cannot listen to this list until you purchase it", comment: "You cannot listen to this list until you purchase it")
        
        self.buyBtn.backgroundColor = .ButtonColor
        self.dollarImage.tintColor = .mainColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buyBtn(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
             self.showAlert()
        }else{
            self.loginAlert()
        }
    }
    private func purchaseAlbumWallet(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                UpgradeMemberShipManager.instance.purchaseAlbum(AccessToken: accessToken, type: "buy_album", AlbumID: self.albumID ?? "") { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
//                                self.purchaseAlbum(albumID: self.albumID ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                self.vc?.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.vc?.dismissProgressDialog {
                                self.vc?.view.makeToast(error?.localizedDescription ?? "")
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
    private func purchaseAlbum(albumID:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            
            Async.background({
                AlbumManager.instance.PurchaseAlbum(AccessToken: accessToken, albumId: albumID, userID: userId, via: "PayPal") { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.vc?.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.vc?.view.makeToast(NSLocalizedString("Your Puchased Album", comment: "Your Puchased Album"))
                            }
                            
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            
                            self.vc?.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.vc?.view.makeToast(sessionError?.error ?? "")
                            }
                            
                            
                        })
                    }else {
                        Async.main({
                            
                            self.vc?.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.vc?.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                    }
                }
            })
        }else{
            
            self.vc?.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.vc?.view.makeToast(InterNetError)
            }
        }
    }
    private func showAlert (){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let wallet = UIAlertAction(title: NSLocalizedString("Wallet", comment: "Wallet"), style: .default) { (action) in
            log.verbose("Album ID = \(self.albumID)")
            if Double(AppInstance.instance.userProfile?.data?.wallet ?? "0.0")! < self.price ?? 0.0 ?? 0.0{
                self.vc?.view.makeToast("Sorry You cannot buy because there is not enough balance in the wallet")
            }else{
                log.verbose("Wallet")
                self.purchaseAlbumWallet()
            }
        
        }
       
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel")
, style: .destructive, handler: nil)
        alert.addAction(wallet)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil{
            self.vc?.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func loginAlert(){
             let alert = UIAlertController(title: NSLocalizedString("Login", comment: "Login")
, message: NSLocalizedString("Sorry you can not continue, you must log in and enjoy access to everything you want", comment: "Sorry you can not continue, you must log in and enjoy access to everything you want"), preferredStyle: .alert)
    let yes = UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .default) { (action) in
         self.vc?.appDelegate.window?.rootViewController = R.storyboard.login.main()
             }
             let no = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .cancel, handler: nil)
        
             alert.addAction(yes)
             alert.addAction(no)
        alert.popoverPresentationController?.sourceView = self
           
                 self.vc?.present(alert, animated: true, completion: nil)
                 
             
         }
   
  
    
}
