//
//  TwoFactorUpdatePopupVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit


class TwoFactorUpdatePopupVC: UIViewController {
    
    @IBOutlet weak var cancelLabel: UIButton!
    @IBOutlet weak var disableLabel: UIButton!
    @IBOutlet weak var enableLabel: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    var delegate:TwoFactorAuthDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelLabel.setTitle((NSLocalizedString("CANCEL", comment: "")), for: .normal)
        self.disableLabel.setTitle((NSLocalizedString("Disable", comment: "")), for: .normal)
        self.enableLabel.setTitle((NSLocalizedString("Enable", comment: "")), for: .normal)
        self.selectLabel.text = (NSLocalizedString("Select", comment: ""))
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func disablePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.getTwoFactorUpdateString(type: "disable")
        }
    }
    @IBAction func enablePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.getTwoFactorUpdateString(type: "enable")
        }
    }
}
