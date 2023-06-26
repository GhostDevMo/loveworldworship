//
//  Dashboard1VC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import MediaPlayer
import HMSegmentedControl
import PanModal
import EzPopup
import EmptyDataSet_Swift

class Dashboard1VC: BaseVC {
    
    
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var latestSongsArray:DiscoverModel.NewReleases?
    private var recentlyPlayedArray:DiscoverModel.RecentlyplayedUnion?
    private var mostPopularArray:DiscoverModel.PopularWeekUnion?
    private var slideShowArray:DiscoverModel.Randoms?
    private var genresArray = [GenresModel.Datum]()
    private var artistArray = [ArtistModel.Datum]()
    private var topSongsArray = [TrendingModel.TopSong]()
    private var topAlbumsArray = [TrendingModel.TopAlbum]()
    private var musicPlayerArray = [MusicPlayerModel]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var object: DiscoverModel.NewReleases?
    
    private var refreshControl = UIRefreshControl()
    var type:DashboardActionType = .suggested
    
    var typeFromLibrary:DashboardActionType? {
        didSet {
            self.type = typeFromLibrary ?? .suggested
        }
    }
    var fromLibraryVC = false
    @IBOutlet weak var heightSegmentsss: NSLayoutConstraint!
    
    var isloading = true
    
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
        self.setupUI()
        
        self.fetchDiscover()
        self.fetchTrending()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
       // self.tabBarController?.selectedIndex = 0
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
        
        self.tableView.register(FoldersTableCell.nib, forCellReuseIdentifier: FoldersTableCell.identifier)
        self.tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        self.tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        self.tableView.register(ArtistTableCell.nib, forCellReuseIdentifier: ArtistTableCell.identifier)
        self.tableView.register(ProfileAlbumsTableCell.nib, forCellReuseIdentifier: ProfileAlbumsTableCell.identifier)
       
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
             refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
         refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
       
