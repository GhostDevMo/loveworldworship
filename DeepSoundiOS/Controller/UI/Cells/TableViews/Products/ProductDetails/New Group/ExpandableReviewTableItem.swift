//
//  ExpandableReviewTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 21/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ExpandableReviewTableItem: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var thumbailImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bind(_ object: ReviewModel) {
        self.lblName.text = object.user_data.name
        self.lblRating.text = "\(object.star)"
        self.lblDescription.text =  object.review
        let url = URL.init(string:object.user_data.avatar ?? "")
        self.thumbailImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder())
    }
}
