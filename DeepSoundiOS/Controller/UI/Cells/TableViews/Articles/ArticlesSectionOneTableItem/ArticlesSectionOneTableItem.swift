//
//  ArticlesSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SDWebImage

class ArticlesSectionOneTableItem: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func bind(_ object: Blog) {
        self.lblTitle.text = object.title
        let url = URL.init(string: object.thumbnail ?? "")
        let indicator = SDWebImageActivityIndicator.medium
        self.articleImage.sd_imageIndicator = indicator
        DispatchQueue.global(qos: .userInteractive).async {
            self.articleImage.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
        }
    }
}