        navigationController?.setNavigationBarHidden(true, animated: false)
        heightSegmentsss.constant = fromLibraryVC ? 1 : 42
        if !fromLibraryVC {
            segmentedControls.selectionStyle = HMSegmentedControlSelectionStyle.fullWidthStripe
            segmentedControls.segmentWidthStyle = .dynamic
            segmentedControls.selectionIndicatorLocation = .bottom
            segmentedControls.selectionIndicatorColor = UIColor.ButtonColor
            segmentedControls.titleTextAttributes = [NSAttributedString.Key.font:R.font.urbanistMedium(size: 14)]
            segmentedControls.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ButtonColor]
            segmentedControls.isUserDraggable = true
            segmentedControls.verticalDividerWidth = 1.0
            segmentedControls.selectionIndicatorHeight = 2
            segmentedControls.frame = CGRect(x: 0, y: 5, width: self.view.frame.width, height: self.segmentedControl.frame.height)
            segmentedControls.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
            self.segmentedControl.addSubview(segmentedControls)
        }
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
    @objc func refresh(sender:AnyObject) {
           self.latestSongsArray?.data?.removeAll()

           self.slideShowArray?.recommended?.removeAll()
           self.artistArray.removeAll()
           self.genresArray.removeAll()
           self.tableView.reloadData()
           self.fetchDiscover()
           refreshControl.endRefreshing()
       }
    @objc func didTapFilterData(sender:UIButton){
        let filterVC = FilterPopUPController(dele: self)
        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 170)), popupWidth: 190, popupHeight: 150)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        
    }
    @IBAction func notificationPressed(_ sender: UIButton) {
        let vc = R.storyboard.notfication.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        let vc = R.storyboard.search.searchParentVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let panVC: PanModalPresentable.LayoutType = AddMenuBottomSheetController(song: "")
        presentPanModal(panVC)
        
    }

    private func fetchDiscover(){
        if Connectivity.isConnectedToNetwork(){
            self.latestSongsArray?.data?.removeAll()
//            self.recentlyPlayedArray?.newRelease?.data?.removeAll()
//            self.mostPopularArray?. ?.removeAll()
            
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,NotDiscovered, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? 0)")
                            self.latestSongsArray = success?.newReleases ?? nil
                            AppInstance.instance.latestSong = success?.newReleases?.data ?? []
                            if ((success?.recentlyPlayed?.emptyArray?.isEmpty) == true){
                            }else{
                                self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
                            }
                           
                            self.mostPopularArray = success?.mostPopularWeek ?? nil
                            self.slideShowArray = success?.randoms ?? nil
                           // self.isloading = false
                            self.tableView.reloadData()
                            self.fetchGenres()
                            
                            
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
        }
        
    }
    
    private func fetchGenres(){
        self.genresArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                        self.genresArray = success?.data ?? []
                        
                        self.tableView.reloadData()
                        self.fetchArtist()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
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
                            self.isloading = false
                            self.tableView.reloadData()
                          
                          
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
        })
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
    @objc func didTapFollowArtist(sender:UIButton){
        
        let userId = self.artistArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        if artistArray[sender.tag].lastFollowID == 0{
            
            sender.backgroundColor = UIColor.white
            sender.setTitle((NSLocalizedString(("Following"), comment: "")), for: .normal)
            sender.setTitleColor((UIColor.hexStringToUIColor(hex:  "FFA143")), for: .normal)
            sender.borderColorV = UIColor.ButtonColor
            sender.borderWidthV = 0.5
            self.followUser(index: sender.tag)
            
        }else{
            sender.backgroundColor = .ButtonColor
            sender.setTitle((NSLocalizedString(("Follow"), comment: "")), for: .normal)
            sender.setTitleColor(UIColor.white, for: .normal)
            self.unFollowUser(index: sender.tag)
        }
    }
    func followUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.artistArray[index].id ?? 0
            if userId == AppInstance.instance.userId {
                self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
                return
            }
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
            Async.background({
                
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString(("User has been Followed"), comment: ""))
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
    func unFollowUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.artistArray[index].id ?? 0
           
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast((NSLocalizedString(("User has been unfollowed"), comment: "")))
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
extension Dashboard1VC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if type == .suggested{
            return SuggestedSections.allCases.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isloading{
            if type == .suggested{
            
                let section = SuggestedSections(rawValue: section)!
                
                switch section {
                case .genres:
                    return 1
                case .latestsongs:
                    return 1
                case .resentlyplayed:
                    return 1
                case .popular:
                    return 1
                case .artist:
                    return 1
                case .topSongs:
                    return 1

                }

            }
        }
        else{
            if type == .suggested{
                
                let section = SuggestedSections(rawValue: section)!
                
                switch section {
                case .genres:
                    return 1
                case .latestsongs:
                    return 1
                case .resentlyplayed:
                    return 1
                case .popular:
                    return 1
                case .artist:
                    return 1
                case .topSongs:
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
                return recentlyPlayedArray?.newRelease?.data?.count ?? 0
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if type == .suggested{
            
            let headerView = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as! SectionHeaderTableItem
            
            let type = SuggestedSections(rawValue: section)!
            
            switch type {
            
            case .genres:
                headerView.titleLabel.text = "Categories"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                
                headerView.btnSeeAll.isHidden = true
                return headerView
            case .latestsongs:
                headerView.titleLabel.text = "New Releases"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag =  2
                return headerView
            case .resentlyplayed:
                headerView.titleLabel.text = "Recently Played"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 3
                return headerView
            case .popular:
                headerView.titleLabel.text = "Popular"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 5
                return headerView
            case .artist:
                headerView.titleLabel.text = "Artist"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 6
                return headerView
            case .topSongs:
                headerView.titleLabel.text = "Top Songs"
                headerView.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                headerView.btnSeeAll.tag = 1
                headerView.btnSeeAll.isHidden = false
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
            headerView.lblTotalSongs.text = "\(recentlyPlayedArray?.newRelease?.data?.count ?? 0) Recently Played"
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if type == .suggested{
            return 50
        }
        else {
            return 43
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isloading ==  true{
            if type == .suggested{
                let section = SuggestedSections(rawValue: indexPath.section)!
                
                switch section {
                case .topSongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
                   // cell?.startSkelting()
                    return cell!
                case .genres:
                    let cell = tableView.dequeueReusableCell(withIdentifier:DashboardSectionTwoTableItem.identifier) as? DashboardSectionTwoTableItem
                  //  cell?.startSkelting()
                    return cell!
                    
                case .latestsongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
                   // cell?.startSkelting()
                    return cell!
                case .resentlyplayed:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFourTableItem.identifier) as? DashboardSectionFourTableItem
                    //cell?.startSkelting()
                    return cell!
                case .popular:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFiveTableItem.identifier) as? DashboardSectionFiveTableItem
                   // cell?.startSkelting()
                    return cell!
                case .artist:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashBoardSectionSixTableItem.identifier) as? DashBoardSectionSixTableItem
                   // cell?.startSkelting()
                    return cell!
               
                }

            }
        }
        else{
            if type == .suggested{
                let section = SuggestedSections(rawValue: indexPath.section)!
                
                switch section {
                case .topSongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: BrowserSectionOneTableItem.identifier) as? BrowserSectionOneTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(topSongsArray)
                    
                    return cell!
                case .genres:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionTwoTableItem.identifier) as? DashboardSectionTwoTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(genresArray)
                    return cell!
                    
                case .latestsongs:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(latestSongsArray ?? nil)
                    return cell!
                case .resentlyplayed:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFourTableItem.identifier) as? DashboardSectionFourTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.selectionStyle = .none
                    cell?.loggedInVC = self
                    cell?.bind(recentlyPlayedArray?.newRelease ?? nil)
                    return cell!
                case .popular:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSectionFiveTableItem.identifier) as? DashboardSectionFiveTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.loggedInVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(mostPopularArray?.newRelease ?? nil)
                    return cell!
                case .artist:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashBoardSectionSixTableItem.identifier) as? DashBoardSectionSixTableItem
                    cell?.isloading = false
                    cell?.stopSkelting()
                    cell?.loggedHomeVC = self
                    cell?.selectionStyle = .none
                    cell?.bind(artistArray)
                    return cell!
                    
                }
                
            }
            
            else if type == .topsongs{
                let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
                cell?.loggedInVC = self
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
                cell?.loggedHomeVC = self
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
                cell?.loggedInVC = self
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
                cell?.loggedInVC = self
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
                cell?.loggedInVC = self
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
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if type == .artists{
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
       
    }
    
    
}

extension Dashboard1VC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black

        let message = "Seems a little quite over here"
        
        return message.stringToAttributed
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return resizeImage(image: UIImage(named: "EmptyData")!, targetSize:  CGSize(width: 200.0, height: 200.0)) 
    }
}
extension Dashboard1VC:MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do
        {
            try FileManager.default.removeItem(at: outputURL)
        }
        catch let error as NSError
        {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background({
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                
                if exportSession!.status == AVAssetExportSession.Status.completed
                {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                  Async.main({
                    self.uploadTrack(TrackData: data)
                  })
                }
            })
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    private func uploadTrack(TrackData:Data){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.filePath ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
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
extension Dashboard1VC: PopupViewControllerDelegate{
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        print("log - popupViewControllerDidDismissByTapGesture")
    }
    
}

extension Dashboard1VC:BottomSheetDelegate{
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
extension Dashboard1VC: FilterTable{
    
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
//            switch order {
//            case .ascending:
//                DispatchQueue.main.async { [self] in
//                    latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
//                    tableView.reloadData()
//                }
//
//            case .descending:
//                DispatchQueue.main.async { [self] in
//                    latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
//                    tableView.reloadData()
//                }
//            case .dateAdded:
//                DispatchQueue.main.async { [self] in
//                    latestSongsArray?.data =  latestSongsArray?.data?.sorted(by: { $0.title ?? "" > $1.title ?? "" })
//                    tableView.reloadData()
//                }
//            case .none:
//                break
//            }
//
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
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
                break
            case .descending:
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                tableView.reloadData()
                break
            case .dateAdded:
                topAlbumsArray = topAlbumsArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
                tableView.reloadData()
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
                artistArray = artistArray.sorted(by: { $0.name ?? "" < $1.name ?? "" })
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

