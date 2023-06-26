//
//  DashboardSectionOneCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardSectionOneCollectionItem: UICollectionViewCell {
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryLabel.textColor = .mainColor
        self.playBtn.backgroundColor = .mainColor
        self.categoryView.cornerRadiusV = self.categoryView.frame.height / 2
    }
    
    func bind(_ object: DiscoverModel.Song){
        titleLabel.text = object.title ?? ""
        self.categoryLabel.text =  "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
          let url = URL.init(string:object.thumbnail ?? "")
          thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
      }
    func notLoggedBind(_ object: DiscoverModel.Song){
           titleLabel.text = object.title ?? ""
           self.categoryLabel.text =  "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music"))"
             let url = URL.init(string:object.thumbnail ?? "")
             thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
         }

}
