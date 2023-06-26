//
//  SongVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Async
import DeepSoundSDK
import SwiftEventBus
import EmptyDataSet_Swift
import PanModal
import EzPopup
class SongVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var numberArray = [Int]()
    var songArray = [ProfileModel.Latestsong]()
    var status:Bool? = false
    private let popupContentController = R.storyboard.player.musicPlayerVC()
        private var musicPlayerArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(ProfileSongTableItem.nib, forCellReuseIdentifier:ProfileSongTableItem.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
//        if self.songArray.isEmpty{
//            for (index,value) in (AppInstance.instance.userProfile?.data?.topSongs?.enumerated())!{
//                self.numberArray.append(index)
//            }
//        }else{
//            for (index,value) in (self.songArray.enumerated()){
//                self.numberArray.append(index)
//            }
//        }
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
    
    @objc func didTapFilterData(sender:UIButton){
        let filterVC = FilterPopUPController(dele: self)
        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 350)), popupWidth: 200, popupHeight: 200)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        
    }
    @objc func didTapSongsMore(sender:UIButton){
      
            
        let object = AppInstance.instance.userProfile?.data?.topSongs?[sender.tag]
            var audioString:String? = ""
            var isDemo:Bool? = false
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
        let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false)
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
            presentPanModal(panVC)
        }
    func changeButtonImage(_ button: UIButton, play: Bool) {
        UIView.transition(with: button, duration: 0.4,
                          options: .transitionCrossDissolve, animations: {
                            button.setImage(UIImage(named: play ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
        }, completion: nil)
    }
    
    @objc func playSong(sender:UIButton){
        
        
      AppInstance.instance.player = nil
      AppInstance.instance.AlreadyPlayed = false
            
            let object = AppInstance.instance.userProfile?.data?.topSongs?[sender.tag]
            
        for i in 0...(AppInstance.instance.userProfile?.data?.topSongs?.count ?? 0) {
                
                if i == sender.tag{
                    if AppInstance.instance.player?.timeControlStatus == .playing {
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? SongsTableCells
                        changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                    }else{
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! SongsTableCells
                        changeButtonImage(cell.btnPlayPause, play: false)
                    }
                }
                else{
                    let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells
                    changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                }
            }
            AppInstance.instance.userProfile?.data?.topSongs!.forEach({ (object) in
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
                let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false)
                self.musicPlayerArray.append(musicObject)
                
            })
        var audioString:String? = ""
        var isDemo:Bool? = false
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
        let duration = object?.duration ?? "0:0"
        let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object?.id)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })
                                                   
    }
    
}

extension SongVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
}

extension SongVC: FilterTable{
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            songArray = songArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            songArray = songArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            songArray = songArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}

extension SongVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}

extension SongVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if status!{
            if songArray.isEmpty{
                return 1
            }else{
                return songArray.count ?? 0
                
            }
        }else{
            if songArray.isEmpty{
                if (AppInstance.instance.userProfile?.data?.topSongs?.isEmpty) ?? false{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.topSongs?.count ?? 0
                }
                
            }else{
                if songArray.isEmpty{
                    return 1
                }else{
                    return songArray.count ?? 0
                    
                }
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(AppInstance.instance.userProfile?.data?.topSongs?.count ?? 0) Songs"
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
            return 43
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if status!{
            if (self.songArray.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as! SongsTableCells
                cell.selectionStyle = .none
                let object = self.songArray[indexPath.row]
                cell.bindProfileSong(object, index: indexPath.row)
                cell.btnPlayPause.tag = indexPath.row
                cell.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
                cell.btnMore.tag = indexPath.row
                cell.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
                return cell
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSongTableItem.identifier) as? ProfileSongTableItem
//                cell?.selectionStyle = .none
//
//                let object = self.songArray[indexPath.row]
////                let index = self.numberArray[indexPath.row]
//                cell?.likeDelegate = self
//                cell!.songVC = self
//             //   cell?.bind(object,index:indexPath.row)
//                return cell!
            }
        }else{
            if songArray.isEmpty{
                
                if (AppInstance.instance.userProfile?.data?.topSongs!.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
                    cell?.selectionStyle = .none
                    
                    let object = (AppInstance.instance.userProfile?.data?.topSongs![indexPath.row])!
                    cell?.btnPlayPause.tag = indexPath.row
                    cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
                    cell?.btnMore.tag = indexPath.row
                    cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
                    cell?.bindLike(object, index: indexPath.row)
                    return cell!
                }
            }else{
                if (self.songArray.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSongTableItem.identifier) as? ProfileSongTableItem
                    cell?.selectionStyle = .none
                    
                    let object = self.songArray[indexPath.row]
//                    let index = self.numberArray[indexPath.row]
                    cell?.likeDelegate = self
                    cell!.songVC = self
                    //cell?.bind(object,index:indexPath.row)
                    return cell!
                }
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if status!{
            if songArray.isEmpty{
                return 300.0
            }else{
                return 120.0
                
            }
        }else{
            if songArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.topSongs?.count ==  0{
                    return 300.0
                }else{
                    return 120.0
                }
                
            }else{
                if songArray.isEmpty{
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
            let object = self.songArray[indexPath.row]
                   self.songArray.forEach({ (it) in
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
                       self.musicPlayerArray.append(musicObject)
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
            let cell  = tableView.cellForRow(at: indexPath) as? ProfileSongTableItem
                   popupContentController!.popupItem.image = cell?.thumbnailImage.image
                   self.addToRecentlyWatched(trackId: object.id ?? 0)
                   AppInstance.instance.popupPlayPauseSong = false
                   SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                   tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                       
                       self.popupContentController?.musicObject = musicObject
                       self.popupContentController!.musicArray = self.musicPlayerArray
                       self.popupContentController!.currentAudioIndex = indexPath.row
                     self.popupContentController?.setup()
                       
                   })
        }else{
            let object = AppInstance.instance.userProfile?.data?.topSongs?[indexPath.row]
            AppInstance.instance.userProfile?.data?.topSongs!.forEach({ (it) in
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
                                  self.musicPlayerArray.append(musicObject)
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
            let cell  = tableView.cellForRow(at: indexPath) as? ProfileSongTableItem
                              popupContentController!.popupItem.image = cell?.thumbnailImage.image
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                              
                              tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                  
                                  self.popupContentController?.musicObject = musicObject
                                  self.popupContentController!.musicArray = self.musicPlayerArray
                                  self.popupContentController!.currentAudioIndex = indexPath.row
                                   self.popupContentController?.setup()
                              })
        }
    }

}

extension SongVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Songs", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You don't have any Songs", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
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

extension SongVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("Songs", comment: "Songs")))
    }
}
extension SongVC:likeDislikeSongDelegate{
    
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
