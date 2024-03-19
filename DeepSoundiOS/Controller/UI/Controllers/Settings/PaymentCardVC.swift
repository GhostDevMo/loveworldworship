//
//  PaymentCardVC.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import Stripe
import DeepSoundSDK

protocol PaymentCardViewDelegate {
    func cardView(_ isSuccess: Bool)
}

class PaymentCardVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var cardNumberTextField: FloatingTextField!
    @IBOutlet weak var cvvTextField: FloatingTextField!
    @IBOutlet weak var yearTextField: FloatingTextField!
    @IBOutlet weak var nameTextField: FloatingTextField!
    @IBOutlet weak var postalCodeTextField: FloatingTextField!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var lblErrorCardNumber: UILabel!
    @IBOutlet weak var lblCvv: UILabel!
    @IBOutlet weak var lblErrorCvv: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblErrorYear: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Properties
    
    var paymentType: PaymentName = .creditCard
    var amount: Int = 0
    var packageAmount: Double = 0
    var delegate: PaymentCardViewDelegate?
    var payType:String = ""
    var memberShipType:Int = 0
    var credits:Int = 0
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.cardNumberTextField.setTitle(title: "Card Number")
        self.cvvTextField.setTitle(title: "CVV")
        self.yearTextField.setTitle(title: "Year")
        self.postalCodeTextField.setTitle(title: "Postal Code")
        self.nameTextField.setTitle(title: "Name On Card")
        self.initialConfig()
    }
  
        
    // MARK: - Selectors
    
    // Continue Button Action
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if paymentType == .authorizeNet {
            self.authorizeNetApi()
            return
        }
        if paymentType == .creditCard {
            self.getStipeToken()
            return
        }
    }
        
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setData()
    }
    
    // Set Data
    func setData() {
        self.cardNumberTextField.delegate = self
        self.yearTextField.delegate = self
        self.cvvTextField.delegate = self
        self.nameTextField.delegate = self
        self.lblErrorCardNumber.text = "Your card's number is invalid."
        self.lblErrorCvv.text = "Your card's security code is invalid."
        self.lblErrorYear.text = "Your card's expiration year is invalid."
        if paymentType == .authorizeNet {
            self.headerLabel.text = "AuthorizeNet"
        }
        if paymentType == .creditCard {
            self.headerLabel.text = "Credit Card"
        }
    }
}

// MARK: - Extensions

