//
//  SearchParentVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import Async
import JGProgressHUD
import FittedSheets
import DeepSoundSDK

class SearchParentVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    var hud : JGProgressHUD?
    var string :String? = ""
    var filterStatus:Bool? = false
    private var priceString:String?  = ""
    private var genrecString:String?  = ""
    private var pricceIdArray = [Int]()
    private var genrecIdArray = [Int]()
    private lazy var searchBar = UISearchBar(frame: .zero)
    
    override func viewDidLoad() {
        self.setupUI()
        super.viewDidLoad()
        self.filterBtn.tintColor = .ButtonColor
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH) { result in
            //            self.search()
            log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("keyword")])")
            let covertedString = result?.userInfo![AnyHashable("keyword")] as? String
            if self.filterStatus!{
                self.string = covertedString
                self.searchFilter(keyWord: self.string, status: false)
            }else{
                self.string = covertedString
                self.fetchPrices(status: false)
            }
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_FILTER) { result in
            self.filterStatus = true
            let priceStringEvent = result?.userInfo![AnyHashable("priceString")] as? String
            let genresStringEvent = result?.userInfo![AnyHashable("genresString")] as? String
            self.genrecString = genresStringEvent
            self.priceString = priceStringEvent
            log.verbose("priceString from Event Passed = \(self.priceString)")
            log.verbose("genresString from Event Passed = \(self.genrecString)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.largeTitleDisplayMode = .automatic

    }
    
    
    @IBAction func filterPressed(_ sender: Any) {
        
        let controller = SheetViewController(controller: R.storyboard.search.filterSearchVC()!, sizes: [.fixed(420), .fullscreen])
//        controller.blurBottomSafeArea = false
        self.present(controller, animated: true, completion: nil)
        
    }
    
    private func setupUI(){
        searchBar.placeholder = NSLocalizedString("Search...", comment: "Search...")
    
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        let lineColor = UIColor.mainColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = lineColor
        settings.style.buttonBarItemFont =  UIFont(name: "Poppins", size: 15)!
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor(red:26/255, green: 34/255, blue: 78/255, alpha: 0.4)
        let newCellColor = UIColor.mainColor
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .systemGray
            newCell?.label.textColor = newCellColor
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
        
    }
    
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let searchSongsVC = R.storyboard.search.searchSongsVC()
        let searchAlbumsVC = R.storyboard.search.searchAlbumsVC()
        let searchPlaylistVC = R.storyboard.search.searchPlaylistVC()
        let searchArtistVC = R.storyboard.search.searchArtistVC()
        
        
        
        return [searchSongsVC!,searchAlbumsVC!,searchPlaylistVC!,searchArtistVC!]
        
    }
    
    private func fetchPrices(status:Bool){
        self.priceString = ""
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PriceManager.instance.getPrice(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            log.debug("success = \(success?.data ?? [])")
                            success?.data?.forEach({ (it) in
                                self.pricceIdArray.append(it.id ?? 0)
                            })
                            var priceStringMap = self.pricceIdArray.map { String($0)}
                            self.priceString = priceStringMap.joined(separator: ",")
                            log.verbose("priceString = \(self.priceString)")
                            self.fetchGenres(status:status)
                            
                            
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                            
                        })
                    }else {
                        Async.main({
                            
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                            
                        })
                    }
                    
                })
                
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func fetchGenres(status:Bool){
        self.genrecString = ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        log.debug("userList = \(success?.data ?? [])")
                        success?.data?.forEach({ (it) in
                            self.genrecIdArray.append(it.id ?? 0)
                        })
                        var genresStringMap = self.genrecIdArray.map { String($0)}
                        self.genrecString = genresStringMap.joined(separator: ",")
                        log.verbose("priceString = \(self.genrecString)")
                        
                        self.search(keyWord: self.string ?? "",status:status)
                        
                    })
                }else if sessionError != nil{
                    Async.main({
                        
                        
                        self.view.makeToast(sessionError?.error ?? "")
                        log.error("sessionError = \(sessionError?.error ?? "")")
                        
                    })
                }else {
                    Async.main({
                        
                        
                        self.view.makeToast(error?.localizedDescription ?? "")
                        log.error("error = \(error?.localizedDescription ?? "")")
                        
                    })
                }
            })
        })
    }
    
    private func search(keyWord:String?,status:Bool){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let searchKeyword = keyWord ?? ""
            let genresString = self.genrecString ?? ""
            let priceString = self.priceString ?? ""
            Async.background({
                SearchManager.instance.search(AccessToken: accessToken, Keyword: searchKeyword, GenresString: genresString, PriceString: priceString, Limit: 10, Offset: 0, AlbumLimit: 10, AlbumOffset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.status ?? nil)")
                            
                            if status{
                                SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD, userInfo: ["receiveResult":success?.data])
                                self.genrecString = ""
                                self.priceString = ""
                            }else{
                                SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH, userInfo: ["receiveResult":success?.data])
                                self.genrecString = ""
                                self.priceString = ""
                            }
                        })
                        
                        
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                            
                        })
                    }else {
                        Async.main({
                            
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                            
                        })
                    }
                })
                
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func searchFilter(keyWord:String?,status:Bool){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let searchKeyword = keyWord ?? ""
            let genresString = self.genrecString ?? ""
            let priceString = self.priceString ?? ""
            Async.background({
                SearchManager.instance.search(AccessToken: accessToken, Keyword: searchKeyword, GenresString: genresString, PriceString: priceString, Limit: 10, Offset: 0, AlbumLimit: 10, AlbumOffset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.status ?? nil)")
                            
                            if status{
                                SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD, userInfo: ["receiveResult":success?.data])
                                
                            }else{
                                SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH, userInfo: ["receiveResult":success?.data])
                                
                            }
                        })
                        
                        
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                            
                        })
                    }else {
                        Async.main({
                            
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                            
                        })
                    }
                })
                
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
}
extension SearchParentVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
        
    {
        
        let keyword = searchBar.text ?? ""
        self.string = keyword
        if self.filterStatus!{
            self.searchFilter(keyWord: self.string, status: true)
        }else{
          self.fetchPrices(status: true)
        }
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
