//
//  StoreVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import DeepSoundSDK
import EmptyDataSet_Swift
class StoreVC: BaseVC {
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var storeArray =  [ ProfileModel.Latestsong]()
    var status:Bool? = false
    private let popupContentController = R.storyboard.player.musicPlayerVC()
       private var albumSongMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        //self.showLabel.text = (NSLocalizedString("There are no activity by this user ", comment: ""))
    }
    func setupUI(){
        if status!{
            if self.storeArray.isEmpty{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
                
            }
        }else{
            if (AppInstance.instance.userProfile?.data?.store?.count == 0){
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }
        collectionView.register(StoreCollectionItem.nib, forCellWithReuseIdentifier: StoreCollectionItem.identifier)
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
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
}
extension StoreVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if status!{
            return self.storeArray.count ?? 0
        }else{
            if storeArray.isEmpty{
                return AppInstance.instance.userProfile?.data?.store?.count ?? 0
                
            }else{
                return self.storeArray.count ?? 0
            }
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        if status!{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCollectionItem.identifier, for: indexPath) as? StoreCollectionItem
            
            let object = self.storeArray[indexPath.row]
            cell?.bind(object)
            
            return cell!
        }else{
            if storeArray.isEmpty{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCollectionItem.identifier, for: indexPath) as? StoreCollectionItem
                
                let object = AppInstance.instance.userProfile?.data?.store![indexPath.row]
                cell?.bind(object!)
                
                return cell!
                
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCollectionItem.identifier, for: indexPath) as? StoreCollectionItem
                
                let object = self.storeArray[indexPath.row]
                cell?.bind(object)
                
                return cell!
            }
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                AppInstance.instance.player = nil
                         AppInstance.instance.AlreadyPlayed = false
        if status!{
               
                        let object = self.storeArray[indexPath.row]
                        
                        self.storeArray.forEach({ (it) in
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
                            let commentCount = it.countComment.intValue ?? 0
                            let trackId = it.id ?? 0
                            let isLiked = it.isLiked ?? false
                            let isFavorited = it.isFavoriated ?? false
                            
                            let likecountString = it.countLikes?.stringValue ?? ""
                            let favoriteCountString = it.countFavorite?.stringValue ?? ""
                            let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                            let sharedCountString = it.countShares?.stringValue ?? ""
                            let commentCountString = it.countComment.stringValue ?? ""
                            
                            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                            self.albumSongMusicArray.append(musicObject)
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
            let commentCount = object.countComment.intValue ?? 0
            let trackId = object.id ?? 0
            let isLiked = object.isLiked ?? false
            let isFavorited = object.isFavoriated ?? false
                        
            let likecountString = object.countLikes?.stringValue ?? ""
            let favoriteCountString = object.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
            let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment.stringValue ?? ""
            let duration = object.duration ?? "0:0"
                        let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
                        
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
                        let cell  = collectionView.cellForItem(at: indexPath) as? StoreCollectionItem
                        popupContentController!.popupItem.image = cell?.thumnbnailImage.image
                        AppInstance.instance.popupPlayPauseSong = false
                        
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                      
            self.addToRecentlyWatched(trackId: object.id ?? 0)
                            self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                
                                self.popupContentController?.musicObject = musicObject
                                self.popupContentController!.musicArray = self.albumSongMusicArray
                                self.popupContentController!.currentAudioIndex = indexPath.row
                                   self.popupContentController?.setup()
                                
                            })
                        
        }else{
            let object = AppInstance.instance.userProfile?.data?.store?[indexPath.row]
            AppInstance.instance.userProfile?.data?.store!.forEach({ (it) in
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
                               let commentCount = it.countComment.intValue ?? 0
                                  let trackId = it.id ?? 0
                                  let isLiked = it.isLiked ?? false
                                  let isFavorited = it.isFavoriated ?? false
                                  let likecountString = it.countLikes?.stringValue ?? ""
                                  let favoriteCountString = it.countFavorite?.stringValue ?? ""
                                  let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                                  let sharedCountString = it.countShares?.stringValue ?? ""
                               let commentCountString = it.countComment.stringValue ?? ""
                                  
                                  let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                  self.albumSongMusicArray.append(musicObject)
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
            let commentCount = object!.countComment.intValue ?? 0
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
                              
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object!.countComment.stringValue ?? ""
            let duration = object?.duration ?? "0:0"
                              let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
           popupContentController!.popupItem.title = object?.publisher?.name ?? ""
              popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
              let cell  = collectionView.cellForItem(at: indexPath) as? StoreCollectionItem
              popupContentController!.popupItem.image = cell?.thumnbnailImage.image
              AppInstance.instance.popupPlayPauseSong = false
              
              SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
                  self.addToRecentlyWatched(trackId: object?.id ?? 0)
                  self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                      
                      self.popupContentController?.musicObject = musicObject
                      self.popupContentController!.musicArray = self.albumSongMusicArray
                      self.popupContentController!.currentAudioIndex = indexPath.row
                         self.popupContentController?.setup()
                      
                  })
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2 - 12
        return CGSize(width: width, height: 250)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    }
    
    
}
extension StoreVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Stores", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Seems little quite here ", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return resizeImage(image:  R.image.emptyData()!, targetSize:  CGSize(width: 200.0, height: 200.0))
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension StoreVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("Store", comment: "Store")))
    }
}
