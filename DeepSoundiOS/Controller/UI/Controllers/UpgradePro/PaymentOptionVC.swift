//
//  PaymentOptionVC.swift
//  DeepSoundiOS
//
//  Created by Moghees on 21/10/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import PassKit
import Braintree
import Async
class PaymentOptionVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageArrary = [UIImage(named: "paypal"),UIImage(named: "googlepay"), UIImage(named: "applepay")]
    var optionArray = ["Paypal","Google Pay", "Apple Pay"]
    var paymentRequest = PKPaymentRequest()
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var selectedPakgeAmount = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PaymentOptionCell.nib, forCellReuseIdentifier: PaymentOptionCell.identifier)
        tableView.register(AddNewCardCell.nib, forCellReuseIdentifier: AddNewCardCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    func applePay(){
        let selectedIndex = selectedPakgeAmount
        let shoe = "Upgrade Pro"
        let paymentItem = PKPaymentSummaryItem.init(label: shoe, amount: NSDecimalNumber(value: selectedIndex))
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        paymentRequest.currencyCode = "USD"
        paymentRequest.countryCode = "US"
        paymentRequest.merchantIdentifier = ControlSettings.applyPayMerchchat
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
        paymentRequest.supportedNetworks = paymentNetworks
        paymentRequest.paymentSummaryItems = [paymentItem]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            print("canMakePayments")
            let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            applePayVC?.delegate = self
            self.present(applePayVC!, animated: true, completion: nil)
        } else {
//                        displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
       
    }
    
    func payPal() {
        braintreeClient = BTAPIClient(authorization: ControlSettings.paypalAuthorizationToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        
        let request = BTPayPalCheckoutRequest(amount: "\(ControlSettings.upgradePaymentAmount ?? 0.0)")
        request.currencyCode = "USD"
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                self.callPayPalApi()
//                let email = tokenizedPayPalAccount.email
//                let firstName = tokenizedPayPalAccount.firstName
//                let lastName = tokenizedPayPalAccount.lastName
//                let phone = tokenizedPayPalAccount.phone
//                let billingAddress = tokenizedPayPalAccount.billingAddress
//                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                
                
                
            } else if let error = error {
                log.verbose("error = \(error.localizedDescription ?? "")")
            } else {
                log.verbose("error = \(error?.localizedDescription ?? "")")
            }
        }
    }
    func callPayPalApi(){
        PaymentManager.instance.getPaypalTopUp(AccessToken: AppInstance.instance.accessToken!, price: "\(selectedPakgeAmount)") { success, sessionError, error in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog {
                        
                        let succesMsg = success
                        print(succesMsg)
                        self.view.makeToast((NSLocalizedString(succesMsg ?? "", comment: "")))
                        self.navigationController?.popViewController(animated: true)
                     
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
    }
    

   
}
extension PaymentOptionVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return optionArray.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentOptionCell.identifier) as! PaymentOptionCell
            cell.imgOption.image = imageArrary[indexPath.row]
            cell.lblOption.text =  optionArray[indexPath.row]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddNewCardCell.identifier) as! AddNewCardCell
            return cell
       
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            
            if indexPath.row == 0{
                payPal()
            }
            else if indexPath.row == 1{
                
            }
           else {
                applePay()
            }
            
        }
        else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PayVC") as! PayVC
            vc.sender = "CreditCard"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
extension PaymentOptionVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        log.verbose("Authorize")
    }
}
