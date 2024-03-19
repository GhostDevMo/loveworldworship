//
//  WarningPopupVC.swift
//  Playtube
//
//  Created by iMac on 10/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class WarningPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Properties
    
    var delegate: WarningPopupVCDelegate?
    var titleText: String?
    var messageText: String?
    var okText: String?
    var cancelText: String?
    var songObject: Song?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Ok Button Action
    @IBAction func okButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.warningPopupOKButtonPressed(sender, self.songObject)
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
