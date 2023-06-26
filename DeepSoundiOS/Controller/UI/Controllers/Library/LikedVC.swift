//
//  LikedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import PanModal
import EzPopup
class LikedVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var LikedArray = [LikedModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var likeMusicArray = [MusicPlayerModel]()
    private var musicPlayerArray = [MusicPlayerModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchLiked()
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
        
        self.title = "Liked"
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register(Liked_TableCell.nib, forCellReuseIdentifier: Liked_TableCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @objc func refresh(sender:AnyObject) {
        self.LikedArray.removeAll()
        self.tableView.reloadData()
        self.fetchLiked()
        refreshControl.endRefreshing()
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
      
            
        let object = LikedArray[sender.tag]
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
    @objc func playSong(sender:UIButton){
        
        
      AppInstance.instance.player = nil
      AppInstance.instance.AlreadyPlayed = false
            
            let object = AppInstance.instance.userProfile?.data?.liked?[sender.tag]
            
        for i in 0...(AppInstance.instance.userProfile?.data?.liked?.count ?? 0) {
                
                if i == sender.tag{
                    if AppInstance.instance.player?.timeControlStatus == .playing {
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? SongsTableCells
//                        changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                    }else{
                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! SongsTableCells
//                        changeButtonImage(cell.btnPlayPause, play: false)
                    }
                }
                else{
                    let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells
//                    changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
                }
            }
            AppInstance.instance.userProfile?.data?.liked!.forEach({ (object) in
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
    
    private func fetchLiked(){
        if Connectivity.isConnectedToNetwork(){
            self.LikedArray.removeAll()
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                
                LikedManager.instance.getLiked(UserId: userId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.LikedArray = success?.data?.data ?? []
                                
                                self.tableView.reloadData()
                                
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
}
extension LikedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.LikedArray.count == 0{
            return 1
        }else{
            return self.LikedArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.LikedArray.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
            cell?.selectionStyle = .none
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
            cell?.selectionStyle = .none
            
            let object = self.LikedArray[indexPath.row]
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            cell?.bindLikeSong(object, index: indexPath.row)
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object = self.LikedArray[indexPath.row]
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        self.LikedArray.forEach({ (it) in
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
            self.likeMusicArray.append(musicObject)
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
        let url = URL.init(string:object.thumbnail ?? "")
        
        
        popupContentController!.popupItem.title = object.publisher?.name ?? ""
        popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
        let cell  = tableView.cellForRow(at: indexPath) as? Liked_TableCell
                  popupContentController!.popupItem.image = cell?.thumbnailImage.image
        self.addToRecentlyWatched(trackId: object.id ?? 0)
        AppInstance.instance.popupPlayPauseSong = false
        
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = musicObject
            self.popupContentController!.musicArray = self.likeMusicArray
            self.popupContentController!.currentAudioIndex = indexPath.row
            self.popupContentController!.songCodeStatus = 1
             self.popupContentController?.setup()
            
            
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.LikedArray.count == 0{
            return 500.0
        }else{
            return 120.0
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(LikedArray.count ) Songs"
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 43
        
    }
    
}

extension LikedVC:likeDislikeSongDelegate{
    
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
extension LikedVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
}
extension LikedVC: FilterTable{
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            LikedArray = LikedArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            LikedArray = LikedArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            LikedArray = LikedArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}
extension LikedVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}
