//
//  DashboardPopular-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardPopular_CollectionCell: UICollectionViewCell {
    @IBOutlet weak var musicCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ object: DiscoverModel.Song){
        titleLabel.text = object.title?.htmlAttributedString ?? ""
        musicCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
        let url = URL.init(string:object.thumbnail ?? "")
        thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    func notLoggedbind(_ object: DiscoverModel.Song){
          titleLabel.text = object.title?.htmlAttributedString ?? ""
          musicCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
          let url = URL.init(string:object.thumbnail ?? "")
          thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
      }
}
