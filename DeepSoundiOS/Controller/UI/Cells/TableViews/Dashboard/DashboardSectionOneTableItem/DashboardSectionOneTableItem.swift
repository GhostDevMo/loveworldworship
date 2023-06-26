//
//  DashboardSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK
class DashboardSectionOneTableItem: UITableViewCell {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var object:DiscoverModel.Randoms?
    var notLoggedobject: DiscoverModel.Randoms?
    
    let collectionViewCellHeightCoefficient: CGFloat = 0.85
    let collectionViewCellWidthCoefficient: CGFloat = 0.55
    let cellsShadowColor = UIColor.hexStringToUIColor(hex: "2a002a").cgColor
    private var slideMusicArray = [MusicPlayerModel]()
    
    var notloggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.configureCollectionView()
        self.pageControl.pageIndicatorTintColor = .mainColor
    }
    private func configureCollectionView() {
        let gravitySliderLayout = GravitySliderFlowLayout(with: CGSize(width: collectionView.frame.size.height * collectionViewCellWidthCoefficient, height: collectionView.frame.size.height * collectionViewCellHeightCoefficient))
        collectionView.collectionViewLayout = gravitySliderLayout
        
    }
    
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(DashboardSectionOneCollectionItem.nib, forCellWithReuseIdentifier: DashboardSectionOneCollectionItem.identifier)
    }
    func bind(_ object:DiscoverModel.Randoms?){
        self.object = object
        self.pageControl.numberOfPages = (self.object?.recommended?.count ?? 0)
        self.collectionView.reloadData()
    }
    func notLoggedBind(_ object:DiscoverModel.Randoms?){
        self.notLoggedobject = object
        self.pageControl.numberOfPages = (self.object?.recommended?.count ?? 0)
        self.collectionView.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    private func configureProductCell(_ cell: DashboardSectionOneCollectionItem, for indexPath: IndexPath) {
        cell.clipsToBounds = false
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.bounds
        //        gradientLayer.colors = [gradientFirstColor, gradientSecondColor]
        gradientLayer.cornerRadius = 21
        gradientLayer.masksToBounds = true
        cell.layer.insertSublayer(gradientLayer, at: 0)
        
        cell.layer.shadowColor = cellsShadowColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 20
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 30)
        
        
    }
    
}
extension DashboardSectionOneTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.loggedInVC != nil{
            return self.object?.recommended?.count ?? 0
            
        }else{
            return self.notLoggedobject?.recommended?.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.loggedInVC != nil{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSectionOneCollectionItem.identifier, for: indexPath) as? DashboardSectionOneCollectionItem
            let object = self.object?.recommended![indexPath.row]
            configureProductCell(cell!, for: indexPath)
            cell?.bind(object!)
            return cell!
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSectionOneCollectionItem.identifier, for: indexPath) as? DashboardSectionOneCollectionItem
            let object = self.notLoggedobject?.recommended![indexPath.row]
            configureProductCell(cell!, for: indexPath)
            cell?.notLoggedBind(object!)
            return cell!
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        if self.loggedInVC != nil{
            let object = self.object?.recommended![indexPath.row]
            
            self.object?.recommended?.forEach({ (it) in
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
                self.slideMusicArray.append(musicObject)
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
            let commentCount = object?.countComment?.intValue ?? 0
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
            
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object?.countComment?.stringValue ?? ""
            let duration = object?.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = collectionView.cellForItem(at: indexPath) as? DashboardSectionOneCollectionItem
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
            AppInstance.instance.popupPlayPauseSong = false
            
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            if self.notloggedInVC != nil{
                self.notloggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.slideMusicArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                    
                })
            }else if self.loggedInVC != nil{
                self.loggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.slideMusicArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                    
                })
            }
            
        }else{
            let object = self.notLoggedobject?.recommended![indexPath.row]
            
            self.notLoggedobject?.recommended?.forEach({ (it) in
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
                self.slideMusicArray.append(musicObject)
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
            let commentCount = object?.countComment?.intValue ?? 0
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
            
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object?.countComment?.stringValue ?? ""
            let duration = object?.duration ?? "0:0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = collectionView.cellForItem(at: indexPath) as? DashboardSectionOneCollectionItem
            popupContentController!.popupItem.image = cell?.thumbnailImage.image
            AppInstance.instance.popupPlayPauseSong = false
            
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            if self.notloggedInVC != nil{
                self.notloggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.notloggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.slideMusicArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                    
                })
            }else if self.loggedInVC != nil{
                self.loggedInVC?.addToRecentlyWatched(trackId: object?.id ?? 0)
                self.loggedInVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                    
                    self.popupContentController?.musicObject = musicObject
                    self.popupContentController!.musicArray = self.slideMusicArray
                    self.popupContentController!.currentAudioIndex = indexPath.row
                    self.popupContentController?.setup()
                    
                })
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 193, height: 250)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
extension DashboardSectionOneTableItem {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let locationFirst = CGPoint(x: collectionView.center.x + scrollView.contentOffset.x, y: collectionView.center.y + scrollView.contentOffset.y)
        let locationSecond = CGPoint(x: collectionView.center.x + scrollView.contentOffset.x + 20, y: collectionView.center.y + scrollView.contentOffset.y)
        let locationThird = CGPoint(x: collectionView.center.x + scrollView.contentOffset.x - 20, y: collectionView.center.y + scrollView.contentOffset.y)
        
        if let indexPathFirst = collectionView.indexPathForItem(at: locationFirst), let indexPathSecond = collectionView.indexPathForItem(at: locationSecond), let indexPathThird = collectionView.indexPathForItem(at: locationThird), indexPathFirst.row == indexPathSecond.row && indexPathSecond.row == indexPathThird.row && indexPathFirst.row != pageControl.currentPage {
            pageControl.currentPage = indexPathFirst.row % (self.object?.recommended?.count)! ?? 0
        }
    }
}
