//
//  ManageSessionTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async

protocol ManageSessionCellDelegate {
    func handleCloseButtonTap(indexPath: IndexPath)
}

class ManageSessionTableItem: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var lastSeenlabel: UILabel!
    @IBOutlet weak var browserLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var singleCharacter: String?
    var indexPath = IndexPath(row: 0, section: 0)
    var delegate: ManageSessionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func bind(_ object: SessionModel.Datum) {
        self.nameLabel.text = "\(object.platform ?? "")"
        self.ipAddressLabel.text = "IP Address: " + (object.ipAddress ?? "")
        self.browserLabel.text = "Browser: " + (object.browser ?? "")
        self.lastSeenlabel.text = "Last seen: " + (object.time ?? "")
        if object.browser == nil {
            self.alphaLabel.text = self.singleCharacter ?? ""
        } else {
            for (index, value) in (object.browser?.enumerated())! {
                if index == 0 {
                    self.singleCharacter = String(value)
                    break
                }
            }
            self.alphaLabel.text = self.singleCharacter ?? ""
        }
    }
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.handleCloseButtonTap(indexPath: self.indexPath)
    }
    
}
