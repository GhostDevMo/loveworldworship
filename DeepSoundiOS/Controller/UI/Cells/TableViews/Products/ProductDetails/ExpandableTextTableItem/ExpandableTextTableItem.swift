//
//  ExpandableTextTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 21/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ExpandableTextTableItem: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:String){
        self.titleLabel.text  = object
    }
    
}
