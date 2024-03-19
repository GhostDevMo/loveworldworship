//
//  SearchVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 11/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK
import Async

struct Page {
    
    var name = ""
    var vc = UIViewController()
    
    init(with _name: String, _vc: UIViewController) {
        
        name = _name
        vc = _vc
    }
}
struct PageCollection {
    
    var pages = [Page]()
    var selectedPageIndex = 0 //The first page is selected by default in the beginning
}

class SearchVC: BaseVC {
    
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var trendingView: UIView!
    
    var isSearch = false {
        didSet {
            self.trendingView.isHidden = self.isSearch
        }
    }
    var searchCategoryArr: [String] = []
    var recentSearchArr: [String] = []
    var searchListArr: [String] = []
    
    var pageCollection = PageCollection()
    
    //MARK:- Programatic UI Properties
    var searchString: String?
    var filterStatus = false
    var pageViewController = UIPageViewController()
    var selectedTabView = UIView()
    private var priceString:String?
    private var genrecString:String?
    private var priceIdArray: [Int] = []
    private var genrecIdArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.trendSearchAPI()
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH) { result in
            log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("isRandomSearch")] ?? "")")
            if let isRandomSearch = result?.userInfo![AnyHashable("isRandomSearch")] as? Bool, isRandomSearch {
                let randomString:String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
                self.searchString = randomString
                if self.filterStatus {
                    self.searchFilter(keyWord: self.searchString, status: false)
                }else{
                    self.fetchPrices(status: false)
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_FILTER) { result in
            self.filterStatus = true
            let priceStringEvent = result?.userInfo![AnyHashable("priceString")] as? String
            let genresStringEvent = result?.userInfo![AnyHashable("genresString")] as? String
            self.genrecString = genresStringEvent
            self.priceString = priceStringEvent
            log.verbose("priceString from Event Passed = \(String(describing: self.priceString))")
            log.verbose("genresString from Event Passed = \(self.genrecString ?? "")")
        }
    }
    
    @IBAction func clearBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.searchTF.text = nil
        self.clearBtn.isHidden = true
        self.isSearch = false
        self.tableView.reloadData()
    }
    
    @IBAction func filterPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.search.filterSearchVC()!
        //        vc.delegate = self
        //        vc.categoryID = selectedCategory
        let panVC: PanModalPresentable.LayoutType = vc
        presentPanModal(panVC)
        
    }
    
    func setupUI() {
        self.searchTF.delegate = self
        self.setupCollectionView()
        self.setupPagingViewController()
        self.populateBottomView()
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.searchCategoryCell), forCellReuseIdentifier: R.reuseIdentifier.searchCategoryCell.identifier)
    }
    
    func setupCollectionView() {
        tabBarCollectionView.register(UINib(resource: R.nib.categoryCell),
                                      forCellWithReuseIdentifier: R.reuseIdentifier.categoryCell.identifier)
        tabBarCollectionView.dataSource = self
        tabBarCollectionView.delegate = self
    }
    
    func setupPagingViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    func populateBottomView() {
        guard let searchSongsVC = R.storyboard.search.searchSongsVC() else { return }
        searchSongsVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Song", _vc: searchSongsVC))
        
        guard let searchAlbumsVC = R.storyboard.search.searchAlbumsVC() else { return  }
        searchAlbumsVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Album", _vc: searchAlbumsVC))
        
        guard let searchPlaylistVC = R.storyboard.search.searchPlaylistVC() else { return  }
        searchPlaylistVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Playlist", _vc: searchPlaylistVC))
        
        guard let searchArtistVC = R.storyboard.search.searchArtistVC() else { return  }
        searchArtistVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Artist", _vc: searchArtistVC))
        
        guard let searchEventsVC = R.storyboard.search.searchEventsVC() else { return  }
        searchEventsVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Event", _vc: searchEventsVC))
        
        guard let searchProductsVC = R.storyboard.search.searchProductsVC() else { return  }
        searchProductsVC.viewDidLoad()
        pageCollection.pages.append(Page(with: "Product", _vc: searchProductsVC))
        
        let initialPage = 0
        pageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        pinPagingViewControllerToBottomView()
    }
    
    func pinPagingViewControllerToBottomView() {
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        pageViewController.setViewControllers([pageCollection.pages[index].vc],
                                              direction: navigationDirection,
                                              animated: true,
                                              completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        pageCollection.selectedPageIndex = indexPath.item
        tabBarCollectionView.scrollToItem(at: indexPath,
                                          at: .centeredHorizontally,
                                          animated: true)
        self.tabBarCollectionView.reloadData()
    }
    
    // Add Search Text In Recent Search
    func addSearchTextInRecentSearch(searchText: String) {
        var recentSearchString = searchText
        self.recentSearchArr = []
        self.searchListArr = []
        recentSearchString = recentSearchString + "," + ((UserDefaults.standard.value(forKey: "RecentSearchString") as? String) ?? "")
        UserDefaults.standard.setValue(recentSearchString, forKey: "RecentSearchString")
        let tempSearchArr = (UserDefaults.standard.value(forKey: "RecentSearchString") as! String).split(separator: ",")
        for search in tempSearchArr {
            self.recentSearchArr.append(String(search))
        }
        self.searchListArr.append(contentsOf: self.recentSearchArr)
        self.searchListArr.append(contentsOf: self.searchCategoryArr)
        self.searchListArr = self.searchListArr.unique()
        let updatedString = self.recentSearchArr.joined(separator: ",")
        UserDefaults.standard.setValue(updatedString, forKey: "RecentSearchString")
    }
}

