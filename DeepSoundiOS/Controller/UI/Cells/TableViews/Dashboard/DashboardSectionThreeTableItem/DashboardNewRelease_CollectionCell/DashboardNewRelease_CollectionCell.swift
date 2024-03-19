//
//  DashboardNewRelease_CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardNewRelease_CollectionCell: UICollectionViewCell {
    
    //    @IBOutlet weak var MusicCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailimage: UIImageView!
    @IBOutlet weak var backShadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backShadowView.addShadow()
        
    }
    
    func bind(_ object: Song) {
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        let url = URL.init(string: object.thumbnail ?? "")
        self.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    
    func bindPlaylist(_ object: Playlist) {
        self.titleLabel.text = object.name
        let url = URL.init(string: object.thumbnail_ready ?? "")
        self.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
}
