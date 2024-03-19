//
//  EventsCollectionCell.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class EventsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var EventImage: UIImageView!
    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var EventDescription: UILabel!
    @IBOutlet weak var EventDate: UILabel!
    @IBOutlet weak var EventWebsite: UILabel!
    
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainView.addShadow()
    }
    
    func bind(_ object: Events) {
        self.EventTitle.text = object.name
        self.EventDescription.text = object.desc?.htmlAttributedString
        self.EventDate.text = object.start_date
        if object.real_address == "" || object.real_address == nil {
            self.EventWebsite.text = object.online_url
        }else {
            self.EventWebsite.text = object.real_address
        }
        if object.id == AppInstance.instance.userId {
            self.eventView.backgroundColor = .mainColor
            self.eventTypeLabel.text = "My Event"
        }else{
            self.eventView.backgroundColor = .red
            self.eventTypeLabel.text = "Event"
        }
        
        let url = URL.init(string: object.image ?? "")
        self.EventImage.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
    }
}
