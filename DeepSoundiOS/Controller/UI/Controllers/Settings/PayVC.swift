

import UIKit
import Alamofire
import Async
import DeepSoundSDK
import BraintreeDropIn
import Braintree

class PayVC: BaseVC,UITextFieldDelegate  {
    
    @IBOutlet weak var cardView: UIView!
    var sender:String?
    //    var amount: String?
    
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    
    @IBOutlet weak var continueLabel: UIButton!
    var payType:String? = ""
    var Description:String? = ""
    var amount:String? = ""
    var memberShipType:Int? = 0
    var credits:Int? = 0
    var paymentType:String? = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yearTextField.delegate = self
        self.setupUI()
    }
    private func setupUI(){
        //        self.cardView.setGradientBackground(colorOne: .Main_StartColor, colorTwo: .Main_EndColor, horizontal: true)
        //        self.continueLabel.backgroundColor = .Button_StartColor
        self.creditLabel.text = NSLocalizedString("Credit Card", comment: "Credit Card")
        self.cardNumberTextField.placeholder =  NSLocalizedString("Enter your card number", comment: "Enter your card number")
        self.yearTextField.placeholder = NSLocalizedString("MMYY", comment: "MMYY")
        cvvTextField.placeholder = NSLocalizedString("CVV", comment: "CVV")
        continueLabel.setTitle(NSLocalizedString("Continue", comment: "Continue"), for: .normal)
    }
    @IBAction func continuePressed(_ sender: Any) {
        if cardNumberTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter card number")
        }else if yearTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter expiry date.")
        }else if cvvTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter CVV.")
        }else{
            if self.sender == "AuthorizeNet" {
                print("AuthorizeNet")
                authorizeNetApi()
            }else{
                self.getStipeToken()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        hideNavigation(hide: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        hideNavigation(hide: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    private func getStipeToken(){
        self.showProgressDialog(text: "Loading...")
//        let stripeCardParams = STPCardParams()
//        stripeCardParams.number = self.cardNumberTextField.text
//        let expiryParameters = yearTextField.text?.components(separatedBy: "/")
//        stripeCardParams.expMonth = UInt(expiryParameters?.first ?? "0") ?? 0
//        stripeCardParams.expYear = UInt(expiryParameters?.last ?? "0") ?? 0
//        stripeCardParams.cvc = cvvTextField.text
//        let config = STPPaymentConfiguration.shared
//        let stpApiClient = STPAPIClient.init(configuration: config)
//        stpApiClient.createToken(withCard: stripeCardParams) { (token, error) in
//            if error == nil {
//                Async.main({
//                    log.verbose("Token = \(token?.tokenId)")
//                    self.payStipe(stripeToken: token?.tokenId ?? "")
//                })
//            } else {
//                self.dismissProgressDialog {
//                    self.view.makeToast(error?.localizedDescription ?? "")
//                    log.verbose("Error = \(error?.localizedDescription ?? "")")
//                }
//            }
//        }
    }
    
    private func payStipe(stripeToken:String){
//        tok_visa
//        if Connectivity.isConnectedToNetwork(){
//            let accessToken = AppInstance.instance.accessToken ?? ""
//            Async.background({
//                PaymentManager.instance.PayStripe(AccessToken: accessToken, Token: stripeToken) { success, sessionError, error in
//                    if success != nil{
//                        Async.main({
//                            self.navigationController?.popViewController(animated: true)
//                        })
//                    }else if sessionError != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                self.view.makeToast(sessionError ?? "")
//                                log.error("sessionError = \(sessionError ?? "")")
//                            }
//                        })
//                    }else {
//                        Async.main({
//                            self.dismissProgressDialog {
//                                self.view.makeToast(error?.localizedDescription ?? "")
//                                log.error("error = \(error?.localizedDescription ?? "")")
//                            }
//                        })
//                    }
//                }
//            })
//        }else{
//            log.error("internetError = \(InterNetError)")
//            self.view.makeToast(InterNetError)
//        }
    }
    func authorizeNetApi()  {
        self.showProgressDialog(text: "Loading...")
        let expiryParameters = yearTextField.text?.components(separatedBy: "/")
        let expMonth = UInt(expiryParameters?.first ?? "0") ?? 0
        let expYear = UInt(expiryParameters?.last ?? "0") ?? 0
        PaymentManager.instance.getAuthorizenetToken(AccessToken: AppInstance.instance.accessToken!, card_number: cardNumberTextField.text ?? "", card_month: "\(expMonth)", card_cvc: cvvTextField.text ?? "", card_year: "\(expYear)", price: amount ?? "") { success, sessionError, error in
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
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        let currentText = textField.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        textField.text = updatedText
        let numberOfCharacters = updatedText.count
        if numberOfCharacters == 2 {
            textField.text?.append("/")
        }
        return false
    }
}



