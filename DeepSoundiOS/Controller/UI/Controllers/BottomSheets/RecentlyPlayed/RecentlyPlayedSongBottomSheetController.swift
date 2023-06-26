//
//  SongBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import PanModal
import DeepSoundSDK
import SwiftEventBus
class RecentlyPlayedSongBottomSheetController: UIViewController, PanModalPresentable{
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblSongDuration: UILabel!
    @IBOutlet weak var lblSongDesc: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    var latestSong:DiscoverModel.Song
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var notloggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
    
    var panScrollable: UIScrollView?
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(650.0) : longFormHeight
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.lblSongName.text = latestSong.title?.htmlAttributedString
        self.lblSongDuration.text = "\(latestSong.duration ?? "" )"
        self.lblSongDuration.text = latestSong.songDescription
        let url = URL.init(string:latestSong.thumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            AppInstance.instance.player = nil
            if self.notloggedInVC != nil{
                self.notloggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }else if self.loggedInVC != nil{
                self.loggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }
        }
    }
    
    init(song: DiscoverModel.Song) {
        latestSong = song
        super.init(nibName: RecentlyPlayedSongBottomSheetController.name, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func playSong(){
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        let object = self.latestSong
        
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
        
        let isOwner = object.isOwner
        let audioId = object.audioID
        let likeCount = object.countLikes?.intValue
        let favoriteCount = object.countFavorite?.intValue ?? 0
        let recentlyPlayedCount = object.countViews?.intValue ?? 0
        let sharedCount = object.countShares?.intValue ?? 0
        let commentCount = object.countComment?.intValue ?? 0
        let trackId = object.id
        let isLiked = object.isLiked
        let isFavorited = object.isFavoriated
        let likecountString = object.countLikes?.stringValue ?? ""
        let favoriteCountString = object.countFavorite?.stringValue ?? ""
        let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
        let sharedCountString = object.countShares?.stringValue ?? ""
        let commentCountString = object.countComment?.stringValue ?? ""
        let duration = object.duration ?? "0:0"
        let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
        popupContentController!.popupItem.title = object.publisher?.name ?? ""
        popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
        
        
        popupContentController!.popupItem.image = imgSong.image
        AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        
        if self.notloggedInVC != nil{
            
            self.notloggedInVC?.addToRecentlyWatched(trackId: object.id ?? 0)
            self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
               // self.popupContentController!.musicArray = self.newReleaseArray
                //self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
            })
        }else if self.loggedInVC != nil{
            self.loggedInVC?.addToRecentlyWatched(trackId: object.id ?? 0)
            self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
              //  self.popupContentController!.musicArray = self.newReleaseArray
               // self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
            })
        }
    }

    @IBAction func didTapLike(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func didTapPlayNext(_ sender: Any) {
        playSong()
    }
    @IBAction func didTapAddToQueue(_ sender: Any) {
    }
    @IBAction func didTapAddToPlayList(_ sender: Any) {
    }
    @IBAction func didTapGoToAlbum(_ sender: Any) {
    }
    @IBAction func didTapGoToArtist(_ sender: Any) {
    }
    @IBAction func didTapDetails(_ sender: Any) {
    }
    @IBAction func didTapSetAsRingtone(_ sender: Any) {
    }
    @IBAction func didTapAddToBlockList(_ sender: Any) {
    }
    @IBAction func didTapShare(_ sender: Any) {
    }
    @IBAction func didTapDeleteFromDevice(_ sender: Any) {
    }
    
}
