//
//  BrowserSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK
class BrowserSectionOneTableItem: UITableViewCell {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object = [TrendingModel.TopSong]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
       private var newReleaseArray = [MusicPlayerModel]()
    var notloggedInVC:NotLoggedInBrowseVC?
      var loggedInVC:Dashboard1VC?
    var isloading = true
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setupUI(){
           self.collectionView.delegate = self
           self.collectionView.dataSource = self
        collectionView.register(Browse_CollectionCell.nib, forCellWithReuseIdentifier: Browse_CollectionCell.identifier)
       }
       func bind(_ object:[TrendingModel.TopSong]){
           self.object = object
        self.collectionView.reloadData()
       }
       
    
}
extension BrowserSectionOneTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading{
            return 10
        }
        else{
            return self.object.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Browse_CollectionCell.identifier, for: indexPath) as? Browse_CollectionCell
            cell?.startSkelting()
            return cell!
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Browse_CollectionCell.identifier, for: indexPath) as? Browse_CollectionCell
            cell?.stopSkelting()
            let object = self.object[indexPath.row]
            cell?.bind(object)
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         AppInstance.instance.player = nil
                AppInstance.instance.AlreadyPlayed = false
         let object = self.object[indexPath.row]
         
         self.object.forEach({ (it) in
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
             self.newReleaseArray.append(musicObject)
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
         let cell  = collectionView.cellForItem(at: indexPath) as? Browse_CollectionCell
               popupContentController!.popupItem.image = cell?.thumbnailimage.image
         AppInstance.instance.popupPlayPauseSong = false
         SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
         
         if self.notloggedInVC != nil{
            self.notloggedInVC?.addToRecentlyWatched(trackId: object.id ?? 0)
             self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                 self.popupContentController?.musicObject = musicObject
                 self.popupContentController!.musicArray = self.newReleaseArray
                 self.popupContentController!.currentAudioIndex = indexPath.row
                 self.popupContentController?.setup()
             })
         }else if self.loggedInVC != nil{
            self.loggedInVC?.addToRecentlyWatched(trackId: object.id ?? 0)
             self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                 self.popupContentController?.musicObject = musicObject
                 self.popupContentController!.musicArray = self.newReleaseArray
                 self.popupContentController!.currentAudioIndex = indexPath.row
                 self.popupContentController?.setup()
             })
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

