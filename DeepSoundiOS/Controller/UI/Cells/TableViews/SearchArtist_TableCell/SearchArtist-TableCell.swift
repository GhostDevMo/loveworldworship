//
//  SearchArtist-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 12/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//


import UIKit

class SearchArtist_TableCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var vc: SearchArtistVC?
    var delegate : followUserDelegate?
    var indexPath:Int? = 0
    var status:Bool? = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
           self.loginAlert()
        }
        
    }
    func loginAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Login", comment: "Login"), message: NSLocalizedString("Sorry you can not continue, you must log in and enjoy access to everything you want", comment: "Sorry you can not continue, you must log in and enjoy access to everything you want"), preferredStyle: .alert)
        let yes = UIAlertAction(title: NSLocalizedString("YES", comment: "YES") , style: .default) { (action) in
            if self.vc != nil {
                self.vc?.appDelegate.window?.rootViewController = R.storyboard.login.main()
            }
        }
        let no = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil {
            self.vc?.present(alert, animated: true, completion: nil)
            
        }
    }
}
