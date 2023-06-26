//
//  ProfileAlbumsTableCell.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/18/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ProfileAlbumsTableCell: UITableViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var priceCountLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var songsCountBackgroundView: UIView!
    @IBOutlet weak var categoryBackgroundView: UIView!
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var categoryNameLAbel: UILabel!
    @IBOutlet weak var nameLAbel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryBackgroundView.cornerRadiusV = self.categoryBackgroundView.frame.height / 2
        songsCountBackgroundView.cornerRadiusV = self.songsCountBackgroundView.frame.height / 2
        priceView.cornerRadiusV = self.priceView.frame.height / 2
        self.bgView.backgroundColor = .mainColor
        self.categoryView.backgroundColor = .mainColor
        self.playBtn.backgroundColor = .mainColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    func bind(_ object:ProfileModel.AlbumElement){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.categoryName ?? ""
        songsCountLabel.text = "\(object.countSongs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price == 0.0{
            self.priceView.isHidden = true
        }else{
            self.priceView.isHidden = false
            self.priceCountLabel.text  = "$\(object.price?.rounded(toPlaces: 2) ?? 0.0)"
        }
    }
    func publicAlbumBind(_ object:TrendingModel.TopAlbum){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.categoryName ?? ""
        songsCountLabel.text = "\(object.countSongs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price == 0.0{
                   self.priceView.isHidden = true
               }else{
                   self.priceView.isHidden = false
            self.priceCountLabel.text  = "$\(object.price?.rounded(toPlaces: 2) ?? 0.0)"
               }
    }
    func searchAlbumBind(_ object:SearchModel.Album){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.categoryName ?? ""
        songsCountLabel.text = "\(object.countSongs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price == 0.0{
                   self.priceView.isHidden = true
               }else{
                   self.priceView.isHidden = false
            self.priceCountLabel.text  = "$\(object.price?.rounded(toPlaces: 2) ?? 0.0)"
               }
    }
    
    
    
    
}
