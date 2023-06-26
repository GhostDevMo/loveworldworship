//
//  DashboardVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds

class DashboardVC: BaseVC {
    
    @IBOutlet weak var artistSeeAllLabel: UILabel!
    @IBOutlet weak var popularSeeAllLabel: UILabel!
    @IBOutlet weak var recentlyPlayedSeeAllLabel: UILabel!
    @IBOutlet weak var newReleaseSeeAllLabel: UILabel!
    @IBOutlet weak var showStackFive: UIStackView!
    @IBOutlet weak var showStackFour: UIStackView!
    @IBOutlet weak var showStackThree: UIStackView!
    @IBOutlet weak var showStackTwo: UIStackView!
    @IBOutlet weak var showStackOne: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var slideCollectionView: UICollectionView!
    @IBOutlet weak var artistCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var recentlyPlayedCollectionView: UICollectionView!
    @IBOutlet weak var newReleaseCollectionView: UICollectionView!
    @IBOutlet weak var genresCollectionView: UICollectionView!
    
    let label = UILabel(frame: CGRect(x: 10, y: -10, width: 20, height: 20))
    private var latestSongsArray:DiscoverModel.NewReleases?
    private var recentlyPlayedArray:DiscoverModel.NewReleases?
    private var mostPopularArray:DiscoverModel.MostPopularWeek?
    private var genresArray = [GenresModel.Datum]()
    private var artistArray = [ArtistModel.Datum]()
    private var slideShowArray:DiscoverModel.Randoms?
    private var refreshControl = UIRefreshControl()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var slideMusicArray = [MusicPlayerModel]()
    private var newReleaseArray = [MusicPlayerModel]()
    private var recentlyPlayedArrayMusic = [MusicPlayerModel]()
    private var popularArray = [MusicPlayerModel]()
    private var notificationCount:Int? = 0
    private var loadinDevices = false
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchDiscover()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
        AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        if ControlSettings.shouldShowAddMobBanner{

            //bannerView = GADBannerView(adSize: GADAdSize())
            addBannerViewToView(bannerView)
            bannerView.adUnitID = ControlSettings.addUnitId
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
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
        
    }
    deinit{
        SwiftEventBus.unregister(self)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchNotification()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            self.view.makeToast(InterNetError)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEventBus.unregister(self)
    }
    