// MARK: Stripe Setup
extension PaymentCardVC {
    private func getStipeToken() {
        self.showProgressDialog(text: "Loading...")
        let stripeCardParams = STPCardParams()
        stripeCardParams.number = self.cardNumberTextField.text
        let expiryParameters = yearTextField.text?.components(separatedBy: "/")
        stripeCardParams.expMonth = UInt(expiryParameters?.first ?? "0") ?? 0
        stripeCardParams.expYear = UInt(expiryParameters?.last ?? "0") ?? 0
        stripeCardParams.cvc = cvvTextField.text
        let config = STPPaymentConfiguration.shared
        if let stripeId = AppInstance.instance.optionsData?.stripe_id, stripeId != "" {
            let stpApiClient = STPAPIClient(publishableKey: stripeId)
            stpApiClient.createToken(withCard: stripeCardParams) { (token, error) in
                if error == nil {
                    Async.main({
                        log.verbose("Token = \(token?.tokenId)")
                        self.payStipe(stripeToken: token?.tokenId ?? "")
                    })
                } else {
                    self.dismissProgressDialog {
                        self.view.makeToast(error?.localizedDescription ?? "")
                        log.verbose("Error = \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }else {
            
        }
    }
    
    private func payStipe(stripeToken:String){
//        tok_visa
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PaymentManager.instance.PayStripe(AccessToken: accessToken, Token: stripeToken) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.navigationController?.popViewController(animated: true)
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
}

// MARK: Authorize Net Api Call
extension PaymentCardVC {
    func authorizeNetApi()  {
        self.showProgressDialog(text: "Loading...")
        let expiryParameters = yearTextField.text?.components(separatedBy: "/") ?? []
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.card_number : cleanCreditCardNo(self.cardNumberTextField.text ?? ""),
            API.Params.card_month : expiryParameters[0],
            API.Params.card_cvc : cvvTextField.text ?? "",
            API.Params.card_year : expiryParameters[1],
            API.Params.price: "\(self.amount)"
        ] as [String : Any]
                
        PaymentManager.instance.getAuthorizenetToken(params: params) { success, sessionError, error in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog {
                        if let succesMsg = success {
                            print(succesMsg)
                            self.view.makeToast((NSLocalizedString(succesMsg, comment: "")))
                            self.navigationController?.popViewController(animated: true)
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
    }
}

// MARK: UITextFieldDelegate Methods
extension PaymentCardVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if cardNumberTextField == textField {
            self.cardNumberTextField.text = textField.text?.formattedCreditCard
            if self.cardNumberTextField.text == "" {
                self.lblCardNumber.text = "**** **** **** ****"
            }else {
                self.lblCardNumber.text = self.cardNumberTextField.text?.formattedCreditCard
            }
            guard let numberAsString = textField.text else { return }
            self.lblErrorCardNumber.isHidden = self.isCardNumberValid2(numberAsString)
            let recognizedType = CCValidator.typeCheckingPrefixOnly(creditCardNumber: numberAsString)
            //check if type is e.g. .Visa, .MasterCard or .NotRecognized
            print(recognizedType.name)
            cardImageView.image = recognizedType.image
        }
        
        if yearTextField == textField {
            if self.yearTextField.text == "" {
                self.lblYear.text = "MM/YYYY"
            }else {
                self.lblYear.text = textField.text?.formattedExpiredDate
            }
            self.lblErrorYear.isHidden = self.isExpDateValid(self.yearTextField.text?.formattedExpiredDate ?? "")
        }
        
        if cvvTextField == textField {
            cvvTextField.text = textField.text?.formattedCvv
            if self.cvvTextField.text == "" {
                self.lblCvv.text = "***"
            }else{
                self.lblCvv.text = self.cvvTextField.text?.formattedCvv
            }
            self.lblErrorCvv.isHidden = self.isCvvValid(self.cvvTextField.text?.formattedCvv)
        }
        
        if nameTextField == textField {
            self.nameTextField.text = textField.text
            if self.nameTextField.text == "" {
                self.lblName.text = "Your Name"
            }else{
                self.lblName.text = self.nameTextField.text
            }
            self.lblErrorCvv.isHidden = self.isCvvValid(self.cvvTextField.text?.formattedCvv)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text ?? "").count + string.count - range.length
        if(textField == cardNumberTextField) {
            return newLength <= 19
        }
        
        if yearTextField == textField {
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            let updatedText = oldText.replacingCharacters(in: r, with: string)
            
            if string == "" {
                if updatedText.count == 2 {
                    textField.text = "\(updatedText.prefix(1))"
                    return false
                }
            } else if updatedText.count == 1 {
                if updatedText > "1" {
                    return false
                }
            } else if updatedText.count == 2 {
                if updatedText <= "12" { //Prevent user to not enter month more than 12
                    textField.text = "\(updatedText)/" //This will add "/" when user enters 2nd digit of month
                }
                return false
            } else if updatedText.count == 7 {
                //                    return true
            } else if updatedText.count > 7 {
                return false
            }
        }
        return true
    }
    
}

extension PaymentCardVC {
    
    public  func cleanCreditCardNo(_ creditCardNo: String) -> String {
        return creditCardNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    public  func isCardNumberValid2(_ cardNumber: String) -> Bool {
        let recognizedType = CCValidator.validate(creditCardNumber: cardNumber)
        return recognizedType
    }
    
    public  func isCardNumberValid(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber else {
            return false
        }
        let number = cardNumber.onlyNumbers()
        guard number.count >= 14 && number.count <= 19 else {
            return false
        }
        
        var digits = number.map { Int(String($0))! }
        stride(from: digits.count - 2, through: 0, by: -2).forEach { i in
            var value = digits[i] * 2
            if value > 9 {
                value = value % 10 + 1
            }
            digits[i] = value
        }
        
        let sum = digits.reduce(0, +)
        return sum % 10 == 0
    }
    
    public func isExpDateValid(_ dateStr: String) -> Bool {
        
        let currentYear = Calendar.current.component(.year, from: Date())   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        let enteredYear = Int(dateStr.suffix(4)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(dateStr.prefix(2)) ?? 0 // get first two digit from entered string as month
        print(dateStr) // This is MM/YY Entered by user
        
        if enteredYear > currentYear {
            if (1 ... 12).contains(enteredMonth) {
                return true
            } else {
                return false
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if (1 ... 12).contains(enteredMonth) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public  func isCvvValid(_ cvv: String?) -> Bool {
        guard let cvv = cvv else {
            return false
        }
        if (cvv.count == 3) {
            return true
        }
        return false
    }
}

extension String {
    func onlyNumbers() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    var formattedCreditCard: String {
        return format(with: CardTextField.cardNumber, phone: self)
    }
    
    var formattedExpiredDate: String {
        return format(with: CardTextField.dateExpiration, phone: self)
    }
    
    var formattedCvv: String {
        return format(with: CardTextField.cvv, phone: self)
    }
    
    func format(with maskType: CardTextField, phone: String) -> String {
        let mask = maskType.mask
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

public enum CardTextField {
    case cardNumber
    case cvv
    case cardHolder
    case dateExpiration
    
    var mask: String {
        switch self {
        case .cardNumber:
            return "XXXX XXXX XXXX XXXX"
        case .cvv:
            return "XXX"
        case .cardHolder:
            return ""
        case .dateExpiration:
            return "XX/XXXX"
        }
    }
}
