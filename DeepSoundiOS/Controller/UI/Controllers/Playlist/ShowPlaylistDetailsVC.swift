//
//  ShowPlaylistDetailsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import PanModal
class ShowPlaylistDetailsVC: BaseVC {
    
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var scrolView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var playlistObject:PlaylistModel.Playlist?
    var publicPlaylistObject:PublicPlaylistModel.Playlist?
    var searchPlaylistObject:SearchModel.Playlist?
    var ProfilePlaylistObject:PlaylistModel.Playlist?
    
    var userID:Int? = 0
    private var playlistSongsArray = [GetPlaylistSongsModel.Song]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var playlistSongMusicArray = [MusicPlayerModel]()
    private var musicPlayerArray = [MusicPlayerModel]()
    private var  playlistID:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchPlaylistSongs()
        self.playlistLabel.text = NSLocalizedString("Playlist", comment: "Playlist")
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func playPressed(_ sender: Any) {
        let object = self.playlistSongsArray[0]
               AppInstance.instance.player = nil
               AppInstance.instance.AlreadyPlayed = false
               
               self.playlistSongsArray.forEach({ (it) in
                   var audioString:String? = ""
                   var isDemo:Bool? = false
                   let name = it.publisher?.name ?? ""
                   let time = it.timeFormatted ?? ""
                   let title = it.title ?? ""
                   let musicType = it.categoryName ?? ""
                   let thumbnailImageString = it.thumbnail ?? ""
                   if it.demoTrack == ""{
                       audioString = it.audioLocation ?? ""
                       isDemo = false
                   }else if it.demoTrack != "" && it.audioLocation != ""{
                       audioString = it.audioLocation ?? ""
                       isDemo = false
                   }else{
                       audioString = it.demoTrack ?? ""
                       isDemo = true
                   }
                   let isOwner = it.isOwner ?? false
                   let audioId = it.audioID ?? ""
                   
                   let likeCount = it.countLikes?.intValue ?? 0
                   let favoriteCount = it.countFavorite?.intValue ?? 0
                   let recentlyPlayedCount = it.countViews?.intValue ?? 0
                   let sharedCount = it.countShares?.intValue ?? 0
                   let commentCount = it.countComment?.intValue ?? 0
                   
                   let trackId = it.id ?? 0
                   let isLiked = it.isLiked ?? false
                   let isFavorited = it.isFavoriated ?? false
                   
                   let likecountString = it.countLikes?.stringValue ?? ""
                   let favoriteCountString = it.countFavorite?.stringValue ?? ""
                   let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                   let sharedCountString = it.countShares?.stringValue ?? ""
                   let commentCountString = it.countComment?.stringValue ?? ""
                   
                   let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                   self.playlistSongMusicArray.append(musicObject)
               })
               var audioString:String? = ""
               var isDemo:Bool? = false
               let name = object.publisher?.name ?? ""
               let time = object.timeFormatted ?? ""
               let title = object.title ?? ""
               let musicType = object.categoryName ?? ""
               let thumbnailImageString = object.thumbnail ?? ""
               if object.demoTrack == ""{
                   audioString = object.audioLocation ?? ""
                   isDemo = false
               }else if object.demoTrack != "" && object.audioLocation != ""{
                   audioString = object.audioLocation ?? ""
                   isDemo = false
               }else{
                   audioString = object.demoTrack ?? ""
                   isDemo = true
               }
               let isOwner = object.isOwner ?? false
               let audioId = object.audioID ?? ""
               
               let likeCount = object.countLikes?.intValue ?? 0
               let favoriteCount = object.countFavorite?.intValue ?? 0
               let recentlyPlayedCount = object.countViews?.intValue ?? 0
               let sharedCount = object.countShares?.intValue ?? 0
               let commentCount = object.countComment?.intValue ?? 0
               
               let trackId = object.id ?? 0
               let isLiked = object.isLiked ?? false
               let isFavorited = object.isFavoriated ?? false
               
               let likecountString = object.countLikes?.stringValue ?? ""
               let favoriteCountString = object.countFavorite?.stringValue ?? ""
               let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
               let sharedCountString = object.countShares?.stringValue ?? ""
               let commentCountString = object.countComment?.stringValue ?? ""
        let duration = object.duration ?? "0:0"
               let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
               popupContentController!.popupItem.title = object.publisher?.name ?? ""
               popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
        let cell  = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BrowseAlbums_TableCell
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
                  
                  AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
               self.addToRecentlyWatched(trackId: object.id ?? 0)
               
               tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                   
                   self.popupContentController?.musicObject = musicObject
                   self.popupContentController!.musicArray = self.playlistSongMusicArray
                   self.popupContentController!.currentAudioIndex = 0
                 self.popupContentController?.setup()
                   
               })
    }
    @IBAction func morePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            if AppInstance.instance.userId == self.userID ?? 0 {
                //self.showMoreAlert()
            }else{
                self.showMoreAlertforNonSameUser()
            }
        }else{
            notLoggedInAlert()
        }
    }
    
    private func setupUI(){
        playBtn.backgroundColor = .lightButtonColor
        playBtn.setTitleColor(.ButtonColor, for: .normal)
        shuffleBtn.backgroundColor = .ButtonColor
        if self.playlistObject != nil{
            
            self.title = self.playlistObject?.name ?? ""
            let url = URL.init(string:playlistObject?.thumbnailReady ?? "")
            self.playlistNameLabel.text = playlistObject?.name ?? ""
            //self.nameLabel.text = "By \(playlistObject?.publisher?.name ?? "")"
            thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            //coverImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            self.userID = playlistObject?.publisher?.id ?? 0
            
        }else if self.publicPlaylistObject != nil{
            self.title = self.publicPlaylistObject?.name ?? ""
            let url = URL.init(string: publicPlaylistObject?.thumbnailReady ?? "")
            self.playlistNameLabel.text =  publicPlaylistObject?.name ?? ""
           // self.nameLabel.text = "By \(publicPlaylistObject?.publisher?.name ?? "")"
            thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            //coverImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            self.userID = publicPlaylistObject?.publisher?.id ?? 0
            
        }else if self.searchPlaylistObject != nil{
            
            self.title = self.searchPlaylistObject?.name ?? ""
            let url = URL.init(string: searchPlaylistObject?.thumbnailReady ?? "")
            self.playlistNameLabel.text = searchPlaylistObject?.name ?? ""
            //self.nameLabel.text = "By \(searchPlaylistObject?.publisher?.name ?? "")"
            thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            //coverImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            self.userID = searchPlaylistObject?.publisher?.id ?? 0
            
        }else if self.ProfilePlaylistObject != nil{
            self.title = self.ProfilePlaylistObject?.name ?? ""
            let url = URL.init(string: ProfilePlaylistObject?.thumbnailReady ?? "")
            self.playlistNameLabel.text = ProfilePlaylistObject?.name ?? ""
           // self.nameLabel.text = "By \(ProfilePlaylistObject?.publisher?.name ?? "")"
            thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
           // coverImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            self.userID = ProfilePlaylistObject?.publisher?.id ?? 0
        }
        
        
        
        self.tableView.separatorStyle = .none
        tableView.register(BrowseAlbums_TableCell.nib, forCellReuseIdentifier: BrowseAlbums_TableCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        self.tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        
        let button = UIButton()
        button.setImage(UIImage(named: "ic-round-dotedmore"), for:.normal)
        button.addTarget(self, action: #selector(showMoreAlert), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let barButton = UIBarButtonItem(customView: button)
       self.navigationItem.rightBarButtonItem = barButton
        
    }
    @objc func showMoreAlert(){
        let alert = UIAlertController(title:NSLocalizedString("Playlist", comment: "Playlist"), message: "", preferredStyle: .actionSheet)
        let deleteAlbum = UIAlertAction(title:NSLocalizedString("Delete Playlist", comment: "Delete Playlist") , style: .default) { (action) in
            
            if self.ProfilePlaylistObject != nil{
                self.deletePlaylist(playlistID: self.ProfilePlaylistObject?.id ?? 0)
            }else if self.playlistObject != nil{
                self.deletePlaylist(playlistID: self.playlistObject?.id ?? 0)
            }else if self.publicPlaylistObject != nil{
                self.deletePlaylist(playlistID: self.publicPlaylistObject?.id ?? 0)
            }else if self.searchPlaylistObject != nil{
                self.deletePlaylist(playlistID: self.searchPlaylistObject?.id ?? 0)
            }
            
        }
        let EditAlbum = UIAlertAction(title: NSLocalizedString("Edit Playlist", comment: "Edit Playlist"), style: .default) { (action) in
            log.verbose("Edit Song")
            
            let vc = R.storyboard.playlist.updatePlaylistVC()
            if self.playlistObject != nil{
                
                let object = UpdatePlayLISTModel(playlistID: self.playlistObject?.id ?? 0, title: self.playlistObject?.name ?? "", privacy: self.playlistObject?.privacy ?? 0, imageString: self.playlistObject?.thumbnailReady ?? "")
                vc!.object = object
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }else if self.publicPlaylistObject != nil{
                let object = UpdatePlayLISTModel(playlistID: self.publicPlaylistObject?.id ?? 0, title: self.publicPlaylistObject?.name ?? "", privacy: self.publicPlaylistObject?.privacy ?? 0, imageString: self.publicPlaylistObject?.thumbnailReady ?? "")
                vc!.object = object
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }else if self.searchPlaylistObject != nil{
                let object = UpdatePlayLISTModel(playlistID: self.searchPlaylistObject?.id ?? 0, title: self.searchPlaylistObject?.name ?? "", privacy: self.searchPlaylistObject?.privacy ?? 0, imageString: self.searchPlaylistObject?.thumbnailReady ?? "")
                vc!.object = object
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }else if self.ProfilePlaylistObject != nil{
                let object = UpdatePlayLISTModel(playlistID: self.ProfilePlaylistObject?.id ?? 0, title: self.ProfilePlaylistObject?.name ?? "", privacy: self.ProfilePlaylistObject?.privacy ?? 0, imageString: self.ProfilePlaylistObject?.thumbnailReady ?? "")
                vc!.object = object
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
            
            
        }
        let ShareAlbum = UIAlertAction(title: NSLocalizedString("Share", comment: "Share") , style: .default) { (action) in
            if self.playlistObject != nil{
                self.share(shareString: self.playlistObject?.url ?? "")
                
            }else if self.publicPlaylistObject != nil{
                self.share(shareString: self.publicPlaylistObject?.url ?? "")
                
            }else if self.searchPlaylistObject != nil{
                
                self.share(shareString: self.searchPlaylistObject?.url ?? "")
                
            }else if self.ProfilePlaylistObject != nil{
                self.share(shareString: self.ProfilePlaylistObject?.url ?? "")
            }
            
            
        }
        let CopyAlbum = UIAlertAction(title:  NSLocalizedString("Copy Playlist Link", comment: "Copy Playlist Link"), style: .default) { (action) in
            if self.playlistObject != nil{
                UIPasteboard.general.string = self.playlistObject?.url ?? ""
                
            }else if self.publicPlaylistObject != nil{
                UIPasteboard.general.string = self.publicPlaylistObject?.url ?? ""
                
            }else if self.searchPlaylistObject != nil{
                
                UIPasteboard.general.string = self.searchPlaylistObject?.url ?? ""
                
            }else if self.ProfilePlaylistObject != nil{
                UIPasteboard.general.string = self.ProfilePlaylistObject?.url ?? ""
            }
            
            self.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(deleteAlbum)
        alert.addAction(EditAlbum)
        alert.addAction(ShareAlbum)
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
         alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func showMoreAlertforNonSameUser(){
        let alert = UIAlertController(title:NSLocalizedString("Playlist", comment: "Playlist") , message: "", preferredStyle: .actionSheet)
        let ShareAlbum = UIAlertAction(title:NSLocalizedString("Share", comment: "Share") , style: .default) { (action) in
            
            log.verbose("Share")
            
            if self.playlistObject != nil{
                self.share(shareString: self.playlistObject?.url ?? "")
                
            }else if self.publicPlaylistObject != nil{
                self.share(shareString: self.publicPlaylistObject?.url ?? "")
                
            }else if self.searchPlaylistObject != nil{
                
                self.share(shareString: self.searchPlaylistObject?.url ?? "")
                
            }else if self.ProfilePlaylistObject != nil{
                self.share(shareString: self.ProfilePlaylistObject?.url ?? "")
            }
            
            
        }
        let CopyAlbum = UIAlertAction(title:NSLocalizedString("Copy Playlist Link", comment: "Copy Playlist Link") , style: .default) { (action) in
            if self.playlistObject != nil{
                UIPasteboard.general.string = self.playlistObject?.url ?? ""
                
            }else if self.publicPlaylistObject != nil{
                UIPasteboard.general.string = self.publicPlaylistObject?.url ?? ""
                
            }else if self.searchPlaylistObject != nil{
                
                UIPasteboard.general.string = self.searchPlaylistObject?.url ?? ""
                
            }else if self.ProfilePlaylistObject != nil{
                UIPasteboard.general.string = self.ProfilePlaylistObject?.url ?? ""
            }
            
            
            self.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            
        }
        let cancel = UIAlertAction(title:NSLocalizedString("Cancel", comment: "Cancel") , style: .destructive, handler: nil)
        
        alert.addAction(ShareAlbum)
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
         alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func notLoggedInAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Playlist", comment: "Playlist"), message: "", preferredStyle: .actionSheet)
        
        let CopyAlbum = UIAlertAction(title:NSLocalizedString("Copy Playlist Link", comment: "Copy Playlist Link") , style: .default) { (action) in
            if self.playlistObject != nil{
                UIPasteboard.general.string = self.playlistObject?.url ?? ""
                
            }else if self.publicPlaylistObject != nil{
                UIPasteboard.general.string = self.publicPlaylistObject?.url ?? ""
                
            }else if self.searchPlaylistObject != nil{
                
                UIPasteboard.general.string = self.searchPlaylistObject?.url ?? ""
                
            }else if self.ProfilePlaylistObject != nil{
                UIPasteboard.general.string = self.ProfilePlaylistObject?.url ?? ""
            }
            
            
            self.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
         alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func playSong(sender:UIButton){
        
        
      AppInstance.instance.player = nil
      AppInstance.instance.AlreadyPlayed = false

            let object = playlistSongsArray[sender.tag]
            
            for i in 0...playlistSongsArray.count{
                
                if i == sender.tag{
                    if AppInstance.instance.player?.timeControlStatus == .playing {
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? SongsTableCells
                        //changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                    }else{
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! SongsTableCells
                        //changeButtonImage(cell.btnPlayPause, play: false)
                    }
                }
                else{
                    let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells
                    //changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                }
            }
        playlistSongsArray.forEach({ (object) in
                var audioString:String? = ""
                var isDemo:Bool? = false
                if object.demoTrack == ""{
                    audioString = object.audioLocation ?? ""
                    isDemo = false
                }else if object.demoTrack != "" && object.audioLocation != ""{
                    audioString = object.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = object.demoTrack ?? ""
                    isDemo = true
                }
                let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment?.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment?.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false)
                self.musicPlayerArray.append(musicObject)
                
            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            if object.demoTrack == ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else if object.demoTrack != "" && object.audioLocation != ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.demoTrack ?? ""
                isDemo = true
            }
        let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment?.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment?.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })
                                                   
    }
    @objc func didTapSongsMore(sender:UIButton){
            
            let object = self.playlistSongsArray[sender.tag]
            var audioString:String? = ""
            var isDemo:Bool? = false
            if object.demoTrack == ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else if object.demoTrack != "" && object.audioLocation != ""{
                audioString = object.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.demoTrack ?? ""
                isDemo = true
            }
            let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment?.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment?.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false)
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
            presentPanModal(panVC)
        }
    private func share(shareString:String?){
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    private func fetchPlaylistSongs(){
        if Connectivity.isConnectedToNetwork(){
            self.playlistSongsArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            if self.playlistObject != nil{
                self.playlistID = playlistObject?.id ?? 0
                
            }else if self.publicPlaylistObject != nil{
                
                self.playlistID = publicPlaylistObject?.id ??  0
            }else if self.searchPlaylistObject != nil{
                self.playlistID =  searchPlaylistObject?.id ?? 0
                
            }else if self.ProfilePlaylistObject != nil{
                self.playlistID = ProfilePlaylistObject?.id ??  0
            }
            
            Async.background({
                PlaylistManager.instance.getPlayListSongs(playlistId: self.playlistID ?? 0, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.songs ?? [])")
                                self.playlistSongsArray = success?.songs ?? []
                                
                                self.tableView.reloadData()
                                self.songsCountLabel.text = "\(self.playlistSongsArray.count ?? 0) Songs"
                                if self.playlistSongsArray.count == 0{
                                    self.playBtn.isHidden = true
                                }else{
                                    self.playBtn.isHidden = false
                                }
                                self.scrollHeight.constant = self.scrollHeight.constant + self.tableView.contentSize.height - 20.0
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func deletePlaylist(playlistID:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PlaylistManager.instance.deletePlaylist(playlistId: playlistID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                            
                            
                        })
                    }else {
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                    }
                }
            })
        }else{
            
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
            
        }
    }
}
extension ShowPlaylistDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.playlistSongsArray.isEmpty{
            return 1
        }else{
            return self.playlistSongsArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.playlistSongsArray.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
//            cell?.playlistVC = self
//            cell?.likeDelegate = self
//            cell?.indexPath = indexPath.row
            let object = self.playlistSongsArray[indexPath.row]
            cell?.bindPlaylistSong(object, index: indexPath.row)
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            return cell!
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.playlistSongsArray.isEmpty{
            log.verbose("Nothing")
          }else{
             let object = self.playlistSongsArray[indexPath.row]
                    AppInstance.instance.player = nil
                    AppInstance.instance.AlreadyPlayed = false
                    
                    self.playlistSongsArray.forEach({ (it) in
                        var audioString:String? = ""
                        var isDemo:Bool? = false
                        let name = it.publisher?.name ?? ""
                        let time = it.timeFormatted ?? ""
                        let title = it.title ?? ""
                        let musicType = it.categoryName ?? ""
                        let thumbnailImageString = it.thumbnail ?? ""
                        if it.demoTrack == ""{
                            audioString = it.audioLocation ?? ""
                            isDemo = false
                        }else if it.demoTrack != "" && it.audioLocation != ""{
                            audioString = it.audioLocation ?? ""
                            isDemo = false
                        }else{
                            audioString = it.demoTrack ?? ""
                            isDemo = true
                        }
                        let isOwner = it.isOwner ?? false
                        let audioId = it.audioID ?? ""
                        
                        let likeCount = it.countLikes?.intValue ?? 0
                        let favoriteCount = it.countFavorite?.intValue ?? 0
                        let recentlyPlayedCount = it.countViews?.intValue ?? 0
                        let sharedCount = it.countShares?.intValue ?? 0
                        let commentCount = it.countComment?.intValue ?? 0
                        
                        let trackId = it.id ?? 0
                        let isLiked = it.isLiked ?? false
                        let isFavorited = it.isFavoriated ?? false
                        
                        let likecountString = it.countLikes?.stringValue ?? ""
                        let favoriteCountString = it.countFavorite?.stringValue ?? ""
                        let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                        let sharedCountString = it.countShares?.stringValue ?? ""
                        let commentCountString = it.countComment?.stringValue ?? ""
                        
                        let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                        self.playlistSongMusicArray.append(musicObject)
                    })
                    var audioString:String? = ""
                    var isDemo:Bool? = false
                    let name = object.publisher?.name ?? ""
                    let time = object.timeFormatted ?? ""
                    let title = object.title ?? ""
                    let musicType = object.categoryName ?? ""
                    let thumbnailImageString = object.thumbnail ?? ""
                    if object.demoTrack == ""{
                        audioString = object.audioLocation ?? ""
                        isDemo = false
                    }else if object.demoTrack != "" && object.audioLocation != ""{
                        audioString = object.audioLocation ?? ""
                        isDemo = false
                    }else{
                        audioString = object.demoTrack ?? ""
                        isDemo = true
                    }
                    let isOwner = object.isOwner ?? false
                    let audioId = object.audioID ?? ""
                    
                    let likeCount = object.countLikes?.intValue ?? 0
                    let favoriteCount = object.countFavorite?.intValue ?? 0
                    let recentlyPlayedCount = object.countViews?.intValue ?? 0
                    let sharedCount = object.countShares?.intValue ?? 0
                    let commentCount = object.countComment?.intValue ?? 0
                    
                    let trackId = object.id ?? 0
                    let isLiked = object.isLiked ?? false
                    let isFavorited = object.isFavoriated ?? false
                    
                    let likecountString = object.countLikes?.stringValue ?? ""
                    let favoriteCountString = object.countFavorite?.stringValue ?? ""
                    let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
                    let sharedCountString = object.countShares?.stringValue ?? ""
                    let commentCountString = object.countComment?.stringValue ?? ""
              let duration = object.duration ?? "0:0"
                    let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
                    popupContentController!.popupItem.title = object.publisher?.name ?? ""
                    popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
                    let cell  = tableView.cellForRow(at: indexPath) as? BrowseAlbums_TableCell
                    popupContentController!.popupItem.image = cell?.thumbnailImage.image
                              
                              AppInstance.instance.popupPlayPauseSong = false
                    SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                    self.addToRecentlyWatched(trackId: object.id ?? 0)
                    
                    tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                        
                        self.popupContentController?.musicObject = musicObject
                        self.popupContentController!.musicArray = self.playlistSongMusicArray
                        self.popupContentController!.currentAudioIndex = indexPath.row
                        self.popupContentController?.setup()
                    })
          }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}



extension ShowPlaylistDetailsVC:likeDislikeSongDelegate{
    
    func likeDisLikeSong(status: Bool, button: UIButton,audioId:String) {
        
        if status{
            
            button.setImage(R.image.ic_heartOutlinePlayer(), for: .normal)
            self.likeDislike(audioId: audioId, button: button)
        }else{
            button.setImage(R.image.ic_heartRed(), for: .normal)
            self.likeDislike(audioId: audioId, button: button)
        }
    }
    
    private func likeDislike(audioId:String,button:UIButton){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId ?? ""
            Async.background({
                likeManager.instance.likeDisLikeSong(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.mode ?? "")")
                                if success?.mode == "disliked"{
                                    button.setImage(R.image.ic_outlineHeart(), for: .normal)
                                }else{
                                    button.setImage(R.image.ic_redHeart(), for: .normal)
                                }
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
}

extension ShowPlaylistDetailsVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
    
}
