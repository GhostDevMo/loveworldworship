//
//  CashFreePopUpVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 06/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CashFreePopUpVC: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate:didInitializeCashFreeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cashFreePopclossed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cashFreePayNowPressed(_ sender: Any) {
        if self.nameTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter full name.")
        }else if self.emailTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter email.")
        }else if self.phoneTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter phone number")
        }else{
            self.dismiss(animated: true) {
                self.delegate?.didInitializeCashFree(name: self.nameTextField.text ?? "", email: self.emailTextField.text ?? "", phoneNumber: self.phoneTextField.text ?? "")
            }
        }
    }
    
}
