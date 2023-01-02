//
//  PaymentOptionCell.swift
//  DeepSoundiOS
//
//  Created by Moghees on 21/10/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class PaymentOptionCell: UITableViewCell {
    
    @IBOutlet weak var imgOption: UIImageView!
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var btnOption: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
