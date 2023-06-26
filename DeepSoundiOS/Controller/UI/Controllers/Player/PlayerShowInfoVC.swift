//
//  PlayerShowInfoVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import MediaPlayer
class PlayerShowInfoVC: BaseVC {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var purchaseRequired: UILabel!
    @IBOutlet weak var ageRestriction: UILabel!
    @IBOutlet weak var lyricAvailable: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var shareCountLabel: UILabel!
    @IBOutlet weak var recentlyPlayedCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var tiltleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var smallthumbnailImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var musicObject:MusicPlayerModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.nameLabel.textColor = .mainColor

    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI(){
        self.tiltleLabel.text = self.musicObject?.title ?? ""
        self.nameLabel.text = self.musicObject?.name ?? ""
        self.timeLabel.text = self.musicObject?.time ?? ""
        self.likeCountLabel.text = "\(self.musicObject?.likeCount ?? 0)"
         self.favoriteCountLabel.text = "\(self.musicObject?.favoriteCount ?? 0)"
        self.recentlyPlayedCountLabel.text = "\(self.musicObject?.recentlyPlayedCount ?? 0)"
        self.shareCountLabel.text = "\(self.musicObject?.sharedCount ?? 0)"
        self.commentCountLabel.text = "\(self.musicObject?.commentCount ?? 0)"
        self.typeLabel.text = self.musicObject?.musicType ?? ""
        let url = URL.init(string:musicObject?.ThumbnailImageString ?? "")
        thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        smallthumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        

    }
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d", minutes,seconds)
    }
}
