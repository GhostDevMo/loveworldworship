//
//  FavouriteVC.swift
//  DeepSoundiOS
//
//  Created by Moghees on 15/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds
import PanModal
import EzPopup

class FavouriteTBVC: BaseVC{

    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var shuffle: UIButton!
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    private lazy var searchBar = UISearchBar(frame: .zero)
    private var refreshControl = UIRefreshControl()
    private var favoriteArray = [FavoriteModel.Datum]()
    private var musicPlayerArray = [MusicPlayerModel]()
    var shuffled:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

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
                if ControlSettings.shouldShowAddMobBanner{
        
                   // bannerView = GADBannerView(adSize: GADAdSize())
//                    addBannerViewToView(bannerView)
//                    bannerView.adUnitID = ControlSettings.addUnitId
//                    bannerView.rootViewController = self
//                    bannerView.load(GADRequest())
                 
                    let request = GADRequest()
                    GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                                           request: request,
                                           completionHandler: { (ad, error) in
                                            if let error = error {
                                                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                                return
                                            }
                                            self.interstitial = ad
                                           }
                    )
        
                }
        setupUI()
        fetchfavorite()
    }
    
    
    private func setupUI(){
        playBtn.backgroundColor = .lightButtonColor
        shuffle.backgroundColor = .ButtonColor
        playBtn.setTitleColor(.ButtonColor, for: .normal)
        searchBar.placeholder = (NSLocalizedString("Search...", comment: ""))
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        self.tableView.separatorStyle = .none
        self.tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        self.tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        
    }
    func changeButtonImage(_ button: UIButton, play: Bool) {
        UIView.transition(with: button, duration: 0.4,
                          options: .transitionCrossDissolve, animations: {
                            button.setImage(UIImage(named: play ? "ic-play-btn" : "ic-pause-btn"), for: .normal)
        }, completion: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        
        self.tableView.reloadData()
        
        refreshControl.endRefreshing()
    }
    @objc func playSong(sender:UIButton){
        
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
       
        
        favoriteArray.forEach({ (object) in
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
        
        let object = favoriteArray[sender.tag]
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        for i in 0...favoriteArray.count{
            
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
    
    @objc func playSong(sender:UIButton, shuffled:Bool){
        
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
       
        
        favoriteArray.forEach({ (object) in
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
        
        var object = favoriteArray[sender.tag]
        var randomInt = 0
        var indexPath = IndexPath(row: sender.tag, section: 0)
        
        if shuffled{
            musicPlayerArray.shuffle()
            randomInt = Int.random(in: 0..<favoriteArray.count)
            object = favoriteArray[randomInt]
            indexPath = IndexPath(row: randomInt, section: 0)
        }
        else{
            object = favoriteArray[sender.tag]
            indexPath = IndexPath(row: sender.tag, section: 0)
            for i in 0...favoriteArray.count{
                
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
        }
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
    func CreateAd() -> GADInterstitialAd {
        
        GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                               request: GADRequest(),
                               completionHandler: { (ad, error) in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               }
        )
        return  self.interstitial
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    
    private func fetchfavorite(){
        if Connectivity.isConnectedToNetwork(){
            self.favoriteArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                FavoriteManager.instance.getFavorite(UserId: userId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.favoriteArray = success?.data?.data ?? []
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
      
        
        let object =  favoriteArray[sender.tag]
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
    @objc func didTapFilterData(sender:UIButton){
        let filterVC = FilterPopUPController(dele: self)
        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 200)), popupWidth: 200, popupHeight: 200)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        
        present(popupVC, animated: true, completion: nil)
        
    }
    
    @IBAction func playSongList(_ sender: UIButton) {
        sender.tag = 0
        shuffled = false
        playSong(sender: sender,shuffled: false)
        
        
    }
    @IBAction func shuffleSongList(_ sender: UIButton) {
        
        playSong(sender: sender,shuffled:true)
        
    }

}
extension FavouriteTBVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return self.favoriteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier:SongsTableCells.identifier) as? SongsTableCells
        //cell?.loggedInVC = self
        cell?.selectionStyle = .none
        let object = self.favoriteArray[indexPath.row]
        cell?.bindFavourite(object, index: indexPath.row)
        cell?.btnPlayPause.tag = indexPath.row
        cell?.btnPlayPause.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
        cell?.btnMore.tag = indexPath.row
        cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
        return cell!
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
               
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(favoriteArray.count) Favourites"
        headerView.btnArrangOrder.tag = section
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
        return headerView
    }
}
extension FavouriteTBVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.tintColor = .white
        searchBar.resignFirstResponder()
        let vc = R.storyboard.search.searchParentVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func BrowseVC(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
    }
}
extension FavouriteTBVC:FilterTable {
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .descending:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            favoriteArray = favoriteArray.sorted(by: { $0.title ?? "" > $1.title ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
     
    }
}
extension FavouriteTBVC:BottomSheetDelegate{
    func goToArtist() {
        let vc = R.storyboard.discover.artistVC()
        self.navigationController?.pushViewController(vc!, animated: true)
      
        
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    
    
    
}
