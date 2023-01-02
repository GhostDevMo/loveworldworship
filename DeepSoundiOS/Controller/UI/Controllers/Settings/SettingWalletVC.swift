//
//  SettingWalletVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
import BraintreeDropIn
import Braintree
import PassKit
import Razorpay
import SafariServices
import PaystackCheckout
import AuthorizeNetAccept

import CFSDK
class SettingWalletVC: BaseVC{
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var bottomUsernameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var status:Bool? = false
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var paymentRequest = PKPaymentRequest()
    private var razorpay:RazorpayCheckout?
    override func viewDidLoad() {
     
        
        razorpay = RazorpayCheckout.initWithKey(ControlSettings.razorPayInitialkey, andDelegate: self)
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI(){
        self.usernameLabel.text = AppInstance.instance.userProfile?.data?.username ?? ""
        self.bottomUsernameLabel.text = "@\(AppInstance.instance.userProfile?.data?.username ?? "")"
        self.balanceLabel.text = AppInstance.instance.userProfile?.data?.wallet ?? ""
        let url = URL.init(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    func callPayPalApi(){
        PaymentManager.instance.getPaypalTopUp(AccessToken: AppInstance.instance.accessToken!, price: amountTextField.text ?? "") { success, sessionError, error in
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
    func initializeCashFree(phone:String,name:String,email:String){
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        Async.background({
            
            PaymentManager.instance.initializeCashFree(AccessToken: accessToken, type: "initialize", phone: phone, name: name, email: email, price:amount ) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            var cashFreeLink = success?["cashfree_link"] as? String
                            print("cashFree link = \(cashFreeLink ?? "")")
                            let url = URL(string: cashFreeLink ?? "")!
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                
                                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                    print("Open url : \(success)")
                                })
                            }
                            
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
    }
    func callSecurionTokenApi() {
        self.showProgressDialog(text: "Loading...")
        PaymentManager.instance.getSecurionToken(AccessToken: AppInstance.instance.accessToken!, type: "initialize", price: amountTextField.text!) { success, sessionError, error in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog {
                        
                        let token = success
                        self.startSecurionPay(securiontoken: token ?? "" )
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
    func paySecurionPay(chargeID:String){
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        self.showProgressDialog(text: "Loading...")
        Async.background({
            PaymentManager.instance.getRazorPay(AccessToken: accessToken, payment_id: chargeID, merchant_amount: amount, price:amount) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            let succesMsg = success
                           
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
        })

    }
    func callRazorpay(paymendID:String){
        PaymentManager.instance.getRazorPay(AccessToken: AppInstance.instance.accessToken!, payment_id: paymendID, merchant_amount: "\(amountTextField.text ?? "")", price: "\(amountTextField.text ?? "")") { success, sessionError, error in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog {
                        
                        let succesMsg = success
                        //self.startSecurionPay(securiontoken: token ?? "" )
                        print(succesMsg)
                        self.view.makeToast((NSLocalizedString(succesMsg ?? "", comment: "")))
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
    func initializePayStack(email:String){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        Async.background({
            PaymentManager.instance.initializePayStack(AccessToken: accessToken, type: "initialize", email: email, price: amount) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let vc = R.storyboard.settings.webViewVC()
                            vc?.delegate = self
                            vc?.webLink = success ?? ""
                            self.navigationController?.pushViewController(vc!, animated: true)
                            
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
    }
    func payPayStack(reference:String){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        Async.background({
            PaymentManager.instance.payPayStack(AccessToken: accessToken, type: "pay", reference: reference, price: amount) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(success ?? "")
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
        })
    }
    @IBAction func paymentPressed(_ sender: Any) {
        let value = Int(self.amountTextField.text ?? "0")
        if value ?? 0 > 0{
            
                let alert = UIAlertController(title: "", message: NSLocalizedString("Select Payment Method", comment: "Select Payment Method"), preferredStyle: .actionSheet)
                let paypal = UIAlertAction(title: NSLocalizedString("Paypal", comment: "Paypal"), style: .default) { (action) in
                    self.startCheckout()
                }
                let bankTransfer = UIAlertAction(title: NSLocalizedString("Bank Transfer", comment: "Bank Transfer"), style: .default) { (action) in
                    let vc = R.storyboard.discover.bankTransferVC()
                    self.present(vc!, animated: true, completion: nil)
                }
                let CreditCard = UIAlertAction(title: NSLocalizedString("CreditCard", comment: "CreditCard"), style: .default) { (action) in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "PayVC") as! PayVC
                    vc.sender = "CreditCard"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                let razorPay = UIAlertAction(title: NSLocalizedString("RazorPay", comment: "RazorPay"), style: .default) { (action) in
                    self.startRazorPay()
                    
                }
                let payStack = UIAlertAction(title: NSLocalizedString("payStack", comment: "PayStack"), style: .default) { (action) in
                   
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "PaystackPopupVC") as! PaystackPopupVC
                    vc.delegate = self
                    self.navigationController?.present(vc, animated: true)
                }
                let Cashfree = UIAlertAction(title: NSLocalizedString("Cashfree", comment: "Cashfree"), style: .default) { (action) in
               
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "CashFreePopUpVC") as! CashFreePopUpVC
                    vc.delegate = self
                    self.navigationController?.present(vc, animated: true)
                    
                }
                let SecurionPay = UIAlertAction(title: NSLocalizedString("SecurionPay", comment: "SecurionPay"), style: .default) { (action) in
                    self.callSecurionTokenApi()
                    
                }
                let PayUmoney = UIAlertAction(title: NSLocalizedString("PayUmoney", comment: "PayUmoney"), style: .default) { (action) in
                    let vc = R.storyboard.discover.bankTransferVC()
                    self.present(vc!, animated: true, completion: nil)
                }
                let AuthorizeNet = UIAlertAction(title: NSLocalizedString("AuthorizeNet", comment: "AuthorizeNet"), style: .default) { (action) in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "PayVC") as! PayVC
                    vc.sender = "AuthorizeNet"
                    vc.amount = self.amountTextField.text
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let applePay = UIAlertAction(title:NSLocalizedString("Apple Pay", comment: "Apple Pay") , style: .default) { (action) in
                    self.applePay()
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
                if ControlSettings.IsPaypalEnabled{
                    alert.addAction(paypal)
                }
                if ControlSettings.isBankTransferEnabled{
                    alert.addAction(bankTransfer)
                }
                if ControlSettings.IsCreditEnabled{
                    alert.addAction(CreditCard)
                }
                if ControlSettings.IsRazorPayEnabled{
                    alert.addAction(razorPay)
                }
                if ControlSettings.IsPayStackEnabled{
                    alert.addAction(payStack)
                }
                
                if ControlSettings.IsCashFreeEnabled{
                    alert.addAction(Cashfree)
                }
               
                if ControlSettings.IsSecurionPayEnabled{
                    alert.addAction(SecurionPay)
                }
                if ControlSettings.IsAuthorizeEnabled{
                    alert.addAction(AuthorizeNet)
                }
            if ControlSettings.isApplePay ?? false{
                    alert.addAction(applePay)
                }
               
               
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            
            
        }else{
            self.view.makeToast("Amount should be greater than 0.")
        }
    }
    func applePay(){
        let selectedIndex = Double(self.amountTextField.text ?? "")
        let shoe = "Upgrade Pro"
        let paymentItem = PKPaymentSummaryItem.init(label: shoe, amount: NSDecimalNumber(value: selectedIndex!))
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
    func startCheckout() {
        braintreeClient = BTAPIClient(authorization: ControlSettings.paypalAuthorizationToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        
        let request = BTPayPalCheckoutRequest(amount: "\(ControlSettings.upgradePaymentAmount ?? 0.0)")
        request.currencyCode = "USD"
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                self.callPayPalApi()
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                
                
                
            } else if let error = error {
                log.verbose("error = \(error.localizedDescription ?? "")")
            } else {
                log.verbose("error = \(error?.localizedDescription ?? "")")
            }
        }
    }
    func startRazorPay(){
        let options: [String:Any] = [
            "amount" : amountTextField.text ?? "", //mandatory in paise like:- 1000 paise ==  10 rs
            "description": "purchase description",
            "image": "ss",
            "name": "Swift Series",
            "prefill": [
                "contact": "9797979797",
                "email": "foo@bar.com"
            ],
            "theme": [
                "color": "#F37254"
            ]
        ]
        razorpay?.open(options, displayController: self)
        
        
    }
    func startSecurionPay(securiontoken:String){
//        SecurionPay.shared.publicKey = ControlSettings.securionPayPublicKey
//        SecurionPay.shared.bundleIdentifier = ControlSettings.securionBundleID
//        SecurionPay.shared.showCheckoutViewController(
//            in: self,
//            checkoutRequest: CheckoutRequest(content: securiontoken))  { [weak self] result, error in
//            if let result = result {
//                log.verbose("Charge id: \(result.chargeId ?? "")")
//                self!.paySecurionPay(chargeID: result.chargeId ?? "")
//            } else if let error = error {
//                let alert = UIAlertController(title: "Error!", message: error.localizedMessage(), preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(title: "Payment cancelled!", message: "Try again", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
//            }
//        }
    }
    
}
extension SettingWalletVC: didInitializeCashFreeDelegate {
    func didInitializeCashFree(name: String, email: String, phoneNumber: String) {
        self.initializeCashFree(phone: phoneNumber, name: name, email: email)
    }
}
extension SettingWalletVC: didSelectPaystackEmailDelegate {
    func didSelectPaystackEmail(email: String) {
        self.initializePayStack(email: email)
    }
}
extension SettingWalletVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        log.verbose("Authorize")
    }
}
extension SettingWalletVC: RazorpayPaymentCompletionProtocol {
    func onPaymentSuccess(_ payment_id: String) {
        print("Payment = \(payment_id)")
        callRazorpay(paymendID: payment_id)
        let alert = UIAlertController(title: "Paid", message: "Payment Success", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Error", message: "\(code)\n\(str)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
extension SettingWalletVC :CheckoutProtocol {
    func onError(error: Error?) {
        view.makeToast("There was an error: \(error!.localizedDescription)")
    }
    
    func onSuccess(response: TransactionResponse) {
        view.makeToast("Payment successfull \(response.reference)")
    }
    
    func onDimissal() {
        view.makeToast("You dimissed the payment modal")
    }
    
}

extension SettingWalletVC :didReceivePaystackReferenceIDDelegate {
    func didReceivePaystackReferenceID(refID: String) {
        self.payPayStack(reference: refID)
    }
}
