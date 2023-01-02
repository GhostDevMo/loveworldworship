//
//  Playlist-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Playlist_CollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
