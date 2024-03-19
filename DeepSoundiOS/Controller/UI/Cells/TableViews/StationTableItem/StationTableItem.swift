//
//  StationTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/13/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class StationTableItem: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func bind(_ object: Song){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.categoryLabel.text = object.category_name ?? ""
        self.titleLabel.text  = object.title ?? ""
    }
    
}
