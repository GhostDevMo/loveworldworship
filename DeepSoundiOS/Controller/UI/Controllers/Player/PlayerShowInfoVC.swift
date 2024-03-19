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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var purchaseRequired: UILabel!
    @IBOutlet weak var ageRestriction: UILabel!
    @IBOutlet weak var lyricAvailable: ExpandableLabel!
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
    
    var musicObject: Song?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.nameLabel.textColor = .mainColor
    }
    
    private func setupUI() {
        if let musicObject = self.musicObject {
            self.tiltleLabel.text = musicObject.title ?? ""
            self.nameLabel.text = musicObject.publisher?.name ?? ""
            self.timeLabel.text = musicObject.time_formatted ?? ""
            if let data = musicObject.count_likes {
                self.likeCountLabel.text = getStringFromModel(model: data)
            }
            
            if let data = musicObject.count_likes {
                self.likeCountLabel.text = getStringFromModel(model: data)
            }
            
            if let data = musicObject.count_favorite {
                self.favoriteCountLabel.text = getStringFromModel(model: data)
            }
            
            if let data = musicObject.count_views {
                self.recentlyPlayedCountLabel.text = getStringFromModel(model: data)
            }
            
            if let data = musicObject.count_shares {
                self.shareCountLabel.text = getStringFromModel(model: data)
            }
            
            if let data = musicObject.count_comment {
                self.commentCountLabel.text = getStringFromModel(model: data)
            }
            
            if musicObject.lyrics == "" {
                self.lyricAvailable.text = "Not Available"
            }else {
                self.lyricAvailable.text = musicObject.lyrics?.htmlAttributedString
                self.lyricAvailable.delegate = self
                self.lyricAvailable.setLessLinkWith(lessLink: "\n Read Less", attributes: [.foregroundColor: UIColor.mainColor], position: .left)
                self.lyricAvailable.shouldCollapse = true
                self.lyricAvailable.textReplacementType = .word
                self.lyricAvailable.numberOfLines = 10
                self.lyricAvailable.collapsed = true
                self.lyricAvailable.text = musicObject.lyrics?.htmlAttributedString
            }
            self.about.text = musicObject.description?.htmlAttributedString
            var tag = ""
            for (index,i) in (musicObject.tags_array ?? []).enumerated() {
                if !(i.isEmpty) {
                    tag += "#\(i)"
                    if index != (musicObject.tags_array!.count - 1) {
                        tag += ", "
                    }
                }
            }
            if tag == "" {
                self.tags.text = "No Tags Available"
            }else {
                self.tags.text = tag
            }
            self.typeLabel.text = musicObject.songArray?.sCategory ?? ""
            let url = URL.init(string: musicObject.thumbnail ?? "")
            thumbnailImage.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
            smallthumbnailImage.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
            songDuration.text =  musicObject.duration
            if (musicObject.is_purchased ?? false) {
                purchaseRequired.text = "Yes"
            } else {
                purchaseRequired.text = "No"
            }
        }
    }
    
    func getStringFromModel(model:CountViews) -> String {
        switch model {
        case .integer(let value):
            return "\(value)"
        case .string(let value):
            return value
        }
    }
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        return String(format: "%02d:%02d", minutes,seconds)
    }
}

extension PlayerShowInfoVC: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        
    }
}

extension PlayerShowInfoVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y > 50.0 {
            self.headerView.isHidden = true
        } else {
            self.headerView.isHidden = false
        }
    }
}
