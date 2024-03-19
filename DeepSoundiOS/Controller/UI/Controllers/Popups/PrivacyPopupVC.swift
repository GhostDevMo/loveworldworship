//
//  PrivacyPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 18/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol PrivacyPopupDelegate {
    func selectedPrivacyType(_ text: String)
}

class PrivacyPopupVC: UIViewController {

    var delegate: PrivacyPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func publicBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.selectedPrivacyType("Public")
        }
    }
    
    @IBAction func privateBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.selectedPrivacyType("Private")
        }
    }
}
