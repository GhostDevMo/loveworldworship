//
//  DashboardNewRelease_CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardNewRelease_CollectionCell: UICollectionViewCell {

    @IBOutlet weak var MusicCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func bind(_ object:DiscoverModel.Song){
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.MusicCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
        let url = URL.init(string:object.thumbnail ?? "")
        self.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    func notLoggedBind(_ object:DiscoverModel.Song){
           self.titleLabel.text = object.title?.htmlAttributedString ?? ""
           self.MusicCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
           let url = URL.init(string:object.thumbnail ?? "")
           self.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
       }

}
