//
//  SectionHeaderTableViewCell.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 16/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SectionHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUniqueName: UILabel!
    
    @IBOutlet weak var isVerified: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(){
        
        self.userName.text = AppInstance.instance.userProfile?.data?.username ?? ""
        self.userUniqueName.text =  "\(AppInstance.instance.userProfile?.data?.username ?? "")"
        let url = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        profileImage.sd_setImage(with: url , placeholderImage:R.image.no_profile_image())
    
        if AppInstance.instance.userProfile?.data?.isPro == 0{
            self.isVerified.isHidden = true
        }else{
            self.isVerified.isHidden = false
        }
    }
    
}
