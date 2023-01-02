//
//  PaystackPopupVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 06/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PaystackPopupVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    var delegate:didSelectPaystackEmailDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func CancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil
        )
    }
    
    @IBAction func payNowPressed(_ sender: Any) {
        if emailTextField.text?.isEmpty ?? false{
            self.view.makeToast("Please enter email.")
        }else{
            self.dismiss(animated: true) {
                self.delegate?.didSelectPaystackEmail(email: self.emailTextField.text ?? "")
            }
        }
    }
    
}
