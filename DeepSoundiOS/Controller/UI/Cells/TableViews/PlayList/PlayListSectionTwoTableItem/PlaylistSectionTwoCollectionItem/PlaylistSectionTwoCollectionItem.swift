//
//  PlaylistSectionTwoCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PlaylistSectionTwoCollectionItem: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailIamge: UIImageView!
    @IBOutlet weak var categoryBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryBackgroundView.cornerRadiusV = self.categoryBackgroundView.frame.height / 2

    }
    func bind(_ object: Playlist){
        titleLabel.text = object.name ?? ""
        self.songCountLabel.text = "\(object.songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        self.categoryLabel.text =  object.privacy_text ?? ""
        let url = URL.init(string:object.thumbnail_ready ?? "")
        thumbnailIamge.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }

}
