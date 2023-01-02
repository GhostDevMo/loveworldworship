//
//  ArticleSectionFiveTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/29/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticleSectionFiveTableItem: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func bind(_ object:GetArticlesCommentsModel.Datum){
        self.titleLabel.text = object.value ?? ""
        let url = URL.init(string:object.userData?.avatar ?? "")
        profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
}
