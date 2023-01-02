//
//  productsRelatedItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class productsRelatedItem: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backView.backgroundColor = .lightMainColor
        songNameLabel.textColor = .mainColor

    }
    func bind(_ object:String){
        self.songNameLabel.text = object
    }
   
    
}
