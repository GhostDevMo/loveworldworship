//
//  TwoFactorUpdatePopupVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TwoFactorUpdatePopupVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var enableLabel: UILabel!
    @IBOutlet weak var disableLabel: UILabel!
    
    // MARK: - Properties

    var delegate: TwoFactorAuthDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Disable Button Action
    @IBAction func disableButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.getTwoFactorUpdateString(type: "disable")
        }
    }
    
    // Enable Button Action
    @IBAction func enableButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.getTwoFactorUpdateString(type: "enable")
        }
    }
    
}
