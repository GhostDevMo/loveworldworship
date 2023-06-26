//
//  StoreCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/16/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class StoreCollectionItem: UICollectionViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumnbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ object:ProfileModel.Latestsong){
          let thumbnailURL = URL.init(string:object.thumbnail ?? "")
          self.thumnbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        categoryLabel.text = "\(object.categoryName  ?? "")  - \(object.publisher?.name  ?? "")"
        
            
      }

}
