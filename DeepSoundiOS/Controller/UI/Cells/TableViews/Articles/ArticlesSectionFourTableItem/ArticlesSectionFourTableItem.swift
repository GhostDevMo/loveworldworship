//
//  ArticlesSectionFourTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticlesSectionFourTableItem: UITableViewCell {
    
    @IBOutlet weak var viewsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object:String){
        self.viewsLabel.text = "\(object) \(NSLocalizedString("Views", comment: "Views"))"
    }
    
}
