//
//  Followings-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Followings_TableCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate : followUserDelegate?
    var vc:FollowingsVC?
    var indexPath:Int? = 0
    var status:Bool? = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func followingPressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            self.status = !status!
            if self.status!{
                self.delegate?.followUser(index: indexPath ?? 0, button: self.followingBtn,status:self.status!)
            }else{
                self.delegate?.followUser(index: indexPath ?? 0, button: self.followingBtn,status:self.status!)
            }
        }else{
            let vc = R.storyboard.popups.loginPopupVC()
            self.vc?.present(vc!, animated: true, completion: nil)
        }
        
    }
}
