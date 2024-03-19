//
//  ArtistTableCell.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 26/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class ArtistTableCell: UITableViewCell {
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var imageVerify: UIImageView!
    @IBOutlet weak var lblAlbumCount: UILabel!
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    
    var delegate : followUserDelegate?
    var indexPath:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgArtist.image = nil
    }
    
    func bind(_ object: Publisher) {
        if object.name ?? "" == ""{
            lblArtistName.text = object.username ?? ""
        }else{
            lblArtistName.text =  object.name ?? ""
        }
        let url = URL.init(string:object.avatar ?? "")
        imgArtist.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
        self.lblAlbumCount.text = "Artists"
        self.imageVerify.isHidden = object.verified == 0
        if object.is_following {
            self.btnFollow.setTitle("Following", for: .normal)
            self.btnFollow.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
            self.btnFollow.setTitleColor(.mainColor, for: .normal)
        }else {
            self.btnFollow.setTitle("Follow", for: .normal)
            self.btnFollow.backgroundColor = .mainColor
            self.btnFollow.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func followingPressed(_ sender: UIButton) {
        self.delegate?.followUser(sender.tag, sender)
    }
    
}

