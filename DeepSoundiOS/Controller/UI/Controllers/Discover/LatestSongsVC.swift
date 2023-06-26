//
//  LatestSongsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//


import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class LatestSongsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    
    var latestSongsArray:DiscoverModel.NewReleases?
    var notLoggedLatestSongsArray:DiscoverModel.NewReleases?
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var latestSongsMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showImage.tintColor = .mainColor
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
    
    private func setupUI(){
        self.title = NSLocalizedString("Latest Songs", comment: "Latest Songs")
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.tableView.separatorStyle = .none
        tableView.register(LatestSongs_TableCell.nib, forCellReuseIdentifier: LatestSongs_TableCell.identifier)
        if self.latestSongsArray != nil{
            if (self.latestSongsArray?.data?.isEmpty) ?? false{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }else if self.notLoggedLatestSongsArray != nil{
            if (self.notLoggedLatestSongsArray?.data?.isEmpty) ?? false{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }
        
    }
    
}
extension LatestSongsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.latestSongsArray != nil{
            return (self.latestSongsArray?.data!.count) ?? 0
        }else{
            return (self.notLoggedLatestSongsArray?.data!.count) ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.latestSongsArray != nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: LatestSongs_TableCell.identifier) as? LatestSongs_TableCell
            cell?.selectionStyle = .none
            let object = self.latestSongsArray?.data![indexPath.row]
            cell?.bind(object!, index: indexPath.row)
            cell?.likedVC = self
            cell?.likeDelegate = self
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: LatestSongs_TableCell.identifier) as? LatestSongs_TableCell
            cell?.selectionStyle = .none
            let object = self.notLoggedLatestSongsArray?.data![indexPath.row]
            cell?.bind(object!, index: indexPath.row)
            cell?.likedVC = self
            cell?.likeDelegate = self
            return cell!
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.latestSongsArray != nil{
            let object = self.latestSongsArray?.data?[indexPath.row]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
            
            self.latestSongsArray?.data!.forEach({ (it) in
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
                self.latestSongsMusicArray.append(musicObject)
            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object?.publisher?.name ?? ""
            let time = object?.timeFormatted ?? ""
            let title = object?.title ?? ""
            let musicType = object?.categoryName ?? ""
            let thumbnailImageString = object?.thumbnail ?? ""
            if object?.demoTrack == ""{
                audioString = object?.audioLocation ?? ""
                isDemo = false
            }else if object?.demoTrack != "" && object?.audioLocation != ""{
                audioString = object?.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object?.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object?.isOwner ?? false
            let audioId = object?.audioID ?? ""
            
            let likeCount = object?.countLikes?.intValue ?? 0
            let favoriteCount = object?.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object?.countViews?.intValue ?? 0
            let sharedCount = object?.countShares?.intValue ?? 0
            let commentCount = object?.countComment?.intValue ?? 0
            
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
            
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object?.countComment?.stringValue ?? ""
            let duration = object?.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? LatestSongs_TableCell
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
            
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.latestSongsMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
                
            })
        }else{
            let object = self.notLoggedLatestSongsArray?.data?[indexPath.row]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
            
            self.notLoggedLatestSongsArray?.data!.forEach({ (it) in
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
                self.latestSongsMusicArray.append(musicObject)
            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object?.publisher?.name ?? ""
            let time = object?.timeFormatted ?? ""
            let title = object?.title ?? ""
            let musicType = object?.categoryName ?? ""
            let thumbnailImageString = object?.thumbnail ?? ""
            if object?.demoTrack == ""{
                audioString = object?.audioLocation ?? ""
                isDemo = false
            }else if object?.demoTrack != "" && object?.audioLocation != ""{
                audioString = object?.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object?.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object?.isOwner ?? false
            let audioId = object?.audioID ?? ""
            
            let likeCount = object?.countLikes?.intValue ?? 0
            let favoriteCount = object?.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object?.countViews?.intValue ?? 0
            let sharedCount = object?.countShares?.intValue ?? 0
            let commentCount = object?.countComment?.intValue ?? 0
            
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
            
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object?.countComment?.stringValue ?? ""
            let duration = object?.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? LatestSongs_TableCell
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
            
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.latestSongsMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
                
            })
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
extension LatestSongsVC:likeDislikeSongDelegate{
    
    func likeDisLikeSong(status: Bool, button: UIButton,audioId:String) {
        
        if status{
            button.setImage(R.image.heart(), for: .normal)
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
                                    button.setImage(R.image.heart(), for: .normal)
                                }else{
                                    button.setImage(R.image.ic_heartRed(), for: .normal)
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