    @IBAction func newReleasePressed(_ sender: Any) {
        let vc = R.storyboard.discover.latestSongsVC()
        vc!.latestSongsArray = self.latestSongsArray ?? nil
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func artistPressed(_ sender: Any) {
        let vc = R.storyboard.discover.artistVC()
//        vc!.artistArray = self.artistArray ?? []
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func popularPressed(_ sender: Any) {
        let vc = R.storyboard.discover.popularVC()
        vc!.popularArray = self.mostPopularArray ?? nil
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func recentlyPlayedPressed(_ sender: Any) {
        let vc = R.storyboard.discover.dashboardRecentlyPlayedVC()
//        vc!.recentlyPlayedArray = self.recentlyPlayedArray ?? nil
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func setupUI(){
        self.showStackOne.isHidden = true
        self.showStackTwo.isHidden = true
        self.showStackThree.isHidden = true
        self.showStackFour.isHidden = true
        self.showStackFive.isHidden = true
        self.recentlyPlayedSeeAllLabel.isHidden = true
        self.artistSeeAllLabel.isHidden = true
        self.popularSeeAllLabel.isHidden = true
        self.newReleaseSeeAllLabel.isHidden = true
        navigationController!.popupInteractionStyle = .drag
        // badge label
        
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont(name: "SanFranciscoText-Light", size: 13)
        label.textColor = .white
        label.backgroundColor = .red
        
        
        // button
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 16))
        rightButton.setBackgroundImage(R.image.ic_bell(), for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
        rightButton.addSubview(label)
        
        // Bar button item
        let rightBarButtomItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtomItem
        
        let leftBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 16))
        leftBarButton.setBackgroundImage(R.image.ic_rocket(), for: .normal)
        leftBarButton.addTarget(self, action: #selector(leftButtonTouched), for: .touchUpInside)

        // Bar button item
        let leftBarButtomItem = UIBarButtonItem(customView: leftBarButton)
        navigationItem.leftBarButtonItem = leftBarButtomItem
        
        
        self.label.isHidden = true
        
        slideCollectionView.register(DashboardSlider_CollectionCell.nib, forCellWithReuseIdentifier: DashboardSlider_CollectionCell.identifier)
        genresCollectionView.register(DashboardGenres_CollectionCell.nib, forCellWithReuseIdentifier: DashboardGenres_CollectionCell.identifier)
        newReleaseCollectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
        recentlyPlayedCollectionView.register(DashboardRecentlyPlayed_CollectionCell.nib, forCellWithReuseIdentifier: DashboardRecentlyPlayed_CollectionCell.identifier)
        popularCollectionView.register(DashboardPopular_CollectionCell.nib, forCellWithReuseIdentifier: DashboardPopular_CollectionCell.identifier)
        artistCollectionView.register(DashboardArtist_CollectionCell.nib, forCellWithReuseIdentifier: DashboardArtist_CollectionCell.identifier)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        scrollView.addSubview(refreshControl)
    }
    @objc func rightButtonTouched() {
        let vc = R.storyboard.notfication.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func leftButtonTouched() {
        let vc = R.storyboard.upgrade.upgradeProVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func refresh(sender:AnyObject) {
        self.latestSongsArray?.data?.removeAll()
        self.recentlyPlayedArray?.data?.removeAll()
        self.mostPopularArray?.data?.removeAll()
        self.slideShowArray?.recommended?.removeAll()
        self.artistArray.removeAll()
        self.genresArray.removeAll()
        self.showStackOne.isHidden = true
        self.showStackTwo.isHidden = true
        self.showStackThree.isHidden = true
        self.showStackFour.isHidden = true
        self.showStackFive.isHidden = true
        self.recentlyPlayedSeeAllLabel.isHidden = true
        self.artistSeeAllLabel.isHidden = true
        self.popularSeeAllLabel.isHidden = true
        self.newReleaseSeeAllLabel.isHidden = true
        
        self.artistCollectionView.reloadData()
        self.genresCollectionView.reloadData()
        self.recentlyPlayedCollectionView.reloadData()
        self.popularCollectionView.reloadData()
        self.newReleaseCollectionView.reloadData()
        self.slideCollectionView.reloadData()
        
        
        self.fetchDiscover()
        refreshControl.endRefreshing()
    }
    
    private func fetchNotification(){
        if Connectivity.isConnectedToNetwork(){
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            Async.background({
                NotificationManager.instance.notificationUnseenCount(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.count ?? 0)")
                                self.notificationCount = success?.count
                                if self.notificationCount == 0{
                                    self.label.isHidden = true
                                }else{
                                    self.label.isHidden = false
                                    self.label.text = "\(self.notificationCount  ?? 0)"
                                }
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
            self.recentlyPlayedArray?.data?.removeAll()
            self.mostPopularArray?.data?.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,notLoggedInSuccess ,sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            
                            log.debug("userList = \(success?.status ?? 0)")
                            self.latestSongsArray = success?.newReleases ?? nil
//                            self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
//                            self.mostPopularArray = success?.mostPopularWeek ?? nil
                            self.slideShowArray = success?.randoms ?? nil
                            self.fetchGenres()
                            
                            
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
                            self.showStackOne.isHidden = false
                            self.showStackTwo.isHidden = false
                            self.showStackThree.isHidden = false
                            self.showStackFour.isHidden = false
                            self.showStackFive.isHidden = false
                            self.recentlyPlayedSeeAllLabel.isHidden = false
                            self.artistSeeAllLabel.isHidden = false
                            self.popularSeeAllLabel.isHidden = false
                            self.newReleaseSeeAllLabel.isHidden = false
                            self.artistCollectionView.reloadData()
                            self.genresCollectionView.reloadData()
                            self.recentlyPlayedCollectionView.reloadData()
                            self.popularCollectionView.reloadData()
                            self.newReleaseCollectionView.reloadData()
                            self.slideCollectionView.reloadData()
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
}


extension DashboardVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == genresCollectionView{
            return (self.genresArray.count) ?? 0
        }else if collectionView == newReleaseCollectionView{
            return (self.latestSongsArray?.data!.count) ?? 0
        }else if collectionView == recentlyPlayedCollectionView{
            return (self.recentlyPlayedArray?.data!.count) ?? 0
        }else if collectionView == popularCollectionView{
            return (self.mostPopularArray?.data!.count) ?? 0
        }else if collectionView == artistCollectionView{
            return (self.artistArray.count) ?? 0
            
        }else{
            pageControl.numberOfPages = (self.slideShowArray?.recommended?.count) ?? 0
            return (self.slideShowArray?.recommended?.count) ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if collectionView == genresCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardGenres_CollectionCell.identifier, for: indexPath) as? DashboardGenres_CollectionCell
            let object = genresArray[indexPath.row]
            cell?.nameLabel.text = object.cateogryName?.htmlAttributedString ?? ""
            cell?.colorView.backgroundColor = UIColor.init().hexStringToUIColor(hex: object.color ?? "").withAlphaComponent(0.4)
            cell?.colorView.isOpaque = false
            let url = URL.init(string:object.backgroundThumb ?? "")
            cell?.backgroundImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else if collectionView == newReleaseCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            let object = self.latestSongsArray?.data![indexPath.row]
            cell?.titleLabel.text = object?.title?.htmlAttributedString ?? ""
            cell?.MusicCountLabel.text = "\(object?.categoryName ?? "") Music"
            let url = URL.init(string:object?.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else if collectionView == recentlyPlayedCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardRecentlyPlayed_CollectionCell.identifier, for: indexPath) as? DashboardRecentlyPlayed_CollectionCell
            let object = self.recentlyPlayedArray?.data![indexPath.row]
            cell?.titleLabel.text = object?.title?.htmlAttributedString ?? ""
            cell?.musicCountLabel.text = "\(object?.categoryName ?? "") Music"
            log.verbose("object?.countViews = \(object?.countViews)")
            let url = URL.init(string:object?.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else if collectionView == popularCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardPopular_CollectionCell.identifier, for: indexPath) as? DashboardPopular_CollectionCell
            let object = self.mostPopularArray?.data![indexPath.row]
            cell?.titleLabel.text = object?.title?.htmlAttributedString ?? ""
            cell?.musicCountLabel.text = "\(object?.categoryName ?? "") Music"
            let url = URL.init(string:object?.thumbnail ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
        }else if collectionView == artistCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardArtist_CollectionCell.identifier, for: indexPath) as? DashboardArtist_CollectionCell
            let object = self.artistArray[indexPath.row]
            cell?.titleLabel.text = object.name ?? object.username ?? ""
            
            let url = URL.init(string:object.avatar ?? "")
            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            
            return cell!
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSlider_CollectionCell.identifier, for: indexPath) as? DashboardSlider_CollectionCell
            let object = self.slideShowArray?.recommended![indexPath.row]
            cell?.titleLabel.text = object?.title?.htmlAttributedString ?? ""
            cell?.categoryLabel.text = "\(object?.categoryName ?? "") Music"
            let url = URL.init(string:object?.thumbnail ?? "")
            cell?.thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
            return cell!
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
            interstitial.present(fromRootViewController: self)
                interstitial = CreateAd()
                AppInstance.instance.addCount = 0
        }
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        if collectionView == genresCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let vc = R.storyboard.discover.genresSongsVC()
            vc?.genresId = self.genresArray[indexPath.row].id ?? 0
            vc?.titleString = self.genresArray[indexPath.row].cateogryName ?? ""

            self.navigationController?.pushViewController(vc!, animated: true)
            
        }else if collectionView == artistCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let vc = R.storyboard.discover.userInfoVC()
            vc?.artistObject = self.artistArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }else if collectionView == slideCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let object = self.slideShowArray?.recommended![indexPath.row]
            
            self.slideShowArray?.recommended?.forEach({ (it) in
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
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
           
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.slideMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
        }else if collectionView == newReleaseCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let object = self.latestSongsArray?.data![indexPath.row]
            
            
            self.latestSongsArray?.data!.forEach({ (it) in
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
                self.newReleaseArray.append(musicObject)
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
            popupContentController!.popupItem.image = R.image.imagePlacholder()
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.newReleaseArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
            
        }else if collectionView == recentlyPlayedCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let object = self.recentlyPlayedArray?.data![indexPath.row]
            
            self.recentlyPlayedArray?.data!.forEach({ (it) in
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
                self.recentlyPlayedArrayMusic.append(musicObject)
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
            popupContentController!.popupItem.image = R.image.imagePlacholder()
            
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.recentlyPlayedArrayMusic
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
            
        }
        else if collectionView == popularCollectionView{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

            let object = self.mostPopularArray?.data![indexPath.row]
            
            self.mostPopularArray?.data!.forEach({ (it) in
                
                var audioString:String? = ""
                var isDemo:Bool? = false
                
                let name = it?.publisher?.name ?? ""
                let time = it?.timeFormatted ?? ""
                let title = it?.title ?? ""
                let musicType = it?.categoryName ?? ""
                let thumbnailImageString = it?.thumbnail ?? ""
                
                if it?.demoTrack == ""{
                    audioString = it?.audioLocation ?? ""
                    isDemo = false
                }else if it?.demoTrack != "" && it?.audioLocation != ""{
                    audioString = it?.audioLocation ?? ""
                    isDemo = false
                }else{
                    audioString = it?.demoTrack ?? ""
                    isDemo = true
                }
                let isOwner = it?.isOwner ?? false
                let audioId = it?.audioID ?? ""
                let likeCount = it?.countLikes?.intValue ?? 0
                let favoriteCount = it?.countFavorite?.intValue ?? 0
                let recentlyPlayedCount = it?.countViews?.intValue ?? 0
                let sharedCount = it?.countShares?.intValue ?? 0
                let commentCount = it?.countComment?.intValue ?? 0
                let trackId = it?.id ?? 0
                let isLiked = it?.isLiked ?? false
                let isFavorited = it?.isFavoriated ?? false
                let likecountString = it?.countLikes?.stringValue ?? ""
                let favoriteCountString = it?.countFavorite?.stringValue ?? ""
                let recentlyPlayedCountString = it?.countViews?.stringValue ?? ""
                let sharedCountString = it?.countShares?.stringValue ?? ""
                let commentCountString = it?.countComment?.stringValue ?? ""
                
                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                self.popularArray.append(musicObject)
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
            popupContentController!.popupItem.image = R.image.imagePlacholder()
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
       
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.popularArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                
            })
            
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0{
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
            if let ip = self.slideCollectionView.indexPathForItem(at: center){
                self.pageControl.currentPage  = ip.row
            }
        }
        if (scrollView.contentOffset.y < -60 && !loadinDevices) {
            loadinDevices = true
            self.latestSongsArray?.data?.removeAll()
            self.recentlyPlayedArray?.data?.removeAll()
            self.mostPopularArray?.data?.removeAll()
            self.slideShowArray?.recommended?.removeAll()
            self.artistArray.removeAll()
            self.genresArray.removeAll()
            self.showStackOne.isHidden = true
            self.showStackTwo.isHidden = true
            self.showStackThree.isHidden = true
            self.showStackFour.isHidden = true
            self.showStackFive.isHidden = true
            self.recentlyPlayedSeeAllLabel.isHidden = true
            self.artistSeeAllLabel.isHidden = true
            self.popularSeeAllLabel.isHidden = true
            self.newReleaseSeeAllLabel.isHidden = true
            
            self.artistCollectionView.reloadData()
            self.genresCollectionView.reloadData()
            self.recentlyPlayedCollectionView.reloadData()
            self.popularCollectionView.reloadData()
            self.newReleaseCollectionView.reloadData()
            self.slideCollectionView.reloadData()
            
            
            self.fetchDiscover()
            refreshControl.endRefreshing()
        }
        
    }
  
}
