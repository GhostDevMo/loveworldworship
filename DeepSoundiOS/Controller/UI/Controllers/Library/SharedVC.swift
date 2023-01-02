//
//  SharedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import Async
import PanModal
import EzPopup
class SharedVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
     private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var sharedSongsArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getSharedSongs()
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
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = (NSLocalizedString("Shared", comment: ""))
        self.tableView.separatorStyle = .none
        tableView.register(Shared_TableCell.nib, forCellReuseIdentifier: Shared_TableCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
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
      
            
//        let object = sharedSongsArray[sender.tag]
//            var audioString:String? = ""
//            var isDemo:Bool? = false
//            if object.demoTrack == ""{
//                audioString = object.audioLocation ?? ""
//                isDemo = false
//            }else if object.demoTrack != "" && object.audioLocation != ""{
//                audioString = object.audioLocation ?? ""
//                isDemo = false
//            }else{
//                audioString = object.demoTrack ?? ""
//                isDemo = true
//            }
//        let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment?.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment?.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false)
//            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
//            presentPanModal(panVC)
        }
    @objc func playSong(sender:UIButton){
        
        
//      AppInstance.instance.player = nil
//      AppInstance.instance.AlreadyPlayed = false
//
//            let object = sharedSongsArray[sender.tag]
//
//        for i in 0...(sharedSongsArray.count ?? 0) {
//
//                if i == sender.tag{
//                    if AppInstance.instance.player?.timeControlStatus == .playing {
//                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? SongsTableCells
////                        changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
//                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
//                    }else{
//                        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! SongsTableCells
////                        changeButtonImage(cell.btnPlayPause, play: false)
//                    }
//                }
//                else{
//                    let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? SongsTableCells
////                    changeButtonImage(cell?.btnPlayPause ?? UIButton(), play: true)
//                }
//            }
//            sharedSongsArray!.forEach({ (object) in
//                var audioString:String? = ""
//                var isDemo:Bool? = false
//                if object.demoTrack == ""{
//                    audioString = object.audioLocation ?? ""
//                    isDemo = false
//                }else if object.demoTrack != "" && object.audioLocation != ""{
//                    audioString = object.audioLocation ?? ""
//                    isDemo = false
//                }else{
//                    audioString = object.demoTrack ?? ""
//                    isDemo = true
//                }
//                let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false)
//                self.musicPlayerArray.append(musicObject)
//
//            })
//        var audioString:String? = ""
//        var isDemo:Bool? = false
//        if object?.demoTrack == ""{
//            audioString = object?.audioLocation ?? ""
//            isDemo = false
//        }else if object?.demoTrack != "" && object?.audioLocation != ""{
//            audioString = object?.audioLocation ?? ""
//            isDemo = false
//        }else{
//            audioString = object?.demoTrack ?? ""
//            isDemo = true
//        }
//        let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false)
//
//            popupContentController!.popupItem.title = object?.publisher?.name
//            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
//            let indexPath = IndexPath(row: sender.tag, section: 0)
//            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
//            popupContentController!.popupItem.image = cell?.imgSong.image
//            AppInstance.instance.popupPlayPauseSong = false
//            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
//
//            self.addToRecentlyWatched(trackId: object?.id)
//            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
//                self.popupContentController?.musicObject = musicObject
//                self.popupContentController!.musicArray = self.musicPlayerArray
//                self.popupContentController!.currentAudioIndex = sender.tag
//                self.popupContentController?.setup()
//
//        })
//
    }
    
    private func getSharedSongs(){
        var allData =  UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
                   self.tableView.isHidden = false
            log.verbose("all data = \(allData)")
            for data in allData{
                let musicObject = try? PropertyListDecoder().decode(MusicPlayerModel.self ,from: data)
                if musicObject != nil{
                    log.verbose("musicObject = \(musicObject?.trackId)")
                    self.sharedSongsArray.append(musicObject!)
                    
                }else{
                    log.verbose("Nil values cannot be append in Array!")
                } 
            }
        
    }
}
extension SharedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sharedSongsArray.count == 0{
                 return 1
             }else{
                 return self.sharedSongsArray.count
             }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.sharedSongsArray.count == 0{
                   let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                   cell?.selectionStyle = .none
                   return cell!
               }else{
                   let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
                   cell?.selectionStyle = .none
                   
                   let object = self.sharedSongsArray[indexPath.row]
                   cell?.btnPlayPause.tag = indexPath.row
                   cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
                   cell?.btnMore.tag = indexPath.row
                   cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
                   cell?.bindSharedSong(object, index: indexPath.row)
                   return cell!
               }
       
        
      
            }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        popupContentController!.popupItem.title = self.sharedSongsArray[indexPath.row].name ?? ""
        popupContentController!.popupItem.subtitle = self.sharedSongsArray[indexPath.row].title ?? ""
        let cell  = tableView.cellForRow(at: indexPath) as? Shared_TableCell
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
                  AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        
        self.addToRecentlyWatched(trackId: self.sharedSongsArray[indexPath.row].trackId ?? 0)
      
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = self.sharedSongsArray[indexPath.row]
            self.popupContentController!.musicArray = self.sharedSongsArray
            self.popupContentController!.currentAudioIndex = indexPath.row
             self.popupContentController?.setup()
            
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.sharedSongsArray.count == 0{
                   return 500.0
               }else{
                   return 120.0
               }
               
               
           }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(sharedSongsArray.count ) Songs"
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 43
        
    }
    
}
extension SharedVC:likeDislikeSongDelegate{
    
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
extension SharedVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
}
extension SharedVC: FilterTable{
    
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            sharedSongsArray = sharedSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
    }
}
extension SharedVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}
