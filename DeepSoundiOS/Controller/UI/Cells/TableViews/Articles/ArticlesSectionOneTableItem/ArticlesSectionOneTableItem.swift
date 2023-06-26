//
//  ArticlesSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticlesSectionOneTableItem: UITableViewCell {
    
    @IBOutlet weak var articleImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func bind(_ object:String){
        let url = URL.init(string:object)
        articleImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
}
