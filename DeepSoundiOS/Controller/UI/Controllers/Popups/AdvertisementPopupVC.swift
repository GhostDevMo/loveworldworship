//
//  AdvertisementPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 19/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol AdvertisementPopupDelegate {
    func selectedPlacement(_ type: String, _ id: String)
    func selectedPricing(_ type: String, _ id: String)
    func selectedType(_ type: String)
}

class AdvertisementPopupVC: BaseVC {
    
    @IBOutlet weak var placementStackView: UIStackView!
    @IBOutlet weak var pricingStackView: UIStackView!
    @IBOutlet weak var typeStackView: UIStackView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
        
    var delegate: AdvertisementPopupDelegate?
    var isPlacement = false
    var isPricing = false
    var isType = false

    override func viewDidLoad() {
        super.viewDidLoad()
        placementStackView.isHidden = !isPlacement
        pricingStackView.isHidden = !isPricing
        typeStackView.isHidden = !isType
        if isPlacement {
            self.lblHeaderTitle.text = "Placement"
        }
        
        if isPricing {
            self.lblHeaderTitle.text = "Pricing"
        }
        
        if isType {
            self.lblHeaderTitle.text = "Type"
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            switch sender.tag {
            case 101,102:
                self.delegate?.selectedPlacement(sender.currentTitle ?? "", sender.tag == 101 ? "1" : "2")
                break
            case 103,104:
                self.delegate?.selectedPricing(sender.currentTitle ?? "", sender.tag == 103 ? "1" : "2")
                break
            case 105,106:
                self.delegate?.selectedType(sender.tag == 105 ? "banner" : "audio")
                break
            default:
                break
            }
        }
    }
}
