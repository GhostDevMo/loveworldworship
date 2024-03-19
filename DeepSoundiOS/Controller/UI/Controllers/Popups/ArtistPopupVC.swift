//
//  ArtistPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 25/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol ArtistPopupDelegate {
    func profileInfoPressed(_ sender: UIButton)
    func blockPressed(_ sender: UIButton)
    func copyProfileLinkPressed(_ sender: UIButton)
}

class ArtistPopupVC: BaseVC {
    
    var delegate: ArtistPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func profileInfoPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.profileInfoPressed(sender)
        }
    }
    
    @IBAction func blockPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.blockPressed(sender)
        }
    }
    @IBAction func copyProfileLinkPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.copyProfileLinkPressed(sender)
        }
    }
    
}
