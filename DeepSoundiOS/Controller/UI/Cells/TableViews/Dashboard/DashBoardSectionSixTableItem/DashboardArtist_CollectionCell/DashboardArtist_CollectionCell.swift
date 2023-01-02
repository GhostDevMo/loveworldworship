//
//  DashboardArtist-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardArtist_CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        func bind(_ object: ArtistModel.Datum){
        if object.name ?? "" == ""{
                titleLabel.text = object.username ?? ""
        }else{
                titleLabel.text =  object.name ?? ""
        }
        let url = URL.init(string:object.avatar ?? "")
        thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            if object.isPro == 1{
                self.verifiedImage.isHidden = false
            }else{
                self.verifiedImage.isHidden = true

            }
    }
    
}
