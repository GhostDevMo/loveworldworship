//
//  ArtistInfoCell.swift
//  DeepSoundiOS
//
//  Created by Moghees on 25/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

protocol ArtistInfoCellDelegate {
    func followUnfollowBtnAction(_ sender: UIButton)
    func messageBtnAction(_ sender: UIButton)
}

class ArtistInfoCell: UITableViewCell {
    
    @IBOutlet weak var imageVerify: UIImageView!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    
    var delegate: ArtistInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnMessage.addShadow(offset: .init(width: 0, height: 2), radius: 2, opacity: 0.5)
        self.btnFollow.addShadow(offset: .init(width: 0, height: 2), radius: 2, opacity: 0.5)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object: Publisher) {
        let url = URL.init(string: object.avatar ?? "")
        self.imgArtist.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
        if let name = object.name {
            self.lblName.text = name
        }else {
            self.lblName.text = object.username
        }
        self.lblDescription.text = object.about_decoded ?? "Has not any info"
        
        btnFollow.setTitle(object.is_following ? "Following" : "Follow", for: .normal)
        btnFollow.backgroundColor = object.is_following ? .hexStringToUIColor(hex: "FFF8ED") : .mainColor
        btnFollow.setTitleColor(object.is_following ? .mainColor : .white, for: .normal)
        imageVerify.isHidden = object.verified == 0
    }
    
    @IBAction func followBtnAction(_ sender: UIButton) {
        self.delegate?.followUnfollowBtnAction(sender)
    }
    
    @IBAction func messageBtnAction(_ sender: UIButton) {
        self.delegate?.messageBtnAction(sender)
    }
}
