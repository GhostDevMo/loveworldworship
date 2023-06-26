//
//  Notifications-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Notifications_TableCell: UITableViewCell {

    @IBOutlet weak var showImage: UIImageView!
  
    @IBOutlet weak var showTextLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
