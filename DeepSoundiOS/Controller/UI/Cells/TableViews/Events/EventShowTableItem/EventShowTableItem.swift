//
//  EventShowTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 22/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class EventShowTableItem: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var backgroundCol: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object:[String:Any]){
    let name = object["name"] as? String
        let description = object["desc"] as? String
        let isJoined = object["is_joined"] as? Int
        let eventDate = object["start_date"] as? String
        let image = object["image"] as? String
        let onlineUrl = object["online_url"] as? String
        let location = object["real_address"] as? String
        self.titleLabel.text = name
        self.descriptionLabel.text = description
        self.dateLabel.text = eventDate
        self.locationLabel.text = onlineUrl
        if onlineUrl == nil {
            self.locationLabel.text = location ?? ""
        }else{
            self.locationLabel.text = onlineUrl ?? ""
        }
        let url = URL.init(string:image ?? "")
        self.imageLabel.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if isJoined == 0{
            self.backgroundCol.backgroundColor = .orange
            self.statusLabel.text = "Event"
        }else{
            self.backgroundCol.backgroundColor = .green
            self.statusLabel.text = "Joined"
        }

    }
    
}
