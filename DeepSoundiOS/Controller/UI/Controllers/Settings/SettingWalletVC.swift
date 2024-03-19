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
import Braintree
import PassKit
import Razorpay
import SafariServices
import PaystackCheckout
import AuthorizeNetAccept
import CFSDK
import Toast_Swift
import SDWebImage

class SettingWalletVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountTextFieldView: UIView!
    
    // MARK: - Properties
    
    var status: Bool = false
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    var paymentRequest = PKPaymentRequest()
    private var razorpay: RazorpayCheckout?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Continue Button Action
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let value = Int(self.amountTextField.text ?? "0")
        if (value ?? 0) <= 0 {
            self.view.makeToast("Amount should be greater than 0.")
            return
        }
        let paymentOptionPopupVC = R.storyboard.popups.paymentOptionPopupVC()
        paymentOptionPopupVC?.delegate = self
        self.present(paymentOptionPopupVC!, animated: true, completion: nil)
    }
    
}
    
// MARK: - Helper Functions

extension SettingWalletVC {
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.setUserData()
        self.razorpay = RazorpayCheckout.initWithKey(AppInstance.instance.optionsData?.razorpay_key_id ?? "", andDelegate: self)
    }
    
    func textFieldSetUp() {
        self.amountTextField.attributedPlaceholder = NSAttributedString(
            string: "Amount",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "9E9E9E") as Any]
        )
        self.amountTextField.delegate = self
    }
    
    func setUserData() {
        AppInstance.instance.fetchUserProfile(isNew: true) { success in
            if success {
                let url = URL.init(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
                self.profileImage.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
                self.nameLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
                self.userNameLabel.text = "@" + (AppInstance.instance.userProfile?.data?.username ?? "")
                self.balanceLabel.text = String(Double(AppInstance.instance.userProfile?.data?.wallet ?? "")?.rounded() ?? 0.0)
                self.amountTextField.text = ""
            }
        }
    }
    
    func callPayPalApi() {
        PaymentManager.instance.getPaypalTopUp(AccessToken: AppInstance.instance.accessToken!, price: amountTextField.text ?? "") { success, sessionError, error in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog {
                        let succesMsg = success
                        print(succesMsg ?? "")
                        self.view.makeToast((NSLocalizedString(succesMsg ?? "", comment: "")))
                        self.setUserData()
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
    
    func initializeCashFree(phone:String, name:String, email:String) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        Async.background({            
            PaymentManager.instance.initializeCashFree(AccessToken: accessToken, type: "initialize", phone: phone, name: name, email: email, price:amount ) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let cashFreeLink = success?["cashfree_link"] as? String
                            print("cashFree link = \(cashFreeLink ?? "")")
                            let vc = R.storyboard.settings.payStackWebViewVC()
                            vc?.delegate = self
                            vc?.webLink = cashFreeLink
                            vc?.paymentType = .cashfree
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
                            self.setUserData()
                        }
                    })
                }else if sessionError != nil {
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
  
    func callRazorpay(paymendID: String) {
        PaymentManager.instance.getRazorPay(AccessToken: AppInstance.instance.accessToken!, payment_id: paymendID, merchant_amount: "\(amountTextField.text ?? "")", price: "\(amountTextField.text ?? "")") { success, sessionError, error in
            if success != nil {
                Async.main {
                    self.dismissProgressDialog {
                        let succesMsg = success
                        //self.startSecurionPay(securiontoken: token ?? "" )
                        print(succesMsg ?? "")
                        self.view.makeToast((NSLocalizedString(succesMsg ?? "", comment: "")))
                        self.setUserData()
                    }
                }
            }else if sessionError != nil {
                Async.main {
                    self.dismissProgressDialog {
                        self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                        log.error("sessionError = \(sessionError ?? "")")
                    }
                }
            }else {
                Async.main {
                    self.dismissProgressDialog {
                        self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                        log.error("error = \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
    }

    func initializePayStack(email: String) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        
        let params = [
            API.Params.AccessToken: accessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.type : "initialize",
            API.Params.price : amount,
            API.Params.Email: email
        ] as [String : Any]
        
        Async.background({
            PaymentManager.instance.initializePayStack(params: params) { success, sessionError, error in
                if success != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            let vc = R.storyboard.settings.payStackWebViewVC()
                            vc?.delegate = self
                            vc?.webLink = success ?? ""
                            vc?.paymentType = .paystack
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                    })
                } else if sessionError != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    })
                } else {
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

    func payPayStack(reference:String) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let amount = self.amountTextField.text ?? ""
        Async.background({
            PaymentManager.instance.payPayStack(AccessToken: accessToken, type: "pay", reference: reference, price: amount) { success, sessionError, error in
                Async.main {
                    self.amountTextField.text = nil
                }
                if success != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(success ?? "")
                            self.setUserData()
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
    
    func applePay() {
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
    
    func startPaypalCheckout() {
        self.view.makeToast("Please Wait...")
        braintreeClient = BTAPIClient(authorization: ControlSettings.paypalAuthorizationToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        
        let request = BTPayPalCheckoutRequest(amount: self.amountTextField.text ?? "")
        request.currencyCode = "USD"
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                self.callPayPalApi()
            } else if let error = error {
                log.verbose("error = \(error.localizedDescription )")
            } else {
                log.verbose("error = \(error?.localizedDescription ?? "")")
            }
        }
    }
   
    func startRazorPay() {
        let options: [String:Any] = [
            "amount" : (Int(amountTextField.text ?? "") ?? 0)*100, //mandatory in paise like:- 1000 paise ==  10 rs
            "description": "purchase description",
            "image": UIImage(named: "CircleLogo")!,
            "name": "Deep Sound",
            "prefill": [
                "contact": "9797979797",
                "email": "foo@bar.com"
            ],
            "theme": [
                "color": "#FF9800"
            ]
        ]
        razorpay?.open(options, displayController: self)
    }
  
    func startSecurionPay(securiontoken: String){
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

// MARK: PaymentOptionPopupVCDelegate
extension SettingWalletVC: PaymentOptionPopupVCDelegate {
    
    func handlePaymentOptionTapped(paymentOption: String) {
        switch paymentOption {
        case "Paypal":
            self.startPaypalCheckout()
        case "Bank Transfer":
            guard let vc = R.storyboard.discover.bankTransferVC() else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        case "Credit Card":
            guard let vc = R.storyboard.settings.paymentCardVC() else { return }
            vc.amount = Int(self.amountTextField.text ?? "0") ?? 0
            vc.paymentType = .creditCard
            self.navigationController?.pushViewController(vc, animated: true)
        case "RazorPay":
            self.startRazorPay()
        case "Paystack":
            guard let vc = R.storyboard.settings.paystackPopupVC() else { return }
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        case "Cashfree":
            guard let vc = R.storyboard.settings.cashfreePopupVC() else { return }
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        case "SecurionPay":
            self.callSecurionTokenApi()
        case "AuthorizeNet":
            guard let vc = R.storyboard.settings.paymentCardVC() else { return }
            vc.paymentType = .authorizeNet
            vc.amount = Int(self.amountTextField.text ?? "0") ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        case "Apple Pay":
            self.applePay()
        case "Paysera":
            self.payseraPaymentGatewayAPI()
            break
        default:
            break;
        }
    }
    
}

// MARK: PaySera Setup
extension SettingWalletVC {
    
    func payseraPaymentGatewayAPI() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let sessionID = AppInstance.instance.accessToken ?? ""
            let amount = Int(self.amountTextField.text ?? "0") ?? 0
            Async.background {
                PaymentManager.instance.payseraWalletAPI(session_token: sessionID, amount: amount) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                if let urlSTR = success {
                                    if let newVC = R.storyboard.settings.payStackWebViewVC() {
                                        newVC.modalPresentationStyle = .overFullScreen
                                        newVC.modalTransitionStyle = .crossDissolve
                                        newVC.paymentType = .paysera
                                        newVC.webLink = urlSTR
                                        self.present(newVC, animated: true)
                                    }
                                }
                            }
                        })
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError)
                            log.verbose("SessionError = \(sessionError ?? "")")
                        }
                    } else {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

//MARK: Cash Free
extension SettingWalletVC: CashfreePopupVCDelegate {
    
    func handleCashfreePayNowButtonTap(name: String, email: String, phone: String) {
        self.initializeCashFree(phone: phone, name: name, email: email)
    }
    
}

//MARK: PayStack
extension SettingWalletVC: didSelectPaystackEmailDelegate, DidReceivePaystackReferenceIDDelegate {
    
    func didSelectPaystackEmail(email: String) {
        self.initializePayStack(email: email)
    }
    
    func didReceivePaystackReferenceID(refID: String) {
        self.payPayStack(reference: refID)
    }
    
}

//MARK: Apple Pay
extension SettingWalletVC: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        log.verbose("Authorize")
    }
    
}

//MARK: Razor Pay
extension SettingWalletVC: RazorpayPaymentCompletionProtocol {
    
    func onPaymentSuccess(_ payment_id: String) {
        print("Payment = \(payment_id)")
        self.callRazorpay(paymendID: payment_id)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Error", message: "\(code)\n\(str)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: Check Out
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

// MARK: UITextFieldDelegate Methods
extension SettingWalletVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case amountTextField:
            self.amountTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case amountTextField:
            self.amountTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}
