//
//  DashboardSectionTwoCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardSectionTwoCollectionItem: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func bind(_ object: GenresModel.Datum){
        self.titleLabel.text = object.cateogryName?.htmlAttributedString ?? ""
        let url = URL.init(string:object.backgroundThumb ?? "")
        self.thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }

}
