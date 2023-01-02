//
//  SenderImageTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SenderImageTableItem: UITableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ object:GetChatMessagesModel.Datum){
           let thumbnailURL = URL.init(string:object.fullImage ?? "")
                self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
       }
}
