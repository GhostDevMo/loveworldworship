//
//  StationsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DeepSoundSDK
import SwiftEventBus
import EmptyDataSet_Swift
class StationsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    var stationArray = [ProfileModel.Latestsong]()
    var status:Bool? = false
    private let popupContentController = R.storyboard.player.musicPlayerVC()
      private var albumSongMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(StationTableItem.nib, forCellReuseIdentifier: StationTableItem.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
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
extension StationsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if status!{
            if stationArray.count ==  0{
                return 1
            }else{
                return stationArray.count ?? 0
                
            }
        }else{
            if stationArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.stations?.count ==  0{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.stations?.count ?? 0
                    
                }
                
            }else{
                if stationArray.count ==  0{
                    return 1
                }else{
                    return stationArray.count ?? 0
                    
                }
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if status!{
            if (stationArray.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: StationTableItem.identifier) as? StationTableItem
                cell?.selectionStyle = .none
                
                let object = self.stationArray[indexPath.row]
                cell?.bind(object)
                return cell!
            }
        }else{
            if stationArray.isEmpty{
                if (AppInstance.instance.userProfile?.data?.stations!.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: StationTableItem.identifier) as? StationTableItem
                    cell?.selectionStyle = .none
                    
                    let object = AppInstance.instance.userProfile?.data?.stations![indexPath.row]
                    cell?.bind(object!)
                    return cell!
                }
                
            }else{
                if (stationArray.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: StationTableItem.identifier) as? StationTableItem
                    cell?.selectionStyle = .none
                    
                    let object = self.stationArray[indexPath.row]
                    cell?.bind(object)
                    return cell!
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if status!{
            if stationArray.isEmpty{
                return 300.0
            }else{
                return 120.0
                
            }
        }else{
            if stationArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.stations?.count ==  0{
                    return 300.0
                }else{
                    return 120.0
                }
                
            }else{
                if stationArray.isEmpty{
                    return 300.0
                }else{
                    return 120.0
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                 AppInstance.instance.player = nil
                         AppInstance.instance.AlreadyPlayed = false
        if status!{
            let object = self.stationArray[indexPath.row]
                   self.stationArray.forEach({ (it) in
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
            let cell  = tableView.cellForRow(at: indexPath) as? StationTableItem
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
            AppInstance.instance.popupPlayPauseSong = false
            
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                   self.addToRecentlyWatched(trackId: object.id ?? 0)
                   
                   
                   tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                       
                       self.popupContentController?.musicObject = musicObject
                       self.popupContentController!.musicArray = self.albumSongMusicArray
                       self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                       
                   })
        }else{
            let object = AppInstance.instance.userProfile?.data?.stations?[indexPath.row]
            AppInstance.instance.userProfile?.data?.stations!.forEach({ (it) in
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
            let cell  = tableView.cellForRow(at: indexPath) as? StationTableItem
                       popupContentController!.popupItem.image = cell?.thumbnailImage.image
                       AppInstance.instance.popupPlayPauseSong = false
                       
                       SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
                             
                              
                              tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                  
                                  self.popupContentController?.musicObject = musicObject
                                  self.popupContentController!.musicArray = self.albumSongMusicArray
                                  self.popupContentController!.currentAudioIndex = indexPath.row
                                self.popupContentController?.setup()
                              })
        }
    }
}
extension StationsVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Station Found", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Seem little quite here", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
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
extension StationsVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("Station", comment: "Station")))
    }
}
