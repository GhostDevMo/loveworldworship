//
//  SettingNotificationItem.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 16/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit


class SettingNotificationItem: UITableViewCell {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var delegate:OnNotificationSettingsDelegate?
    var indexPath:Int? = 0
    var valueStatus:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ objectValue:Int){
        if objectValue == 0{
            self.notificationSwitch.isOn = false
        }else{
            self.notificationSwitch.isOn = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func swtichToggled(_ sender: Any) {
        if valueStatus == 0{
            self.delegate?.OnNotificationSettingsChanged(value: 1, index: indexPath ?? 0, status: notificationSwitch.isOn)
        }else{
            self.delegate?.OnNotificationSettingsChanged(value: 0, index: indexPath ?? 0, status: notificationSwitch.isOn)
        }
       
      
        
    }
}
