//
//  ActivitiesVC.swift
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
class ActivitiesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var Activities = [ProfileModel.Activity]()
    var status:Bool? = false
    private var activitesMusicArray = [MusicPlayerModel]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(Activities_TableCell.nib, forCellReuseIdentifier: Activities_TableCell.identifier)
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
extension ActivitiesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if status!{
            if Activities.isEmpty{
                return 1
            }else{
                return Activities.count ?? 0
                
            }
        }else{
            if Activities.isEmpty{
                if (AppInstance.instance.userProfile?.data?.activities?.isEmpty) ?? false{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.activities?.count ?? 0
                }
                
            }else{
                if Activities.isEmpty{
                    return 1
                }else{
                    return Activities.count ?? 0
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if status!{
            if (self.Activities.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: Activities_TableCell.identifier) as? Activities_TableCell
                cell?.selectionStyle = .none
                
                let object = self.Activities[indexPath.row]
                cell!.vc = self
                cell?.bind(object, index: indexPath.row)
                return cell!
            }
        }else{
            if self.Activities.count == 0{
                if (AppInstance.instance.userProfile?.data?.activities!.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Activities_TableCell.identifier) as? Activities_TableCell
                    cell?.selectionStyle = .none
                    
                    let object = AppInstance.instance.userProfile?.data?.activities![indexPath.row]
                    cell!.vc = self
                    cell?.bind(object!, index: indexPath.row)
                    return cell!
                }
            }else{
                if (self.Activities.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Activities_TableCell.identifier) as? Activities_TableCell
                    cell?.selectionStyle = .none
                    
                    let object = self.Activities[indexPath.row]
                    cell!.vc = self
                    cell?.bind(object, index: indexPath.row)
                    return cell!
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if status!{
            if self.Activities.count == 0{
                return 300.0
            }else{
                return 150.0
                
            }
        }else{
            if self.Activities.count == 0{
                if AppInstance.instance.userProfile?.data?.activities?.count ==  0{
                    return 300.0
                }else{
                    return 150.0
                    
                }
                
            }else{
                if Activities.count == 0{
                    return 300.0
                }else{
                    return 150.0
                    
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        if status!{
             let object = self.Activities[indexPath.row]
            self.Activities.forEach({ (it) in
                var audioString:String? = ""
                var isDemo:Bool? = false
                let name = it.userData?.name ?? ""
                let time = it.trackData?.timeFormatted ?? ""
                let title = it.trackData?.title ?? ""
                let musicType = it.trackData?.categoryName ?? ""
                let thumbnailImageString = it.trackData?.thumbnail ?? ""
                if it.trackData?.demoTrack == ""{
                    audioString = it.trackData?.audioLocation ?? ""
                    isDemo = false
                }else if it.trackData?.demoTrack != "" && it.trackData?.audioLocation != ""{
                    audioString = it.trackData?.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = it.trackData?.demoTrack ?? ""
                    isDemo = true
                }
                let isOwner = it.trackData?.isOwner ?? false
                let audioId = it.trackData?.audioID ?? ""
                let likeCount = it.trackData?.countLikes?.intValue ?? 0
                let favoriteCount = it.trackData?.countFavorite?.intValue ?? 0
                let recentlyPlayedCount = it.trackData?.countViews?.intValue ?? 0
                let sharedCount = it.trackData?.countShares?.intValue ?? 0
                let commentCount = it.trackData?.countComment.intValue ?? 0
                let trackId = it.trackData?.id ?? 0
                let isLiked = it.trackData?.isLiked ?? false
                let isFavorited = it.trackData?.isFavoriated ?? false
                
                let likecountString = it.trackData?.countLikes?.stringValue ?? ""
                let favoriteCountString = it.trackData?.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it.trackData?.countViews?.stringValue ?? ""
                let sharedCountString = it.trackData?.countShares?.stringValue ?? ""
                let commentCountString = it.trackData?.countComment.stringValue ?? ""
                
                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                self.activitesMusicArray.append(musicObject)
            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object.trackData?.title ?? ""
            let time = object.trackData?.timeFormatted ?? ""
            let title = object.trackData?.title ?? ""
            let musicType = object.trackData?.categoryName ?? ""
            let thumbnailImageString = object.trackData?.thumbnail ?? ""
            if object.trackData?.demoTrack == ""{
                audioString = object.trackData?.audioLocation ?? ""
                isDemo = false
            }else if object.trackData?.demoTrack != "" && object.trackData?.audioLocation != ""{
                audioString = object.trackData?.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = object.trackData?.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object.trackData?.isOwner ?? false
            let audioId = object.trackData?.audioID ?? ""
            let likeCount = object.trackData?.countLikes?.intValue ?? 0
            let favoriteCount = object.trackData?.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object.trackData?.countViews?.intValue ?? 0
            let sharedCount = object.trackData?.countShares?.intValue ?? 0
            let commentCount = object.trackData?.countComment.intValue ?? 0
            let trackId = object.trackData?.id ?? 0
            let isLiked = object.trackData?.isLiked ?? false
            let isFavorited = object.trackData?.isFavoriated ?? false
            
            let likecountString = object.trackData?.countLikes?.stringValue ?? ""
            let favoriteCountString = object.trackData?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object.trackData?.countViews?.stringValue ?? ""
            let sharedCountString = object.trackData?.countShares?.stringValue ?? ""
            let commentCountString = object.trackData?.countComment.stringValue ?? ""
            let duration = object.trackData?.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object.userData?.name ?? ""
            popupContentController!.popupItem.subtitle = object.trackData?.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? Activities_TableCell
                 popupContentController!.popupItem.image = cell?.thumbnailImage.image
            self.addToRecentlyWatched(trackId: object.trackData?.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.activitesMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController?.setup()
                
            })
        }else{
            let object = AppInstance.instance.userProfile?.data?.activities![indexPath.row]
            AppInstance.instance.userProfile?.data?.activities!.forEach({ (it) in
                          var audioString:String? = ""
                          var isDemo:Bool? = false
                          let name = it.userData?.name ?? ""
                          let time = it.trackData?.timeFormatted ?? ""
                          let title = it.trackData?.title ?? ""
                          let musicType = it.trackData?.categoryName ?? ""
                          let thumbnailImageString = it.trackData?.thumbnail ?? ""
                          if it.trackData?.demoTrack == ""{
                              audioString = it.trackData?.audioLocation ?? ""
                              isDemo = false
                          }else if it.trackData?.demoTrack != "" && it.trackData?.audioLocation != ""{
                              audioString = it.trackData?.audioLocation ?? ""
                              isDemo = false
                          }else{
                              audioString = it.trackData?.demoTrack ?? ""
                              isDemo = true
                          }
                          let isOwner = it.trackData?.isOwner ?? false
                          let audioId = it.trackData?.audioID ?? ""
                          let likeCount = it.trackData?.countLikes?.intValue ?? 0
                          let favoriteCount = it.trackData?.countFavorite?.intValue ?? 0
                          let recentlyPlayedCount = it.trackData?.countViews?.intValue ?? 0
                          let sharedCount = it.trackData?.countShares?.intValue ?? 0
                          let commentCount = it.trackData?.countComment.intValue ?? 0
                          let trackId = it.trackData?.id ?? 0
                          let isLiked = it.trackData?.isLiked ?? false
                          let isFavorited = it.trackData?.isFavoriated ?? false
                          
                          let likecountString = it.trackData?.countLikes?.stringValue ?? ""
                          let favoriteCountString = it.trackData?.countFavorite?.stringValue ?? ""
                          let recentlyPlayedCountString = it.trackData?.countViews?.stringValue ?? ""
                          let sharedCountString = it.trackData?.countShares?.stringValue ?? ""
                          let commentCountString = it.trackData?.countComment.stringValue ?? ""
                          
                          let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                          self.activitesMusicArray.append(musicObject)
                      })
                      var audioString:String? = ""
                      var isDemo:Bool? = false
            let name = object?.trackData?.title ?? ""
                      let time = object?.trackData?.timeFormatted ?? ""
                      let title = object?.trackData?.title ?? ""
                      let musicType = object?.trackData?.categoryName ?? ""
                      let thumbnailImageString = object?.trackData?.thumbnail ?? ""
                      if object?.trackData?.demoTrack == ""{
                          audioString = object?.trackData?.audioLocation ?? ""
                          isDemo = false
                      }else if object?.trackData?.demoTrack != "" && object?.trackData?.audioLocation != ""{
                          audioString = object?.trackData?.audioLocation ?? ""
                          isDemo = false
                      }else{
                          audioString = object?.trackData?.demoTrack ?? ""
                          isDemo = true
                      }
                      let isOwner = object?.trackData?.isOwner ?? false
                      let audioId = object?.trackData?.audioID ?? ""
                      let likeCount = object?.trackData?.countLikes?.intValue ?? 0
                      let favoriteCount = object?.trackData?.countFavorite?.intValue ?? 0
                      let recentlyPlayedCount = object?.trackData?.countViews?.intValue ?? 0
                      let sharedCount = object?.trackData?.countShares?.intValue ?? 0
                      let commentCount = object?.trackData?.countComment.intValue ?? 0
                      let trackId = object?.trackData?.id ?? 0
                      let isLiked = object?.trackData?.isLiked ?? false
                      let isFavorited = object?.trackData?.isFavoriated ?? false
                      
                      let likecountString = object?.trackData?.countLikes?.stringValue ?? ""
                      let favoriteCountString = object?.trackData?.countFavorite?.stringValue ?? ""
                      let recentlyPlayedCountString = object?.trackData?.countViews?.stringValue ?? ""
                      let sharedCountString = object?.trackData?.countShares?.stringValue ?? ""
                      let commentCountString = object?.trackData?.countComment.stringValue ?? ""
            let duration = object?.trackData?.duration ?? "0:0"
                      let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
                      
                      popupContentController!.popupItem.title = object?.userData?.name ?? ""
                      popupContentController!.popupItem.subtitle = object?.trackData?.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? Activities_TableCell
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
                      
                      AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object?.trackData?.id ?? 0)
                      tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                          
                          self.popupContentController?.musicObject = musicObject
                          self.popupContentController!.musicArray = self.activitesMusicArray
                          self.popupContentController!.currentAudioIndex = indexPath.row
                        self.popupContentController?.setup()
                          
                      })
        }
        
        
    }
}

extension ActivitiesVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Activities", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have no Activities in list", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
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

extension ActivitiesVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("Activities", comment: "Activities")))
    }
}

