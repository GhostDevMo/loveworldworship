
//
//  ProfilePlaylistCollectionCell.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/18/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ProfilePlaylistCollectionCell: UICollectionViewCell {
    @IBOutlet weak var songsCountLabel: UILabel!
      @IBOutlet weak var titleLabel: UILabel!
      @IBOutlet weak var thumnbnailImage: UIImageView!
    @IBOutlet weak var btnMore: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(_ object:PlaylistModel.Playlist){
        let thumbnailURL = URL.init(string:object.thumbnailReady ?? "")
           self.thumnbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.name ?? ""
         songsCountLabel.text = "\(object.songs  ?? 0) \(NSLocalizedString("Songs", comment: "Songs")) "
         
       }
    func publicPlaylistBind(_ object:PublicPlaylistModel.Playlist){
     let thumbnailURL = URL.init(string:object.thumbnailReady ?? "")
        self.thumnbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
     titleLabel.text = object.name ?? ""
      songsCountLabel.text = "\(object.songs  ?? 0) \(NSLocalizedString("Songs", comment: "Songs")) "
      
    }
    func searchPlayListBind(_ object:SearchModel.Playlist){
        let thumbnailURL = URL.init(string:object.thumbnailReady ?? "")
           self.thumnbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.name ?? ""
         songsCountLabel.text = "\(object.songs  ?? 0) \(NSLocalizedString("Songs", comment: "Songs")) "
         
       }
}
