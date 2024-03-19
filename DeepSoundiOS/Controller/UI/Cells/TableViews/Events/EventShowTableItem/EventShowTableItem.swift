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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backgroundCol: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.addShadow()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object: Events) {
        self.titleLabel.text = object.name
        self.descriptionLabel.text = object.desc?.htmlAttributedString
        self.dateLabel.text = object.start_date
        if object.real_address == "" || object.real_address == nil {
            self.locationLabel.text = object.online_url
        }else {
            self.locationLabel.text = object.real_address?.htmlAttributedString?.replacingOccurrences(of: "<br>", with: "")
        }
        let url = URL.init(string:object.image ?? "")
        self.imageLabel.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if object.user_id != AppInstance.instance.userId {
            self.backgroundCol.backgroundColor = .mainColor
            self.statusLabel.text = "Event"
        }else{
            self.backgroundCol.backgroundColor = .red
            self.statusLabel.text = "My Event"
        }
    }
}
