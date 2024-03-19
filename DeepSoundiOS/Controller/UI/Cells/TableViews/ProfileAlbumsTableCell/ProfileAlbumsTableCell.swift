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
        self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object: Album){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.category_name ?? ""
        songsCountLabel.text = "\(object.count_songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.is_purchased == 1 {
            self.priceView.isHidden = true
        }else {
            if object.price?.intValue == 0 {
                self.priceView.isHidden = true
            }else{
                self.priceView.isHidden = false
                switch object.price {
                case .double(let value):
                    self.priceCountLabel.text  = "$\(value.rounded(toPlaces: 2))"
                case .integer(let value):
                    self.priceCountLabel.text  = "$\(value)"
                case .string(let value):
                    self.priceCountLabel.text  = "$\(value)"
                case .none:
                    break
                }
            }
        }
    }
    
    func publicAlbumBind(_ object: Album){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.category_name ?? ""
        songsCountLabel.text = "\(object.count_songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price?.intValue == 0 {
            self.priceView.isHidden = true
        }else{
            self.priceView.isHidden = false
            switch object.price {
            case .double(let value):
                self.priceCountLabel.text  = "$\(value.rounded(toPlaces: 2))"
            case .integer(let value):
                self.priceCountLabel.text  = "$\(value)"
            case .string(let value):
                self.priceCountLabel.text  = "$\(value)"
            case .none:
                break
            }
        }
    }
    func searchAlbumBind(_ object: Album){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        nameLAbel.text = "\(object.publisher?.name ?? "")"
        categoryNameLAbel.text = object.category_name ?? ""
        songsCountLabel.text = "\(object.count_songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
        if object.price?.intValue == 0 {
            self.priceView.isHidden = true
        }else{
            self.priceView.isHidden = false
            switch object.price {
            case .double(let value):
                self.priceCountLabel.text  = "$\(value.rounded(toPlaces: 2))"
            case .integer(let value):
                self.priceCountLabel.text  = "$\(value)"
            case .string(let value):
                self.priceCountLabel.text  = "$\(value)"
            case .none:
                break
            }
        }
    }
}
