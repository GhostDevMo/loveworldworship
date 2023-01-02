//
//  Settings-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Settings_TableCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
