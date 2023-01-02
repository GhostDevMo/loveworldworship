//
//  DashboardSectionFiveTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK

class DashboardSectionFiveTableItem: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object:DiscoverModel.MostPopularWeek?
    var notLoggedobject: DiscoverModel.MostPopularWeek?
    var notloggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var popularArray = [MusicPlayerModel]()
    var isloading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(DashboardPopular_CollectionCell.nib, forCellWithReuseIdentifier: DashboardPopular_CollectionCell.identifier)
    }
    func bind(_ object:DiscoverModel.MostPopularWeek?){
        self.object = object
        self.collectionView.reloadData()
    }
    func notLoggedBind(_ object:DiscoverModel.MostPopularWeek?){
        self.notLoggedobject = object
        self.collectionView.reloadData()
    }
    
    
}
extension DashboardSectionFiveTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading == true{
            if self.loggedInVC != nil{
               return 10
                
            }else{
                return 10
                
            }
        }
        else{
        if self.loggedInVC != nil{
            return self.object?.data?.count ?? 0
            
        }else{
            return self.notLoggedobject?.data?.count ?? 0
            
        }
    }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading {
            if self.loggedInVC != nil{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardPopular_CollectionCell.identifier, for: indexPath) as? DashboardPopular_CollectionCell
                cell?.startSkelting()
                return cell!
                
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardPopular_CollectionCell.identifier, for: indexPath) as? DashboardPopular_CollectionCell
                cell?.startSkelting()
              
                return cell!
                
            }
        }
        else{
            if self.loggedInVC != nil{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardPopular_CollectionCell.identifier, for: indexPath) as? DashboardPopular_CollectionCell
                cell?.stopSkelting()
                let object = self.object?.data![indexPath.row]
                cell?.bind(object!)
                return cell!
                
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardPopular_CollectionCell.identifier, for: indexPath) as? DashboardPopular_CollectionCell
                cell?.stopSkelting()
                let object = self.notLoggedobject?.data![indexPath.row]
                cell?.notLoggedbind(object!)
                return cell!
                
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        if self.loggedInVC != nil{
            
            let object = self.object?.data![indexPath.row]
            
            self.object?.data!.forEach({ (it) in
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
                self.popularArray.append(musicObject)
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
            
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = collectionView.cellForItem(at: indexPath) as? DashboardPopular_CollectionCell
            popupContentController!.popupItem.image = cell?.thumbnailimage.image
            
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            if self.notloggedInVC != nil{
                self.notloggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.popularArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                })
            }else if self.loggedInVC != nil{
                self.loggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.popularArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                })
            }
        }else{
            
            let object = self.notLoggedobject?.data![indexPath.row]
            
            self.notLoggedobject?.data!.forEach({ (it) in
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
                self.popularArray.append(musicObject)
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
            
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = collectionView.cellForItem(at: indexPath) as? DashboardPopular_CollectionCell
            popupContentController!.popupItem.image = cell?.thumbnailimage.image
            
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            if self.notloggedInVC != nil{
                self.notloggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.popularArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                })
            }else if self.loggedInVC != nil{
                self.loggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.popularArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                })
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 230)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

