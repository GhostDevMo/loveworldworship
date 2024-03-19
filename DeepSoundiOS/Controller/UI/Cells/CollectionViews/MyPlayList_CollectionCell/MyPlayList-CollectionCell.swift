//
//  MyPlayList-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 09/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class MyPlayList_CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
    
    var delegate:showPlaylistPopupDelegate?
    var indexPath:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
    }
    
    @IBAction func morePressed(_ sender: UIButton) {
        self.delegate?.showPlaylistPopup(status:true,index:self.indexPath)
    }
    
}
