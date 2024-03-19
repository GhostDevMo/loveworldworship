//
//  SongsTableCells.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 26/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class SongsTableCells: UITableViewCell {

    @IBOutlet weak var lblSongDesc: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var lblSongDuration: UILabel!
    @IBOutlet weak var lblSongTittle: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var septView: UIView!
   
    var delegate: SongsTableCellsDelegate?
    var indexPath: IndexPath?
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ object: Song) {
        self.lblSongTittle.text = object.title?.htmlAttributedString ?? ""
        if object.duration == "" {
            self.lblSongDuration.text = "\(object.demo_duration ?? "")"
        } else {
            let time = object.duration?.components(separatedBy: ":").first
            let timeSTR = (Int(time ?? "") == 0) ? " Sec" : " Min"
            self.lblSongDuration.text = "\(object.duration ?? "")" + timeSTR
        }
        if object.publisher?.name == "" {
            lblSongDesc.text = object.publisher?.username ?? ""
        } else {
            lblSongDesc.text = object.publisher?.name ?? ""
        }
        let url = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        if (popupContentController?.musicObject?.id == object.id) {
            self.btnPlayPause.setImage(UIImage(named: (!AppInstance.instance.AlreadyPlayed) ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
        }else {
            self.btnPlayPause.setImage(UIImage(named: "ic-play-btn"), for: .normal)
        }
    }
    
    func bind(_ object: Song, index:Int) {
        self.lblSongTittle.text = object.title?.htmlAttributedString ?? ""
        if object.duration == "" {
            self.lblSongDuration.text = "\(object.demo_duration ?? "")"
        } else {
            let time = object.duration?.components(separatedBy: ":").first
            let timeSTR = (Int(time ?? "") == 0) ? " Sec" : " Min"
            self.lblSongDuration.text = "\(object.duration ?? "")" + timeSTR
        }
        if object.publisher?.name == "" {
            lblSongDesc.text = "\(object.category_name ?? "") - \(object.publisher?.username ?? "")"
        } else {
            lblSongDesc.text = "\(object.category_name ?? "") - \(object.publisher?.name ?? "")"
        }
        let url = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if (popupContentController?.musicObject?.id == object.id) {
            self.btnPlayPause.setImage(UIImage(named: (!AppInstance.instance.AlreadyPlayed) ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
        }else {
            self.btnPlayPause.setImage(UIImage(named: "ic-play-btn"), for: .normal)
        }
    }
    
    func bindProfilePlayList(_ object: Playlist, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail_ready ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.name ?? ""
        self.lblSongDesc.text = "\(object.songs ?? 0 ) Songs"
        self.lblSongDuration.text = ""
        self.btnPlayPause.isHidden = true
        self.lblSongDuration.isHidden = true
        self.septView.isHidden = true
    }
   
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.playButtonPressed(sender, indexPath: indexPath, cell: self)
        }
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.moreButtonPressed(sender, indexPath: indexPath, cell: self)
        }
    }
}
