//
//  DashboardTopAlbums_CollectionCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

class DashboardTopAlbums_CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbailImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblSongCount: UILabel!
    @IBOutlet weak var btnPrice: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(_ object: Album){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        lblTitle.text = object.title ?? ""
        lblCategoryName.text = object.publisher?.name ?? ""
        lblSongCount.text = "\(object.count_songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price?.intValue == 0  || object.price?.doubleValue == 0 {
            self.btnPrice.isHidden = true
        }else{
            self.btnPrice.isHidden = false
            print("Price", object.price?.doubleValue ?? 0)
            self.btnPrice.setTitle("$\(object.price?.doubleValue?.rounded(toPlaces: 2) ?? 0)", for: .normal)
            self.btnPrice.isUserInteractionEnabled = false
        }
    }
}
