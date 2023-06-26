//
//  ReceiverImageTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ReceiverImageTableItem: UITableViewCell {

    @IBOutlet weak var cornerView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.backgroundColor = .mainColor
        self.cornerView.tintColor = .mainColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:GetChatMessagesModel.Datum){
        let thumbnailURL = URL.init(string:object.fullImage ?? "")
             self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
    }
    
}
