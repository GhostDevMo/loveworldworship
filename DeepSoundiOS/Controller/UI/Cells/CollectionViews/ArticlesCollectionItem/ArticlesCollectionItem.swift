//
//  ArticlesCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticlesCollectionItem: UICollectionViewCell {

    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(_ object:GetArticlesModel.Datum){
        self.titleLabel.text = object.title ?? ""
        self.timelabel.text = object.createdAt ?? ""
        let url = URL.init(string:object.thumbnail ?? "")
        self.articleImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }

}
