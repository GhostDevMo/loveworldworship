
//
//  GenresSongs-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Foundation

class GenresSongs_TableCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var sharedCountlabel: UILabel!
    @IBOutlet weak var recentlyPlayedCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var delegate:showReportScreenDelegate?
    var IndexPath:Int? = 0
    var songLink:String? = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    @IBAction func morePressed(_ sender: Any) {
        self.delegate!.showReportScreen(Status: true, IndexPath: IndexPath ?? 0, songLink: self.songLink ?? "")
    }
}
