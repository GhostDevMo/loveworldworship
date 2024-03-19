//
//  ChatSenderTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ChatSenderTableItem: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func bind(_ object:GetMessage){
        self.titleLabel.text = object.text
        self.dateLabel.text = getDate(unixdate: object.time, timezone: "GMT")
    }
}

func getDate(unixdate: Int, timezone: String) -> String {
    if unixdate == 0 {return ""}
    let date = Date(timeIntervalSince1970: TimeInterval(unixdate))
    let dayTimePeriodFormatter = DateFormatter()
    if date.getDayMonthYearFormat() == Date().getDayMonthYearFormat() {
        dayTimePeriodFormatter.dateFormat = "h:mm a"
    }else {
        dayTimePeriodFormatter.dateStyle = .short
        //        dayTimePeriodFormatter.timeStyle = .short
    }
    dayTimePeriodFormatter.timeZone = .current
    let dateString = dayTimePeriodFormatter.string(from: date)
    return "\(dateString)"
}
