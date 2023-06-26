//
//  SelectPlaylist_TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SelectPlaylist_TableCell: UITableViewCell {

    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    private var status:Bool? = false
    var playListIdArray = [PlaylistModel.Playlist]()
    var indexPath:Int? = 0
    var delegate: didSetPlaylistDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    @IBAction func selectPressed(_ sender: Any) {
        self.status = !status!
        
        if status!{
            self.delegate?.didPlaylist(Image: self.checkImage, status: status ?? false, idsArray: playListIdArray, Index: indexPath!)
        }else{
              self.delegate?.didPlaylist(Image: self.checkImage, status: status ?? false, idsArray: playListIdArray, Index: indexPath!)
        }
    }
}
