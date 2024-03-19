//
//  ArticlesCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticlesCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //radius: 1.0, opacity: 0.25
        self.mainView.addShadow()
    }
    
    func bind(_ object: Blog){
        self.titleLabel.text = object.title ?? ""
        self.timelabel.text = object.created_at ?? ""
        let url = URL.init(string:object.thumbnail ?? "")
        self.articleImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if Int(object.created_by ?? "") == AppInstance.instance.userId {
            self.statusLabel.text = "My Article"
        }else{
            self.statusLabel.text = "Others"
        }
    }
    
}
