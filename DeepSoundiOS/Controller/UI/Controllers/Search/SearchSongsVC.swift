//
//  SearchSongsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Async
import SwiftEventBus
import DeepSoundSDK
import PanModal
import EzPopup
class SearchSongsVC: BaseVC {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
   
    private let randomString:String? = "a"
    private var songArray = [SearchModel.Song]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var searchMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH) { result in
            self.dismissProgressDialog {
                self.songArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let songResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.songArray = songResult?.songs ?? []
                log.verbose("SongsCount = \(songResult?.songs?.count)")
                self.tableView.reloadData()
            }
            
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                self.songArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let songResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.songArray = songResult?.songs ?? []
                log.verbose("SongsCount = \(songResult?.songs?.count)")
                self.tableView.reloadData()
            }
            
        }
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
    @IBAction func searchPressed(_ sender: Any) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["keyword":randomString])
    }
    private func setupUI(){
//        self.tableView.isHidden = true
        self.tableView.separatorStyle = .none
        tableView.register(SearchSong_TableCell.nib, forCellReuseIdentifier: SearchSong_TableCell.identifier)
        tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
    }
    @objc func didTapSongsMore(sender:UIButton){
      
            
        let object = songArray[sender.tag]
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
    
}
extension SearchSongsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
        cell?.selectionStyle = .none
        
        let object = self.songArray[indexPath.row]
        cell?.btnPlayPause.tag = indexPath.row
       // cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
        cell?.btnMore.tag = indexPath.row
        cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
        cell?.bindSearchSong(object, index: indexPath.row)
        return cell!
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object = self.songArray[indexPath.row]
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
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
            self.searchMusicArray.append(musicObject)
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
        let cell  = tableView.cellForRow(at: indexPath) as? SearchSong_TableCell
                  popupContentController!.popupItem.image = cell?.thumbnailImage.image
                            
                            AppInstance.instance.popupPlayPauseSong = false
                  SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        self.addToRecentlyWatched(trackId: object.id ?? 0)
    
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = musicObject
            self.popupContentController!.musicArray = self.searchMusicArray
            self.popupContentController!.currentAudioIndex = indexPath.row
            self.popupContentController?.setup()

        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

extension SearchSongsVC:likeDislikeSongDelegate{
    
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
extension SearchSongsVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
    
}
extension SearchSongsVC: FilterTable{
    
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
extension SearchSongsVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}
extension SearchSongsVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("SONGS", comment: "SONGS"))
    }
}
