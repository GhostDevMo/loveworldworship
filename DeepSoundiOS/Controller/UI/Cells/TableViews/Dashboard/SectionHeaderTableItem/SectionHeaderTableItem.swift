//
//  SectionHeaderTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SectionHeaderTableItem: UITableViewCell {

    @IBOutlet weak var btnSeeAll: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sepratorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSeeAll.setTitleColor(.ButtonColor, for: .normal) 
    }

   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    
}
