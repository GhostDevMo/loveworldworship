//
//  ChatReceiverTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ChatReceiverTableItem: UITableViewCell {
    
    @IBOutlet weak var cornerVIew: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.backgroundColor = .mainColor
        self.cornerVIew.tintColor = .mainColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object:GetMessage) {
        self.titleLabel.text = object.text
        self.dateLabel.text = getDate(unixdate: object.time, timezone: "GMT")
    }
}
