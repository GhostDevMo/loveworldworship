//
//  SettingsSectionTwoTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/6/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SettingsSectionTwoTableItem: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tittleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
