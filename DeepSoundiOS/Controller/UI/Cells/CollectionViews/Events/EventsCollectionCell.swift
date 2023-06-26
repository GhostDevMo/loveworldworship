//
//  EventsCollectionCell.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class EventsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var EventImage: UIImageView!
    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var EventDescription: UILabel!
    @IBOutlet weak var EventDate: UILabel!
    @IBOutlet weak var EventWebsite: UILabel!
    
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    
    var object = [[String:Any]]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ object:[String:Any]){
        
    let name = object["name"] as? String
        let description = object["desc"] as? String
        let eventDate = object["start_date"] as? String
        let image = object["image"] as? String
        let onlineUrl = object["online_url"] as? String
        let userdata = object["user_data"] as? [String:Any]
        let id = userdata?["id"] as? Int
        self.EventTitle.text = name
        self.EventDescription.text = description
        self.EventDate.text = eventDate
        self.EventWebsite.text = onlineUrl

        if id == AppInstance.instance.userId ?? 0{
            self.eventView.backgroundColor = .mainColor
            self.eventTypeLabel.text = "My Event"
        }else{
            self.eventView.backgroundColor = .mainColor
            self.eventTypeLabel.text = "Event"
        }
        
        let url = URL.init(string:image ?? "")
        self.EventImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())

    }
}
