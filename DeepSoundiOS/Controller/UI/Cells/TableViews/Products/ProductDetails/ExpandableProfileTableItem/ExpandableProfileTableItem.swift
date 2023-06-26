//
//  ExpandableProfileTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 21/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ExpandableProfileTableItem: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:[String:Any]){
        let name = object["username"] as? String
        let image = object["avatar"] as? String
        let url = URL.init(string:image ?? "")
        self.nameLabel.text = name ?? ""
        self.profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
}
