//
//  ChatTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/12/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ChatTableItem: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object :GetChatsModel.Datum){
      
        let url = URL(string: object.user.avatar ?? "")
         profileImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder())
        self.usernameLabel.text = "\(object.user.name)"
        self.timeLabel.text = ""
        if object.getLastMessage.apiType == "image"{
                  self.lastMessageLabel.text = NSLocalizedString("Photo", comment: "Photo")
            self.iconImage.isHidden = false
              }else{
                  self.lastMessageLabel.text = object.getLastMessage.text ?? ""
            self.iconImage.isHidden = true

              }

    }
    
    
}
