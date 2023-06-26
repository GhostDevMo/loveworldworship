
//
//  Comments-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Comments_TableCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var messegeTextView: UITextView!
    @IBOutlet weak var profileImage: UIImageView!
    
    var likeDislikeCommentDelegate:likeDislikeCommentDelegate?
    var indexPath:Int? = 0
    var songLink:String? = ""
    var likeStatus:Bool? = false
    var commentId:Int? = 0
    var commentDelegate:commentProfileDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.ProfileImageHandleTap(_:)))
         profileImage?.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(profileImageTap)
        
    }
    @objc func ProfileImageHandleTap(_ sender: UITapGestureRecognizer? = nil) {
      log.verbose("ProfilePressed")
        self.commentDelegate?.commentProfile(index: indexPath ?? 0, status: true)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func likePressed(_ sender: Any) {
        if self.likeStatus!{
            log.verbose("Status = \(likeStatus!)")
            self.likeDislikeCommentDelegate?.likeDisLikeComment(status: likeStatus!, button: likeBtn, commentId: self.commentId ?? 0)
        }else{
            log.verbose("Status = \(likeStatus!)")
            self.likeDislikeCommentDelegate?.likeDisLikeComment(status: likeStatus!, button: likeBtn, commentId: self.commentId ?? 0)
        }
    }
}
