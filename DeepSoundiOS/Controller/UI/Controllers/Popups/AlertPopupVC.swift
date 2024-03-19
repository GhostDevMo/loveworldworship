//
//  AlertPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol AlertPopupVCDelegate {
    func alertPopupOKButtonPressed(_ sender: UIButton)
}

class AlertPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Properties
    
    var delegate: AlertPopupVCDelegate?
    var titleText: String?
    var messageText: String?
    var okText: String?
    var cancelText: String?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Ok Button Action
    @IBAction func okButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.alertPopupOKButtonPressed(sender)
        }
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        self.setTitleAndMessage()
    }
    
    func setTitleAndMessage() {
        self.titleLabel.text = titleText ?? "Warning"
        self.messageLabel.text = messageText ?? "N/A"
        self.okButton.setTitle((okText ?? "OK"), for: .normal)
        self.cancelButton.setTitle((cancelText ?? "CANCEL"), for: .normal)
    }

}
