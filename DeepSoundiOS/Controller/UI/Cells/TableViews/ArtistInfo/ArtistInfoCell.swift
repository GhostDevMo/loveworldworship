//
//  ArtistInfoCell.swift
//  DeepSoundiOS
//
//  Created by Moghees on 25/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class ArtistInfoCell: UITableViewCell {

    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
