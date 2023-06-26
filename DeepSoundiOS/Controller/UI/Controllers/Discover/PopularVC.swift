//
//  PopularVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//


import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class PopularVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    var popularArray:DiscoverModel.MostPopularWeek?
    var notLoggedPopularArray:DiscoverModel.MostPopularWeek?
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var popularMusicArray = [MusicPlayerModel]()
    
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
        self.title =  NSLocalizedString("Popular", comment: "Popular")
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.tableView.separatorStyle = .none
        tableView.register(Popular_TableCell.nib, forCellReuseIdentifier: Popular_TableCell.identifier)
        if self.popularArray != nil{
            if (self.popularArray?.data!.isEmpty)!{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }else if self.notLoggedPopularArray  != nil{
            if (self.notLoggedPopularArray?.data!.isEmpty)!{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }
        
    }
    
}
extension PopularVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.popularArray != nil{
                   return (self.popularArray?.data!.count) ?? 0
               }else {
                   return (self.notLoggedPopularArray?.data!.count) ?? 0
               }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.popularArray != nil{
                       let cell = tableView.dequeueReusableCell(withIdentifier: Popular_TableCell.identifier) as? Popular_TableCell
                              cell?.likeDelegate = self
                              cell?.selectionStyle = .none
                              cell?.likedVC = self
                              let object = self.popularArray?.data![indexPath.row]
                              cell?.bind(object!, index: indexPath.row)
                              
                              return cell!
                      }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Popular_TableCell.identifier) as? Popular_TableCell
                               cell?.likeDelegate = self
                               cell?.selectionStyle = .none
                               cell?.likedVC = self
                               let object = self.notLoggedPopularArray?.data![indexPath.row]
                               cell?.bind(object!, index: indexPath.row)
                               
                               return cell!
                      }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.popularArray != nil{
                            let object = self.popularArray?.data![indexPath.row]
                                   AppInstance.instance.player = nil
                                   AppInstance.instance.AlreadyPlayed = false
                                   
                                   self.popularArray?.data!.forEach({ (it) in
                                       var audioString:String? = ""
                                       var isDemo:Bool? = false
                                       let name = it?.publisher?.name ?? ""
                                       let time = it?.timeFormatted ?? ""
                                       let title = it?.title ?? ""
                                       let musicType = it?.categoryName ?? ""
                                       let thumbnailImageString = it?.thumbnail ?? ""
                                       if it?.demoTrack == ""{
                                           audioString = it?.audioLocation ?? ""
                                           isDemo = false
                                       }else if it?.demoTrack != "" && it?.audioLocation != ""{
                                           audioString = it?.audioLocation ?? ""
                                           isDemo = false
                                       }else{
                                           audioString = it?.demoTrack ?? ""
                                           isDemo = true
                                       }
                                       let isOwner = it?.isOwner ?? false
                                       let audioId = it?.audioID ?? ""
                                       let likeCount = it?.countLikes?.intValue ?? 0
                                       let favoriteCount = it?.countFavorite?.intValue ?? 0
                                       let recentlyPlayedCount = it?.countViews?.intValue ?? 0
                                       let sharedCount = it?.countShares?.intValue ?? 0
                                       let commentCount = it?.countComment?.intValue ?? 0
                                       let trackId = it?.id ?? 0
                                       let isLiked = it?.isLiked ?? false
                                       let isFavorited = it?.isFavoriated ?? false
                                       
                                       let likecountString = it?.countLikes?.stringValue ?? ""
                                       let favoriteCountString = it?.countFavorite?.stringValue ?? ""
                                       let recentlyPlayedCountString = it?.countViews?.stringValue ?? ""
                                       let sharedCountString = it?.countShares?.stringValue ?? ""
                                       let commentCountString = it?.countComment?.stringValue ?? ""
                                       
                                       let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                       self.popularMusicArray.append(musicObject)
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
                                   let cell  = tableView.cellForRow(at: indexPath) as? Popular_TableCell
                                   popupContentController!.popupItem.image = cell?.thumbnailImage.image
                                   
                                   AppInstance.instance.popupPlayPauseSong = false
                                   SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                                   self.addToRecentlyWatched(trackId: object?.id ?? 0)
                                   
                                   tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                       
                                       self.popupContentController?.musicObject = musicObject
                                       self.popupContentController!.musicArray = self.popularMusicArray
                                       self.popupContentController!.currentAudioIndex = indexPath.row
                                       self.popupContentController?.setup()
                                   })
                             }else {
                              let object = self.notLoggedPopularArray?.data![indexPath.row]
                                     AppInstance.instance.player = nil
                                     AppInstance.instance.AlreadyPlayed = false
                                     
                                     self.notLoggedPopularArray?.data!.forEach({ (it) in
                                         var audioString:String? = ""
                                         var isDemo:Bool? = false
                                         let name = it?.publisher?.name ?? ""
                                         let time = it?.timeFormatted ?? ""
                                         let title = it?.title ?? ""
                                         let musicType = it?.categoryName ?? ""
                                         let thumbnailImageString = it?.thumbnail ?? ""
                                         if it?.demoTrack == ""{
                                             audioString = it?.audioLocation ?? ""
                                             isDemo = false
                                         }else if it?.demoTrack != "" && it?.audioLocation != ""{
                                             audioString = it?.audioLocation ?? ""
                                             isDemo = false
                                         }else{
                                             audioString = it?.demoTrack ?? ""
                                             isDemo = true
                                         }
                                         let isOwner = it?.isOwner ?? false
                                         let audioId = it?.audioID ?? ""
                                         let likeCount = it?.countLikes?.intValue ?? 0
                                         let favoriteCount = it?.countFavorite?.intValue ?? 0
                                         let recentlyPlayedCount = it?.countViews?.intValue ?? 0
                                         let sharedCount = it?.countShares?.intValue ?? 0
                                         let commentCount = it?.countComment?.intValue ?? 0
                                         let trackId = it?.id ?? 0
                                         let isLiked = it?.isLiked ?? false
                                         let isFavorited = it?.isFavoriated ?? false
                                         
                                         let likecountString = it?.countLikes?.stringValue ?? ""
                                         let favoriteCountString = it?.countFavorite?.stringValue ?? ""
                                         let recentlyPlayedCountString = it?.countViews?.stringValue ?? ""
                                         let sharedCountString = it?.countShares?.stringValue ?? ""
                                         let commentCountString = it?.countComment?.stringValue ?? ""
                                         
                                         let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                         self.popularMusicArray.append(musicObject)
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
                                     let cell  = tableView.cellForRow(at: indexPath) as? Popular_TableCell
                                     popupContentController!.popupItem.image = cell?.thumbnailImage.image
                                     
                                     AppInstance.instance.popupPlayPauseSong = false
                                     SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                                     self.addToRecentlyWatched(trackId: object?.id ?? 0)
                                     
                                     tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                         
                                         self.popupContentController?.musicObject = musicObject
                                         self.popupContentController!.musicArray = self.popularMusicArray
                                         self.popupContentController!.currentAudioIndex = indexPath.row
                                         self.popupContentController?.setup()
                                     })
                             }
        
       
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
extension PopularVC:likeDislikeSongDelegate{
    
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
