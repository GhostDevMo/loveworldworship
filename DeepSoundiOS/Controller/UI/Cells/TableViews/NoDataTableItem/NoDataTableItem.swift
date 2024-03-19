//
//  NoDataTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/13/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class NoDataTableItem: UITableViewCell {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.noDataImage.tintColor = .mainColor
       // self.noDataLabel.text = NSLocalizedString("There are no activity by this user ", comment: "There are no activity by this user ")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
