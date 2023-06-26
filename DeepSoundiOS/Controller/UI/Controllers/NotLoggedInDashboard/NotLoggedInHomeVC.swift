//
//  NotLoggedInHomeVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 3/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import HMSegmentedControl
import PanModal
import EzPopup
import SwiftEventBus
import MediaPlayer
class NotLoggedInHomeVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var latestSongsArray:DiscoverModel.NewReleases?
    private var recentlyPlayedArray:DiscoverModel.RecentlyplayedUnion?
    private var mostPopularArray:DiscoverModel.PopularWeekUnion?
    private var slideShowArray:DiscoverModel.Randoms?
    private var genresArray = [GenresModel.Datum]()
    private var artistArray = [ArtistModel.Datum]()
    private var topAlbumsArray = [TrendingModel.TopAlbum]()
    private var topSongsArray = [TrendingModel.TopSong]()
    private var refreshControl = UIRefreshControl()
    private var musicPlayerArray = [MusicPlayerModel]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var type:DashboardActionType = .suggested
    
    let segmentedControls = HMSegmentedControl(sectionTitles: [
        "Suggestion",
        "Top Songs",
        "Latest Songs",
        "Recently Played",
        "Top Albums",
        "Popular",
        "Artists",
        
    ])
    
    @IBOutlet weak var segmentedControl: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = (NSLocalizedString("Discover", comment: ""))
        self.setupUI()
        self.fetchDiscover()
        self.fetchTrending()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.tableView.register(DashboardSectionOneTableItem.nib, forCellReuseIdentifier: DashboardSectionOneTableItem.identifier)
        self.tableView.register(DashboardSectionTwoTableItem.nib, forCellReuseIdentifier: DashboardSectionTwoTableItem.identifier)
        self.tableView.register(DashboardSectionThreeTableItem.nib, forCellReuseIdentifier: DashboardSectionThreeTableItem.identifier)
        self.tableView.register(DashboardSectionFourTableItem.nib, forCellReuseIdentifier: DashboardSectionFourTableItem.identifier)
        self.tableView.register(DashboardSectionFiveTableItem.nib, forCellReuseIdentifier: DashboardSectionFiveTableItem.identifier)
        self.tableView.register(DashBoardSectionSixTableItem.nib, forCellReuseIdentifier: DashBoardSectionSixTableItem.identifier)
        self.tableView.register(BrowserSectionOneTableItem.nib, forCellReuseIdentifier: BrowserSectionOneTableItem.identifier)
        
        self.tableView.register(NoLoginTableItem.nib, forCellReuseIdentifier: NoLoginTableItem.identifier)
        
        
        self.tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        self.tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        self.tableView.register(ArtistTableCell.nib, forCellReuseIdentifier: ArtistTableCell.identifier)
        self.tableView.register(ProfileAlbumsTableCell.nib, forCellReuseIdentifier: ProfileAlbumsTableCell.identifier)
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        segmentedControls.selectionStyle = HMSegmentedControlSelectionStyle.fullWidthStripe
        segmentedControls.segmentWidthStyle = .dynamic
        segmentedControls.selectionIndicatorLocation = .bottom
        segmentedControls.selectionIndicatorColor = UIColor.orange
        segmentedControls.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)]
        segmentedControls.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        segmentedControls.isUserDraggable = true
        segmentedControls.verticalDividerWidth = 1.0
        segmentedControls.selectionIndicatorHeight = 2
        segmentedControls.frame = CGRect(x: 0, y: 5, width: self.view.frame.width, height: self.segmentedControl.frame.height)
        segmentedControls.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        self.segmentedControl.addSubview(segmentedControls)
        
        
    }
    
    
    @objc func segmentedControlChangedValue(segmentedControl:HMSegmentedControl){
        self.type =  DashboardActionType(rawValue: Int(segmentedControl.selectedSegmentIndex)) ?? .suggested
        tableView.reloadData()

    }
    @objc func didTappSeeAll(_ sender:UIButton){
        self.type = DashboardActionType(rawValue: sender.tag) ?? .suggested
        segmentedControls.selectedSegmentIndex = UInt(sender.tag )
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: true)
        
    }
    @objc func didTapFollowArtist(sender:UIButton){
        if  AppInstance.instance.getUserSession(){
        }else{
            AppInstance.instance.player?.pause()
            self.loginAlert()
        }
    }
    @objc func refresh(sender:AnyObject) {
        self.latestSongsArray?.data?.removeAll()
        //        self.recentlyPlayedArray?.data?.removeAll()
        //        self.mostPopularArray?.data?.removeAll()
        self.slideShowArray?.recommended?.removeAll()
        self.artistArray.removeAll()
        self.genresArray.removeAll()
        self.tableView.reloadData()
        self.fetchDiscover()
        refreshControl.endRefreshing()
    }
    
    @objc func didTapSongsMore(sender:UIButton){
        if type == .popular{
            
            let object = mostPopularArray?.newRelease?.data?[sender.tag]
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
            let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false)
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
            presentPanModal(panVC)
        }
        else if type == .topsongs
        {
        
            let object =  topSongsArray[sender.tag]
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
        else if type == .recentlyplayed{
       
            let object =  recentlyPlayedArray?.newRelease?.data?[sender.tag]
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
            let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false)
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
            presentPanModal(panVC)
        }
      
        else if type == .latestsongs{
    
            let object =  (latestSongsArray?.data?[sender.tag])!
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
        else{
            return
        }
        
        
        
        
        
    }
    @objc func didTapFilterData(sender:UIButton){
        let filterVC = FilterPopUPController(dele: self)
        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 200)), popupWidth: 200, popupHeight: 200)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        
    }
    
    
    
    func changeButtonImage(_ button: UIButton, play: Bool) {
        UIView.transition(with: button, duration: 0.4,
                          options: .transitionCrossDissolve, animations: {
                            button.setImage(UIImage(named: play ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
        }, completion: nil)
    }
    func getViewIndexInTableView(tableView: UITableView, view: UIView) -> IndexPath? {
        let pos = view.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: pos)
    }
    
    func stopCurrentlyPlaying(indexStop:Int) {
        if  AppInstance.instance.player?.timeControlStatus == .playing {
                let cell = tableView.cellForRow(at: IndexPath(item: indexStop, section: 0)) as! SongsTableCells
                changeButtonImage(cell.btnPlayPause, play: true)
        }
    }
    
    
    @objc func playSong(sender:UIButton){
        
        
      AppInstance.instance.player = nil
      AppInstance.instance.AlreadyPlayed = false
        
        if type == .topsongs{
            
           
            
            let object = topSongsArray[sender.tag]
            
            for i in 0...topSongsArray.count{
                
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
            topSongsArray.forEach({ (object) in
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
                self.musicPlayerArray.append(musicObject)
                
            })
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
            let duration = object.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: object.publisher?.name ?? "", time: object.duration ?? "", title:  object.songArray?.sName ?? "", musicType: object.songArray?.sCategory ?? "", ThumbnailImageString:  object.songArray?.sThumbnail ?? "", likeCount:  object.countLikes?.intValue ?? 0, favoriteCount: object.countFavorite?.intValue ?? 0, recentlyPlayedCount: object.countViews?.intValue ?? 0, sharedCount: object.countShares?.intValue ?? 0, commentCount: object.countComment?.intValue ?? 0, likeCountString: object.countLikes?.stringValue ?? "", favoriteCountString: object.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object.countViews?.stringValue ?? "", sharedCountString: object.countShares?.stringValue ?? "", commentCountString: object.countComment?.stringValue ?? "", audioString: audioString, audioID: object.audioID ?? "", isLiked: object.isLiked, isFavorite: object.isFavoriated ?? false, trackId: object.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })
                                                   
    }
                                                   
        else if type == .latestsongs{
           
          
            let object = latestSongsArray?.data?[sender.tag]
            for i in 0...(latestSongsArray?.data?.count ?? 0){
                
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
            latestSongsArray?.data?.forEach({ (object) in
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
            let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })

        }
        else if type == .recentlyplayed{
           
           
            let object = recentlyPlayedArray?.newRelease?.data?[sender.tag]
            for i in 0...(recentlyPlayedArray?.newRelease?.data?.count ?? 0){
                
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
            recentlyPlayedArray?.newRelease?.data?.forEach({ (object) in
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
            let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })
        }
        else if type == .popular {
           
            
            let object = mostPopularArray?.newRelease?.data?[sender.tag]
            for i in 0...(mostPopularArray?.newRelease?.data?.count ?? 0){
                
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
            mostPopularArray?.newRelease?.data?.forEach({ (object) in
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
                let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false)
                
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
            let musicObject = MusicPlayerModel(name: object?.publisher?.name ?? "", time: object?.duration ?? "", title:  object?.songArray?.sName ?? "", musicType: object?.songArray?.sCategory ?? "", ThumbnailImageString:  object?.songArray?.sThumbnail ?? "", likeCount:  object?.countLikes?.intValue ?? 0, favoriteCount: object?.countFavorite?.intValue ?? 0, recentlyPlayedCount: object?.countViews?.intValue ?? 0, sharedCount: object?.countShares?.intValue ?? 0, commentCount: object?.countComment?.intValue ?? 0, likeCountString: object?.countLikes?.stringValue ?? "", favoriteCountString: object?.countFavorite?.stringValue ?? "", recentlyPlayedCountString: object?.countViews?.stringValue ?? "", sharedCountString: object?.countShares?.stringValue ?? "", commentCountString: object?.countComment?.stringValue ?? "", audioString: audioString, audioID: object?.audioID ?? "", isLiked: object?.isLiked, isFavorite: object?.isFavoriated ?? false, trackId: object?.id ?? 0,isDemoTrack:isDemo!,isPurchased:false,isOwner: object?.isOwner ?? false, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell  = tableView.cellForRow(at: indexPath) as? SongsTableCells
            popupContentController!.popupItem.image = cell?.imgSong.image
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: {
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.musicPlayerArray
                self.popupContentController!.currentAudioIndex = sender.tag
                self.popupContentController?.setup()
            
        })
        }

  }
    
    @IBAction func notificationPressed(_ sender: Any) {
        let vc = R.storyboard.notfication.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        let vc = R.storyboard.search.searchParentVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    private func fetchTrending() {
        if Connectivity.isConnectedToNetwork(){
            self.topSongsArray.removeAll()
            //self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                TrendingManager.instance.getTrending(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.topSongsArray = success?.topSongs ?? []
                                self.topAlbumsArray = success?.topAlbums ?? []
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
    private func fetchDiscover(){
        if Connectivity.isConnectedToNetwork(){
            self.latestSongsArray?.data?.removeAll()
            //            self.recentlyPlayedArray?.data?.removeAll()
            //            self.mostPopularArray?.data?.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,notLoggedInSuccess, sessionError, error) in
                    if success != nil{
                        
                        log.debug("userList = \(success?.status ?? 0)")
                        self.latestSongsArray = success?.newReleases ?? nil
                        self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
                        self.mostPopularArray = success?.mostPopularWeek ?? nil
                        self.slideShowArray = success?.randoms ?? nil
                        self.fetchGenres()
                        
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
    private func fetchGenres(){
        self.genresArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        self.genresArray = success?.data ?? []
                        self.fetchArtist()
                        
                        
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
    }
    private func fetchArtist(){
        self.artistArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ArtistManager.instance.getDiscover(AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.artistArray = success?.data?.data ?? []
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
    }
    func loginAlert(){
        let alert = UIAlertController(title:NSLocalizedString("Login", comment: "Login") , message:NSLocalizedString("Please login to continue", comment: "Please login to continue"), preferredStyle: .alert)
        let login = UIAlertAction(title: NSLocalizedString("Login", comment: "Login"), style: .default) { (action) in
            self.appDelegate.window?.rootViewController = R.storyboard.login.main()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(login)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
extension NotLoggedInHomeVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if type == .suggested{
            return SectionsforNotLogin.allCases.count
        }
        else{
            return 1
        }
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if type == .suggested{
        
        let section = SectionsforNotLogin(rawValue: section)!
        
        switch section {
        case .login:
            return 1
        case .genres:
            return 1
        case .latestsongs:
            return 1
        case .popular:
            return 1
        case .artist:
            return 1
        case .topSongs:
            return 1

        case .resentlyplayed:
            return 1
        }
        }
        else if type == .topsongs{
            return topSongsArray.count
        }
        else if type == .topalbums{
            return topAlbumsArray.count
        }
        else if type == .artists{
            return artistArray.count
        }
        else if type == .recentlyplayed{
            return recentlyPlayedArray?.newRelease?.count ?? 0
        }
        else if type == .popular{
            return mostPopularArray?.newRelease?.data?.count ?? 0
        }
        else if type == .latestsongs{
            return latestSongsArray?.data?.count ?? 0
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if type == .suggested{
        let section = SectionsforNotLogin(rawValue: indexPath.section )!
        
        switch section {
            
        case .login:
            let cell = tableView.dequeueReusableCell(withIdentifier: NoLoginTableItem.identifier) as? NoLoginTableItem
            cell?.selectionStyle = .none
            return cell!
        case .genres:
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionTwoTableItem.identifier) as? DashboardSectionTwoTableItem
            cell?.notLoggedInVC = self
            cell?.selectionStyle = .none
            cell?.bind(genresArray)
            return cell!
            
        case .latestsongs:
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
            
            cell?.NotLoggedbind(latestSongsArray ?? nil)
            cell?.notloggedInVC = self
            return cell!
            
        case .resentlyplayed:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFourTableItem.identifier) as? DashboardSectionFourTableItem
            cell?.selectionStyle = .none
            cell?.notloggedInVC = self
            cell?.bind(recentlyPlayedArray?.newRelease ?? nil)
            return cell!
        case .popular:
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFiveTableItem.identifier) as? DashboardSectionFiveTableItem
            cell?.notLoggedBind(mostPopularArray?.newRelease ?? nil)
            return cell!
        case .artist:
            let cell = tableView.dequeueReusableCell(withIdentifier: DashBoardSectionSixTableItem.identifier) as? DashBoardSectionSixTableItem
            cell?.notLoggedHomeVC = self
            cell?.selectionStyle = .none
            cell?.bind(artistArray)
            return cell!
        case .topSongs:
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserSectionOneTableItem.identifier) as? BrowserSectionOneTableItem
                //cell?.notloggedInVC = self
            cell?.selectionStyle = .none
            cell?.bind(topSongsArray)
            return cell!
        
        }
        }
        else if type == .topsongs{
            let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
            
            cell?.selectionStyle = .none
            cell?.bindTopSong((topSongsArray[indexPath.row]))
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            return cell!
        }
        else if type == .artists{
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTableCell.identifier) as? ArtistTableCell
            
            cell?.selectionStyle = .none
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapFollowArtist(sender:)), for: .touchUpInside)
            cell?.bind(artistArray[indexPath.row])
            return cell!
        }
        else if type == .topalbums{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
            cell.selectionStyle = .none
            let object = self.topAlbumsArray[indexPath.row]
            cell.publicAlbumBind(object)
            return cell
        }
        else if type == .popular {
            let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
            
            cell?.selectionStyle = .none
            cell?.bind((mostPopularArray?.newRelease?.data?[indexPath.row]) ?? nil)
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            return cell!
        }
        else if type == .latestsongs {
            let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
            
            cell?.selectionStyle = .none
            cell?.bind((latestSongsArray?.data?[indexPath.row]) ?? nil)
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            return cell!
        }
        else if type == .recentlyplayed{
            let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
            
            cell?.selectionStyle = .none
            cell?.bindRecentPlayedSong((recentlyPlayedArray?.newRelease?.data?[indexPath.row]))
            cell?.btnPlayPause.tag = indexPath.row
            cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
            return cell!
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: FoldersTableCell.identifier) as? FoldersTableCell
           
            return cell!
        }
        
        
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
       
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if type == .suggested{
        if section == 0{return 0}
        else {return 50}
        }
        else {return 43}
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if type == .suggested{
            let headerView = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as! SectionHeaderTableItem
            
            let type = SectionsforNotLogin(rawValue: section)!
            
            switch type {
            
            case .login:
                return nil
                
            case .genres:
                headerView.titleLabel.text = "Genres"
                
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = true
                return headerView
            case .latestsongs:
                headerView.titleLabel.text = "Latest Songs"
                headerView.btnSeeAll.tag =  2
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = false
                
                return headerView
            case .resentlyplayed:
                headerView.titleLabel.text = "Resently Played"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 3
                return headerView
            case .popular:
                headerView.titleLabel.text = "Popular"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = false
                headerView.btnSeeAll.tag = 5
                return headerView
            case .artist:
                headerView.titleLabel.text = "Artist"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = false
                headerView.btnSeeAll.tag = 6
                return headerView
            case .topSongs:
                headerView.titleLabel.text = "Top Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.isHidden = false
                headerView.btnSeeAll.tag = 1
                return headerView
            }
        }
        else if type == .topsongs {
            
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.lblTotalSongs.text = "\(topSongsArray.count) Songs"
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            return headerView
        }
        else if type == .artists {
            
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(artistArray.count ) Artists"
            return headerView
        }
        else if type == .topalbums {
            
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(topAlbumsArray.count ) Top Albums"
            return headerView
        }
        else if type == .recentlyplayed{
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(recentlyPlayedArray?.newRelease?.count ?? 0) Recently Played"
            return headerView
            
        }
        else if type == .popular{
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(mostPopularArray?.newRelease?.data?.count ?? 0) Popular"
            return headerView
         
        }
        else {
            let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
            headerView.btnArrangOrder.tag = type.rawValue
            headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
            headerView.lblTotalSongs.text = "\(latestSongsArray?.data?.count ?? 0) folders"
            return headerView
        }
           
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if type == .suggested{
        switch indexPath.section {
        case 0:
            self.loginAlert()
        case 4:
            let vc = R.storyboard.discover.latestSongsVC()
            vc!.notLoggedLatestSongsArray = self.latestSongsArray ?? nil
            self.navigationController?.pushViewController(vc!, animated: true)
        case 6:
            
            let vc = R.storyboard.discover.popularVC()
            vc!.notLoggedPopularArray = self.mostPopularArray?.newRelease ?? nil
            self.navigationController?.pushViewController(vc!, animated: true)
        case 8:
            let vc = R.storyboard.discover.artistVC()
//            vc!.artistArray = self.artistArray ?? []
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            log.verbose("Nothing to select")
        }
        }
        else if type == .artists{
            if self.artistArray[indexPath.row].artist == 0{
                let vc = R.storyboard.dashboard.showProfileVC()
                vc?.userID  = self.artistArray[indexPath.row].id ?? 0
                vc?.profileUrl = self.artistArray[indexPath.row].url ?? ""
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                let storyBoard: UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
                 let vc = storyBoard.instantiateViewController(withIdentifier: "ArtistInfoVC") as! ArtistInfoVC
                vc.artistObject = self.artistArray[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if type == .topalbums{
            let vc = R.storyboard.dashboard.showAlbumVC()
            vc?.albumObject = topAlbumsArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    
}
extension NotLoggedInHomeVC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}

extension NotLoggedInHomeVC:BottomSheetDelegate{
    func goToArtist() {
        self.type =  .artists
        segmentedControls.selectedSegmentIndex = 6
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: true)
    }
    
    func goToAlbum() {
        self.type =  .topalbums
        segmentedControls.selectedSegmentIndex = 4
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: true)
    }
    
    
}
extension NotLoggedInHomeVC: FilterTable{
    
    func filterData(order: Int) {
        
        if type == .recentlyplayed{
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
//                recentlyPlayedArray?.newRelease?.data? = recentlyPlayedArray?.newRelease?.data?.sorted(by: $0.title ?? "" > $1.title ?? "" )
//                tableView.reloadData()
                break
            case .descending:
//                recentlyPlayedArray?.newRelease?.data? = recentlyPlayedArray?.newRelease?.data?.sorted(by: $0.title ?? "" < $1.title ?? "" )
//                tableView.reloadData()
                break
            case .dateAdded:
//                recentlyPlayedArray?.newRelease?.data? = recentlyPlayedArray?.newRelease?.data?.sorted(by: $0.title ?? "" > $1.title ?? "" )
//                tableView.reloadData()
                break
            case .none:
                break
            }
        }
        else if type == .latestsongs{
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
                latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .none:
                break
            }
            
        }
        else if type == .popular{
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
//                mostPopularArray?.mostPopularWeek?.data = mostPopularArray?.mostPopularWeek?.data?.sorted(by: { $0?.title? ?? "" > $1.title ?? "" })
//                tableView.reloadData()
                break
            case .descending:
//                mostPopularArray?.mostPopularWeek?.data = mostPopularArray?.mostPopularWeek?.data?.sorted(by: { $0?.title? ?? "" < $1.title ?? "" })
//                tableView.reloadData()
                break
            case .dateAdded:
//                mostPopularArray?.mostPopularWeek?.data = mostPopularArray?.mostPopularWeek?.data?.sorted(by: { $0?.title? ?? "" > $1.title ?? "" })
//                tableView.reloadData()
                break
            case .none:
                break
            }
            
        }
        else if type == .topalbums{
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
                break
            case .descending:
                break
            case .dateAdded:
                break
            case .none:
                break
            }
            
        }
        else if type == .artists{
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
                artistArray = artistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
                tableView.reloadData()
            case .descending:
                artistArray = artistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
                tableView.reloadData()
            case .dateAdded:
                artistArray = artistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
                tableView.reloadData()
            case .none:
                break
            }
            
        }
        else if type == .topsongs{
            
            let order = FilterData(rawValue: order)
            switch order {
            case .ascending:
                topSongsArray = topSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .descending:
                topSongsArray = topSongsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
            case .dateAdded:
                topSongsArray = topSongsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
            case .none:
                break
            }
            
        }
    }
    
    
}

