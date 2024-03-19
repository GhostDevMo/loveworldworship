//
//  TargetAudienceTableCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 19/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

class TargetAudienceTableCell: UITableViewCell {
    
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
