//
//  GoProPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 31/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol GoProPopupVCDelegate {
    func handleWalletTap(_ sender: UIButton)
}

class GoProPopupVC: UIViewController {
    
    // MARK: - Properties
    
    var delegate: GoProPopupVCDelegate?
    
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
    
    // Wallet Button Action
    @IBAction func walletButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.handleWalletTap(sender)
        }
    }

}
