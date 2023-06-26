//
//  ArtistTableCell.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 26/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class ArtistTableCell: UITableViewCell {

    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblSongsCount: UILabel!
    @IBOutlet weak var lblAlbumCount: UILabel!
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    var loggedHomeVC:Dashboard1VC?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnMore.backgroundColor = .ButtonColor
    }
    func bind(_ object: ArtistModel.Datum){
    if object.name ?? "" == ""{
        lblArtistName.text = object.username ?? ""
    }else{
        lblArtistName.text =  object.name ?? ""
    }
    let url = URL.init(string:object.avatar ?? "")
        imgArtist.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
      
}
    func bindSearchArtist(_ object:SearchModel.Artist){
    if object.name ?? "" == ""{
        lblArtistName.text = object.username ?? ""
    }else{
        lblArtistName.text =  object.name ?? ""
    }
    let url = URL.init(string:object.avatar ?? "")
        imgArtist.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
      
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

