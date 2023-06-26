//
//  PurchasesVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class PurchasesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var purchasesArray = [GetPurchaseModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var likeMusicArray = [MusicPlayerModel]()
    
    
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
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = (NSLocalizedString("Purchases", comment: ""))
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register(PurchaseTableItem.nib, forCellReuseIdentifier: PurchaseTableItem.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        self.purchasesArray.removeAll()
        self.tableView.reloadData()
        self.fetchLiked()
        refreshControl.endRefreshing()
    }
    
    private func fetchLiked(){
        if Connectivity.isConnectedToNetwork(){
            self.purchasesArray.removeAll()
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PurchaseManager.instance.getPurchases(AccessToken: accessToken, userId: userId, limit: 10, offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
//                                log.debug("userList = \(success?.data[0].data ?? [])")
//                                self.purchasesArray = success?.data[0].data ?? []
                                
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
                }
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension PurchasesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.purchasesArray.count == 0{
            return 1
        }else{
            return self.purchasesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.purchasesArray.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
            cell?.selectionStyle = .none
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseTableItem.identifier) as? PurchaseTableItem
            cell?.selectionStyle = .none
            
            cell?.vc = self
            cell?.likeDelegate = self
            let object = self.purchasesArray[indexPath.row]
            cell?.bind(object, index: indexPath.row)
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.purchasesArray.count == 0{
        let object = self.purchasesArray[indexPath.row]
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        self.purchasesArray.forEach({ (it) in
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
        let cell  = tableView.cellForRow(at: indexPath) as? PurchaseTableItem
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
                  AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        self.addToRecentlyWatched(trackId: object.id ?? 0)
        
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = musicObject
            self.popupContentController!.musicArray = self.likeMusicArray
            self.popupContentController!.currentAudioIndex = indexPath.row
            self.popupContentController!.songCodeStatus = 1
            self.popupContentController?.setup()
        })
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.purchasesArray.count == 0{
            return 500.0
        }else{
            return 120.0
        }
        
        
    }
    
}

extension PurchasesVC:likeDislikeSongDelegate{
    
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
