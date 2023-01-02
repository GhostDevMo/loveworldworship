//
//  PlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds
import MediaPlayer
import EmptyDataSet_Swift

class PlaylistVC: BaseVC {
    
    @IBOutlet weak var addPressed: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    private var publicPlaylistArray = [PublicPlaylistModel.Playlist]()
    private var EventlistArray = [[String:Any]]()
    private var articlesArray = [GetArticlesModel.Datum]()
    private var PlaylistArray = [PlaylistModel.Playlist]()
    private var refreshControl = UIRefreshControl()
    private var productsArray = [[String:Any]]()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPressed.backgroundColor = .mainColor
        self.setupUI()
        titleLabel.title = (NSLocalizedString("Trending", comment: "Trending"))
        fetchPublicPlaylist()
        self.fetchMyPlaylist()
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
        
    }
    @IBAction func addPressed(_ sender: Any) {
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Upload single song", style: .default , handler:{ (UIAlertAction)in
                let mediaPicker = MPMediaPickerController(mediaTypes: .music)
                mediaPicker.delegate = self
                mediaPicker.allowsPickingMultipleItems = false
                self.present(mediaPicker, animated: true, completion: nil)
//                let vc = R.storyboard.album.uploadAlbumVC()
//                         self.navigationController?.pushViewController(vc!, animated: true)
                print("uploadAlbumVC button")
            }))
            
        alert.addAction(UIAlertAction(title: "Import Song", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.track.importURLVC()
            self.navigationController?.pushViewController(vc!, animated: true)
            print("User click Delete button")
        }))
        
            alert.addAction(UIAlertAction(title: "Create Album", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.album.uploadAlbumVC()
                self.navigationController?.pushViewController(vc!, animated: true)
//                let vc = R.storyboard.track.importURLVC()
//                self.navigationController?.pushViewController(vc!, animated: true)
                print("Upload Album button")
            }))

            
        alert.addAction(UIAlertAction(title: "Create Playlist", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.playlist.createPlaylistVC()
            self.present(vc!, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Create Station", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.stations.stationsFullVC()
            self.navigationController?.pushViewController(vc!, animated: true)
           
            print("User click Delete button")
        }))
            
        if AppInstance.instance.userProfile?.data?.artist == 0{
            print("no create event and product")
            
        }else{
            alert.addAction(UIAlertAction(title: "Create Event", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.events.createEventVC()
                self.navigationController?.pushViewController(vc!, animated: true)
               
               
            }))
            alert.addAction(UIAlertAction(title: "Create Product", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.products.createProductVC()
                self.navigationController?.pushViewController(vc!, animated: true)
               
           
            }))
        }
        
        
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
                print("Import button clicked")
            }))

            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
    }
    @IBAction func CartPressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        navigationController?.pushViewController(vc, animated: true)
        print("Navigation to CartVC")
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(SectionHeaderTableItem.nib, forCellReuseIdentifier: SectionHeaderTableItem.identifier)
        self.tableView.register(PlayListSectionOneTableItem.nib, forCellReuseIdentifier: PlayListSectionOneTableItem.identifier)
        self.tableView.register(PlayListSectionTwoTableItem.nib, forCellReuseIdentifier: PlayListSectionTwoTableItem.identifier)
        self.tableView.register(UINib(nibName: "ProductsCollectionTableCell", bundle: nil), forCellReuseIdentifier: "ProductsCollectionTableCell")
        self.tableView.register(UINib(nibName: "EventTableCell", bundle: nil), forCellReuseIdentifier: "EventTableCell")
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
              refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
              self.tableView.addSubview(refreshControl)
        
    }
    @objc func refresh(sender:AnyObject) {
          self.publicPlaylistArray.removeAll()
          self.PlaylistArray.removeAll()
          self.tableView.reloadData()
          fetchPublicPlaylist()
          self.fetchMyPlaylist()
        self.fetchMyEvents()
        self.getProducts()
          refreshControl.endRefreshing()
      }
    private func fetchPublicPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.publicPlaylistArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PlaylistManager.instance.getPublicPlayList(AccessToken: accessToken, Limit: 20, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.fetchMyEvents()
                                self.getProducts()
                                log.debug("userList = \(success?.playlists?.count ?? 0)")
                                self.publicPlaylistArray = success?.playlists ?? []
                                self.tableView.reloadData()
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
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
    private func fetchMyPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.publicPlaylistArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.PlaylistArray = success?.playlists ?? []
                               // self.tableView.reloadData()
                                
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
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
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
    private func fetchMyEvents(){
        if Connectivity.isConnectedToNetwork(){
            self.publicPlaylistArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.getEvents(AccessToken: accessToken, limit: 10, offset: 56) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.getArticles()
                                
                                self.EventlistArray = success ?? []
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
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
                }

            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func getProducts(){
        self.productsArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.getProducts(AccessToken: accessToken, priceTo: 0, priceFrom: 0, category: "") { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.productsArray = success ?? []
                            self.tableView.reloadData()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
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
            }
        })
    }
    private func getArticles(){
        if Connectivity.isConnectedToNetwork(){
            self.articlesArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            
            Async.background({
                ArticlesManager.instance.getArticles(AccessToken: accessToken, limit: 10, offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.articlesArray = success?.data ?? []
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

extension PlaylistVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            return 1
        case 6:
            return 1
        case 7:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString("Event", comment: ""))
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableCell") as? EventTableCell
            cell?.selectionStyle = .none
            cell?.vc1 = self
            cell?.collection
            cell?.bind(EventlistArray)
            return cell!

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString("Hot PlayList", comment: ""))
            
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayListSectionOneTableItem.identifier) as? PlayListSectionOneTableItem
            cell?.selectionStyle = .none
            cell?.vc = self
            cell?.bind(publicPlaylistArray)
            return cell!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString("Articles", comment: ""))
            return cell!
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayListSectionTwoTableItem.identifier) as? PlayListSectionTwoTableItem
            cell?.selectionStyle = .none
            cell?.vc = self
            cell?.bind(articlesArray)
            return cell!
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.btnSeeAll.isHidden = true
            cell?.titleLabel.text = (NSLocalizedString("Products", comment: ""))
            return cell!

        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionTableCell") as? ProductsCollectionTableCell
            cell?.vc = self
            cell?.bind(self.productsArray)
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = R.storyboard.events.eventsVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            log.verbose("")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.EventlistArray.count == 0{
                return 0
            }else{
                return UITableView.automaticDimension
            }
        case 1:
            if self.EventlistArray.count == 0{
                return 0
            }else{
                return 300
            }
        case 2:
            if self.publicPlaylistArray.count == 0{
                return 0
            }else{
                return UITableView.automaticDimension
            }
         
            
        case 3:
            if self.publicPlaylistArray.count == 0{
                return 0
            }else{
                return 300
            }
           
        case 4:
            if self.articlesArray.count == 0{
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
            
        case 5:
            if self.articlesArray.count == 0{
                return 0
            }else{
                return 300
            }
        default:
            return  UITableView.automaticDimension
        }
    }
    
    
}
extension PlaylistVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Not Found", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Something goes worng please trry again.", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
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
extension PlaylistVC:MPMediaPickerControllerDelegate{
    
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
