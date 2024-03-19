//
//  PurchaseButtonTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Braintree
import Async
import DeepSoundSDK
import PassKit

class PurchaseButtonTableItem: UITableViewCell {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var dollarImage: UIImageView!
    //    @IBOutlet weak var buyBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.buyBtn.setTitle(NSLocalizedString("BUY", comment: "BUY"), for: .normal)
        //        self.buyBtn.backgroundColor = .ButtonColor
        self.dollarImage.tintColor = .mainColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
