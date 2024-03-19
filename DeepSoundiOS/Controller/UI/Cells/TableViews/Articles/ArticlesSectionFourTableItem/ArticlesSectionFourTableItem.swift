//
//  ArticlesSectionFourTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol ArticleSectionDelegate {
    func moreBtnAction(_ sender: UIButton)
}

class ArticlesSectionFourTableItem: UITableViewCell {
    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    
    var delegate: ArticleSectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object:String){
        self.viewsLabel.text = "\(object) \(NSLocalizedString("Views", comment: "Views"))"
    }
    
    @IBAction func moreBtn(_ sender: UIButton) {
        self.delegate?.moreBtnAction(sender)
    }
}
