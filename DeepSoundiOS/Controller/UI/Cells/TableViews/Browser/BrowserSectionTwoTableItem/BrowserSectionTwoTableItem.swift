//
//  BrowserSectionTwoTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class BrowserSectionTwoTableItem: UITableViewCell {
    
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
    }
    
}