// MARK: TableView Setup
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchCategoryCell.identifier) as! SearchCategoryCell
        cell.titleLabel?.text = self.searchListArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isSearch = true
        self.clearBtn.isHidden = false
        self.searchTF.text = searchListArr[indexPath.row]
        self.textFieldDidEndEditing(self.searchTF)
    }
}


//MARK: - API Services -
extension SearchVC {
    private func fetchPrices(status: Bool) {
        self.priceString = ""
        self.priceIdArray.removeAll()
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PriceManager.instance.getPrice(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.data ?? [])")
                            success?.data?.forEach({ (it) in
                                self.priceIdArray.append(it.id ?? 0)
                            })
                            let priceStringMap = self.priceIdArray.map { String($0)}
                            self.priceString = priceStringMap.joined(separator: ",")
                            log.verbose("priceString = \(self.priceString ?? "")")
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
        self.genrecIdArray.removeAll()
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
                        self.searchFilter(keyWord: self.searchString ?? "",status:status)
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
    
    private func searchFilter(keyWord:String?,status:Bool) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let searchKeyword = keyWord ?? ""
            let genresString = self.genrecString ?? ""
            let priceString = self.priceString ?? ""
            Async.background({
                SearchManager.instance.search(AccessToken: accessToken, Keyword: searchKeyword, GenresString: genresString, PriceString: priceString, Limit: 10, Offset: 0, AlbumLimit: 10, AlbumOffset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.status ?? 0)")
                            if let data = success?.data {
                                SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD, userInfo: ["receiveResult": data])
                                self.genrecString = ""
                                self.priceString = ""
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError = \(sessionError ?? "")")
                            self.view.makeToast(sessionError ?? "")
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
    
    private func trendSearchAPI() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                UserManager.instance.trendSearchAPI { (success, sessionError, error) in
                    if success != nil {
                        Async.main({
                            log.debug("userList = \(success?.data ?? [])")
                            success?.data.forEach({ (it) in
                                print(it.keyword)
                                self.searchCategoryArr.append(it.keyword)
                            })
                            self.recentSearchArr = []
                            self.searchListArr = []
                            let tempSearchArr = ((UserDefaults.standard.value(forKey: "RecentSearchString") as? String) ?? "").split(separator: ",")
                            for search in tempSearchArr {
                                self.recentSearchArr.append(String(search))
                            }
                            self.searchListArr.append(contentsOf: self.recentSearchArr)
                            self.searchListArr.append(contentsOf: self.searchCategoryArr)
                            self.searchListArr = self.searchListArr.unique()
                            self.tableView.reloadData()
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
                }
            }
        }else {
            log.error("error = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

//MARK: - UITextField Delegate Methods -
extension SearchVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let keyword = textField.text ?? ""
        self.searchString = keyword
        self.addSearchTextInRecentSearch(searchText: keyword)
        if self.filterStatus {
            self.searchFilter(keyWord: self.searchString, status: true)
        } else {
            self.fetchPrices(status: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == searchTF {
            if textField.text == "" {
                self.clearBtn.isHidden = true
                self.isSearch = false
                self.tableView.reloadData()
            } else {
                self.clearBtn.isHidden = false
                self.isSearch = true
            }
            SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD, userInfo: ["isTyping": true])
        }
    }
}

//MARK: - Collection View Data Source -
extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCollection.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.categoryCell.identifier, for: indexPath) as? CategoryCell {
            cell.categoryLabel.text = pageCollection.pages[indexPath.row].name
            cell.mainView.borderColorV = .ButtonColor
            cell.mainView.borderWidthV = 1
            cell.mainView.cornerRadiusV = 20.0
            cell.backView.isHidden = true
            cell.categoryLabel.font = setCustomFont(size: 18.0, fontName: R.font.urbanistSemiBold.name)
            if indexPath.row == self.pageCollection.selectedPageIndex {
                cell.mainView.backgroundColor = .ButtonColor
                cell.categoryLabel.textColor = .white
            } else {
                cell.mainView.backgroundColor = .white
                cell.categoryLabel.textColor = .ButtonColor
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

//MARK:- Collection View Delegate

extension SearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == pageCollection.selectedPageIndex {
            return
        }
        var direction: UIPageViewController.NavigationDirection
        if indexPath.item > pageCollection.selectedPageIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        scrollSelectedTabView(toIndexPath: indexPath)
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: getWidthFromItem(title: self.pageCollection.pages[indexPath.row].name, font: setCustomFont(size: 18.0, fontName: R.font.urbanistSemiBold.name)).width + 30.0, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    // Get Width From String
    func getWidthFromItem(title: String, font: UIFont) -> CGSize {
        let itemSize = title.size(withAttributes: [
            NSAttributedString.Key.font: font
        ])
        return itemSize
    }
    
    // Set Custom Font
    func setCustomFont(size: CGFloat, fontName: String) -> UIFont {
        return UIFont.init(name: fontName, size: size)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

//MARK:- Delegate Method to give the next and previous View Controllers to the Page View Controller

extension SearchVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                // go to previous page in array
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                // go to next page in array
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}

//MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
//Capture it and change the selection bar position in collection View

extension SearchVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        scrollSelectedTabView(toIndexPath: indexPathAtCollectionView)
    }
}
