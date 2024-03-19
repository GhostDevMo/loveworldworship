//
//  ChatScreenTableItem.swift
//  QuickDate
//

//  Copyright © 2020 ScriptSun. All rights reserved.
//

import UIKit
import SDWebImage

class ChatScreenTableItem: UITableViewCell {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var textMsgLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var viewMessgaeCount: UIView!
    @IBOutlet weak var viewSetOnlineOffline: UIImageView!
    @IBOutlet weak var lblTotalMsgCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object: ChatConversationModel) {
        if object.getCountSeen != 0 {
            viewMessgaeCount.isHidden = false
            lblTotalMsgCount.text = "\(object.getCountSeen)"
        } else {
            viewMessgaeCount.isHidden = true
        }
        let milisecond = object.user.last_active ?? 0
        let dateVar = Date.init(timeIntervalSinceNow: TimeInterval(milisecond)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if dateVar == Date() {
            viewSetOnlineOffline.backgroundColor = UIColor.hexStringToUIColor(hex: "47D017")
        } else {
            viewSetOnlineOffline.backgroundColor = UIColor.hexStringToUIColor(hex: "BDBDBD")
        }
        print(dateFormatter.string(from: dateVar))
        if object.user.name == "" {
            self.userNameLabel.text = object.user.username
        } else {
            self.userNameLabel.text = object.user.name
        }
        
        let chatTime = Date.init(timeIntervalSince1970: TimeInterval(object.chatTime))
        self.timeLabel.text = chatTime.timeAgoDisplay()
        if object.user.or_avatar != "upload/photos/d-avatar.jpg" {
            let url = URL(string: object.user.avatar ?? "")
            self.avatarImageView.sd_setImage(with: url, placeholderImage: R.image.no_profile_image_circle())
        }else {
            self.avatarImageView.image = R.image.no_profile_image_circle()
        }
        if object.getLastMessage.apiType == "image" {
            self.textMsgLabel.text = "Photo"
            self.iconImage.isHidden = false
            self.iconImage.image = UIImage(named: "icon_image")
        } else if object.getLastMessage.apiType == "sticker" {
            self.textMsgLabel.text = "sticker"
            self.iconImage.isHidden = false
            self.iconImage.image = UIImage(named: "icn_smile")
        } else if object.getLastMessage.apiType == "text" {
            self.textMsgLabel.text = object.getLastMessage.text
            self.iconImage.isHidden = true
        }
    }
}

//extension Date {
//    func timeAgoDisplay() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        return formatter.localizedString(for: self, relativeTo: Date())
//    }
//}
