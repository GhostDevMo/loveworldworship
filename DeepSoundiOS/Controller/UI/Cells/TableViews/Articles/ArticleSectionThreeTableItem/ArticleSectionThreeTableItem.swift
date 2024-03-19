//
//  ArticleSectionThreeTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ArticleSectionThreeTableItem: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ object: Blog) {
        var str = object.content?.replacingOccurrences(of: "&lt;", with: "<")
        str = str?.replacingOccurrences(of: "&gt;", with: ">")
        self.descriptionLabel.attributedText = str?.convertHtmlToAttributedStringWithCSS(font: R.font.urbanistRegular.callAsFunction(size: 18), font3: R.font.urbanistBold.callAsFunction(size: 18)!, csscolor: "#212121")
    }
}
