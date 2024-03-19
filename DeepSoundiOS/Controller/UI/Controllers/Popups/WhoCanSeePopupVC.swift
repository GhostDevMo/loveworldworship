//
//  WhoCanSeePopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol WhoCanSeePopupDelegate {
    func selectedType(_ sender: UIButton, _ type: String)
}

class WhoCanSeePopupVC: BaseVC {
  
    var delegate: WhoCanSeePopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func followersBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.selectedType(sender, "followers")
        }
    }
    
    @IBAction func allBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.selectedType(sender, "all")
        }
    }
}
