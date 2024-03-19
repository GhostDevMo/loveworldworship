//
//  PaymentOptionPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 16/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit


public enum PaymentName {
    case paypal
    case creditCard
    case bank
    case razorPay
    case cashfree
    case paysera
    case paystack
    case securionPay
    case authorizeNet
    case iyziPay
    case aamarPay
    case flutterWave
    case coinbase
    case ngenius
}


protocol PaymentOptionPopupVCDelegate {
    func handlePaymentOptionTapped(paymentOption: String)
}

class PaymentOptionPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties -
    var paymentOptionArray: [String] = []
    var delegate: PaymentOptionPopupVCDelegate?
        
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        self.registerCell()
        self.setTableViewDataAndHeight()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.paymentOptionPopupCell), forCellReuseIdentifier: R.reuseIdentifier.paymentOptionPopupCell.identifier)
    }
    
    // Set TableView Data And Height
    func setTableViewDataAndHeight() {
        if let optionsModel = AppInstance.instance.optionsData {
            if optionsModel.paypal_payment == "on" {
                self.paymentOptionArray.append("Paypal")
            }
            if optionsModel.bank_payment == "on" {
                self.paymentOptionArray.append("Bank Transfer")
            }
            if optionsModel.stripe_payment == "on" {
                self.paymentOptionArray.append("Credit Card")
            }
            if optionsModel.razorpay_payment == "on" {
                self.paymentOptionArray.append("RazorPay")
            }
            if optionsModel.paystack_payment == "on" {
                self.paymentOptionArray.append("Paystack")
            }
            if optionsModel.cashfree_payment == "on" {
                self.paymentOptionArray.append("Cashfree")
            }
            if optionsModel.paysera_payment == "on" {
                self.paymentOptionArray.append("Paysera")
            }
            if optionsModel.checkout_payment == "on" {
                self.paymentOptionArray.append("Checkout")
            }
            if optionsModel.iyzipay_payment == "on" {
                self.paymentOptionArray.append("Iyzipay")
            }
            if optionsModel.payu_payment == "on" {
                self.paymentOptionArray.append("Payu")
            }
            if optionsModel.securionpay_payment == "on" {
                self.paymentOptionArray.append("SecurionPay")
            }
            if optionsModel.authorize_payment == "on" {
                self.paymentOptionArray.append("AuthorizeNet")
            }
            if optionsModel.fortumo_payment == "on" {
                self.paymentOptionArray.append("Fortumo")
            }
            if optionsModel.aamarpay_payment == "on" {
                self.paymentOptionArray.append("AamarPay")
            }
            if optionsModel.ngenius_payment == "on" {
                self.paymentOptionArray.append("Ngenius")
            }
            if optionsModel.coinbase_payment == "on" {
                self.paymentOptionArray.append("Coinbase")
            }
            if optionsModel.yoomoney_payment == "on" {
                self.paymentOptionArray.append("Yoomoney")
            }
            if optionsModel.fluttewave_payment == "on" {
                self.paymentOptionArray.append("FlutterWave")
            }
            if optionsModel.coinpayments == "on" {
                self.paymentOptionArray.append("CoinPay")
            }
            self.paymentOptionArray.append("Apple Pay")
            self.paymentOptionArray = self.paymentOptionArray.sorted()
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if self.tableView.contentSize.height > (self.view.frame.height * 0.7) {
                    self.tableViewHeight.constant = (self.view.frame.height * 0.7)
                } else {
                    self.tableViewHeight.constant = self.tableView.contentSize.height
                }
            }
        }
    }
}

// MARK: - TableView Delegate and DataSource Methods -
extension PaymentOptionPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentOptionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.paymentOptionPopupCell.identifier, for: indexPath) as! PaymentOptionPopupCell
        cell.titleLabel.text = self.paymentOptionArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.handlePaymentOptionTapped(paymentOption: self.paymentOptionArray[indexPath.row])            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
