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
    var loggedInVC:Dashboard1VC?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ object:DiscoverModel.Song?){
        self.lblSongTittle.text = object?.title?.htmlAttributedString ?? ""
        if object?.duration == ""{
            self.lblSongDuration.text = "\(object?.demoDuration ?? "")"
        }
        else{
            self.lblSongDuration.text = "\(object?.duration ?? "")"
        }
        if  object?.publisher?.name == ""{
            lblSongDesc.text = object?.publisher?.username ?? ""
        }
        else{
            lblSongDesc.text = object?.publisher?.name ?? ""
        }
       
        
        let url = URL.init(string:object?.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    func bindinfoList(_ object:UserInfoModel.Latestsong?){
        self.lblSongTittle.text = object?.title?.htmlAttributedString ?? ""
        if object?.duration == ""{
            self.lblSongDuration.text = "\(object?.demoDuration ?? "")"
        }
        else{
            self.lblSongDuration.text = "\(object?.duration ?? "")"
        }
        if  object?.publisher?.name == ""{
            lblSongDesc.text = object?.publisher?.username ?? ""
        }
        else{
            lblSongDesc.text = object?.publisher?.name ?? ""
        }
       
        
        let url = URL.init(string:object?.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    func bindTopSong(_ object:TrendingModel.TopSong?){
        self.lblSongTittle.text = object?.title?.htmlAttributedString ?? ""
        if object?.duration == ""{
            self.lblSongDuration.text = "\(object?.demoDuration ?? "")"
        }
        else{
            self.lblSongDuration.text = "\(object?.duration ?? "")"
        }
        if  object?.publisher?.name == ""{
            lblSongDesc.text = object?.publisher?.username ?? ""
        }
        else{
            lblSongDesc.text = object?.publisher?.name ?? ""
        }
       
        
        let url = URL.init(string:object?.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    func bindFavourite(_ object:FavoriteModel.Datum, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""
     
      
        
    }
    func bindSearchSong(_ object:SearchModel.Song, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""
     
      
        
    }
    func bindProfileSong(_ object:ProfileModel.Latestsong, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""

    }
    
    func bindPlaylistSong(_ object: GetPlaylistSongsModel.Song, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""
    }
    func bindLikeSong(_ object:LikedModel.Datum, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""
    }
    func bindLike(_ object:ProfileModel.Latestsong, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.title ?? ""
        self.lblSongDesc.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        self.lblSongDuration.text = object.duration ?? ""
    }
    
    func bindProfilePlayList(_ object:PlaylistModel.Playlist, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnailReady ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.name ?? ""
        self.lblSongDesc.text = "\(object.songs ?? 0 ) Songs"
        self.lblSongDuration.text = ""
        self.septView.isHidden = true
       
    }
    func bindSharedSong(_ object:MusicPlayerModel, index :Int){
        let thumbnailURL = URL.init(string:object.ThumbnailImageString ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblSongTittle.text = object.name ?? ""
       // self.lblSongDesc.text = "\(object.songs ?? 0 ) Songs"
        self.lblSongDuration.text = ""
        self.septView.isHidden = true
       
    }
    func bindRecentPlayedSong(_ object:DiscoverModel.Song?){
        
        self.lblSongTittle.text = object?.title?.htmlAttributedString ?? ""
        if object?.duration == ""{
            self.lblSongDuration.text = "\(object?.demoDuration ?? "")"
        }
        else{
            self.lblSongDuration.text = "\(object?.duration ?? "")"
        }
        if  object?.publisher?.name == ""{
            lblSongDesc.text = object?.publisher?.username ?? ""
        }
        else{
            lblSongDesc.text = object?.publisher?.name ?? ""
        }
       
        
        let url = URL.init(string:object?.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    
    func bindAlbumSong(_ object:GetAlbumSongsModel.Song?){
        
        self.lblSongTittle.text = object?.title?.htmlAttributedString ?? ""
        if object?.duration == ""{
            self.lblSongDuration.text = "\(object?.demoDuration ?? "")"
        }
        else{
            self.lblSongDuration.text = "\(object?.duration ?? "")"
        }
        if  object?.publisher?.name == ""{
            lblSongDesc.text = object?.publisher?.username ?? ""
        }
        else{
            lblSongDesc.text = object?.publisher?.name ?? ""
        }
       
        
        let url = URL.init(string:object?.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
