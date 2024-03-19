//
//  ProfilePopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 31/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol ProfilePopupVCDelegate {
    func handleChangeCoverImageTap(_ sender: UIButton)
    func handleSettingsTap(_ sender: UIButton)
    func handleCopyLinkToProfileTap(_ sender: UIButton)
}

class ProfilePopupVC: UIViewController {
    
    // MARK: - Properties
    
    var delegate: ProfilePopupVCDelegate?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Change Cover Image Button Action
    @IBAction func changeCoverImageButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.handleChangeCoverImageTap(sender)
        }
    }
    
    // Settings Button Action
    @IBAction func settingsButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.handleSettingsTap(sender)
        }
    }
    
    // Copy Link To Profile Button Action
    @IBAction func copyLinkToProfileButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.handleCopyLinkToProfileTap(sender)
        }
    }

}
