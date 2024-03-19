//
//  TrendingVC.swift
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
import Toast_Swift

class TrendingVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var lblCartCount: UILabel!
    
    // MARK: - Properties
    
    var isLoading = true
    private var publicPlaylistArray = [Playlist]()
    private var eventlistArray = [Events]()
    private var articlesArray = [Blog]()
    // private var PlaylistArray = [Playlist]()
    private var refreshControl = UIRefreshControl()
    private var productsArray = [Product]()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        fetchPublicPlaylist()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        SwiftEventBus.onMainThread(self, name: "ReloadProductData") { result in
            self.getProducts()
        }
        if ControlSettings.shouldShowAddMobBanner {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId, request: request, completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            })
        }
        self.btnCart.isHidden = !AppInstance.instance.isLoginUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppInstance.instance.isLoginUser {
            self.fetchCartItems()
        }
    }
    
    // MARK: - Selectors
    
    @IBAction func CartPressed(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        navigationController?.pushViewController(vc, animated: true)
        print("Navigation to CartVC")
    }
    
    @objc func didTappSeeAll(_ sender:UIButton) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let vc = R.storyboard.events.eventsVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if sender.tag == 1002 {
            let vc = R.storyboard.settings.articlesVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if sender.tag == 1003 {
            let vc = R.storyboard.products.discoverProductsVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: ControlSettings.interestialAddUnitId, request: GADRequest(), completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        })
        return  self.interstitial
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.searchTableViewCell), forCellReuseIdentifier: R.reuseIdentifier.searchTableViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.sectionHeaderTableItem), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.playListSectionOneTableItem),
                                forCellReuseIdentifier: R.reuseIdentifier.playListSectionOneTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.playListSectionTwoTableItem),
                                forCellReuseIdentifier: R.nib.playListSectionTwoTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.productsCollectionTableCell),
                                forCellReuseIdentifier: R.reuseIdentifier.productsCollectionTableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.eventTableCell),
                                forCellReuseIdentifier: R.reuseIdentifier.eventTableCell.identifier)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.tableView.addPullToRefresh { [self] in
            publicPlaylistArray.removeAll()
            eventlistArray.removeAll()
            articlesArray.removeAll()
            productsArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchPublicPlaylist()
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension TrendingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            switch section {
            case 0:
                return 1
            case 1, 2, 3, 4:
                return 2
            default:
                return 0
            }
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                if publicPlaylistArray.count == 0 {
                    return 0
                } else {
                    return 2
                }
            case 2:
                if eventlistArray.count == 0 {
                    return 0
                }else {
                    return 2
                }
            case 3:
                if articlesArray.count == 0 {
                    return 0
                } else {
                    return 2
                }
            case 4:
                if productsArray.count == 0 {
                    return 0
                } else {
                    return 2
                }
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
                return cell
            case 1:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.startSkelting()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playListSectionOneTableItem.identifier) as! PlayListSectionOneTableItem
                    cell.isLoading = self.isLoading
                    return cell
                }
            case 2:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.startSkelting()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventTableCell.identifier) as! EventTableCell
                    cell.isEvent = true
                    cell.isLoading = self.isLoading
                    return cell
                }
            case 3:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.startSkelting()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventTableCell.identifier) as! EventTableCell
                    cell.isEvent = false
                    cell.isLoading = self.isLoading
                    return cell
                }
            case 4:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.startSkelting()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productsCollectionTableCell.identifier) as! ProductsCollectionTableCell
                    cell.isLoading = self.isLoading
                    return cell
                }
            default:
                return UITableViewCell()
            }
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
                cell.delegate = self
                return cell
            case 1:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.btnSeeAll.isHidden = true
                    cell.titleLabel.text = (NSLocalizedString("Hot PlayList", comment: ""))
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playListSectionOneTableItem.identifier) as! PlayListSectionOneTableItem
                    cell.isLoading = self.isLoading
                    cell.selectionStyle = .none
                    cell.delegate = self
                    cell.bind(publicPlaylistArray)
                    return cell
                }
            case 2:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.btnSeeAll.isHidden = false
                    cell.btnSeeAll.tag = 1001
                    cell.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    cell.titleLabel.text = (NSLocalizedString("Event", comment: ""))
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventTableCell.identifier) as! EventTableCell
                    cell.isEvent = true
                    cell.selectionStyle = .none
                    cell.delegate = self
                    cell.isLoading = self.isLoading
                    cell.bind(eventlistArray)
                    return cell
                }
            case 3:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.btnSeeAll.isHidden = false
                    cell.btnSeeAll.tag = 1002
                    cell.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    cell.titleLabel.text = (NSLocalizedString("Articles", comment: ""))
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventTableCell.identifier) as! EventTableCell
                    cell.isEvent = false
                    cell.isLoading = self.isLoading
                    cell.delegate = self
                    cell.selectionStyle = .none
                    cell.bind(articlesArray)
                    return cell
                }
            case 4:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                    cell.stopSkelting()
                    cell.selectionStyle = .none
                    cell.btnSeeAll.isHidden = false
                    cell.btnSeeAll.tag = 1003
                    cell.btnSeeAll.addTarget(self, action: #selector(didTappSeeAll(_:)), for: .touchUpInside)
                    cell.titleLabel.text = (NSLocalizedString("Products", comment: ""))
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productsCollectionTableCell.identifier) as! ProductsCollectionTableCell
                    cell.isLoading = self.isLoading
                    cell.delegate = self
                    cell.bind(self.productsArray)
                    return cell
                }
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            switch indexPath.section {
            case 0:
                return 70
            case 1, 2, 3, 4:
                if indexPath.row == 0 {
                    return 50.0
                }
                return UITableView.automaticDimension
            default:
                return  UITableView.automaticDimension
            }
        } else {
            switch indexPath.section {
            case 0:
                return 70
            case 1:
                if self.publicPlaylistArray.count == 0 {
                    return 0
                } else {
                    if indexPath.row == 0 {
                        return 50.0
                    }
                    return UITableView.automaticDimension
                }
            case 2:
                if self.eventlistArray.count == 0 {
                    return 0
                } else {
                    if indexPath.row == 0 {
                        return 50.0
                    }
                    return UITableView.automaticDimension
                }
            case 3:
                if self.articlesArray.count == 0 {
                    return 0
                } else {
                    if indexPath.row == 0 {
                        return 50.0
                    }
                    return UITableView.automaticDimension
                }
            case 4:
                if self.productsArray.count == 0 {
                    return 0
                } else {
                    if indexPath.row == 0 {
                        return 50.0
                    }
                    return UITableView.automaticDimension
                }
            default:
                return  UITableView.automaticDimension
            }
        }
    }
    
}

// MARK: - API Call
extension TrendingVC {
    
    private func fetchCartItems() {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.getCart(AccessToken: accessToken) { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            let data = success?.array ?? []
                            self.lblCartCount.isHidden = data.count == 0
                            self.lblCartCount.text = "\(data.count)"
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    private func fetchPublicPlaylist() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                PlaylistManager.instance.getPublicPlayList(AccessToken: accessToken, Limit: 20, Offset: 0, completionBlock: { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.playlists?.count ?? 0)")
                                self.publicPlaylistArray = success?.playlists ?? []
                                if AppInstance.instance.isLoginUser {
                                    self.fetchMyEvents()
                                } else {
                                    self.getArticles()
                                }
                                // self.isLoading = false
                                // self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
        }
    }
    
    private func fetchMyEvents() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                EventManager.instance.getEvents(AccessToken: accessToken, limit: 10, offset: 0) { success, sessionError, error in
                    Async.main {
                        self.tableView.stopPullToRefresh()
                        self.getArticles()
                    }
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                let data = success?.data ?? []
                                self.eventlistArray = data.filter { event in
                                    print((event.time ?? 0))
                                    return Int(Date().timeIntervalSince1970) < (event.time ?? 0)
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                if let msg = error?.localizedDescription {
                                    self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                    log.error("error = \(msg)")
                                }
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getProducts() {
        self.productsArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.getProducts(AccessToken: accessToken, priceTo: 0, priceFrom: 0, limit: 10, offSet: 0, category: "") { success, sessionError, error in
                self.tableView.stopPullToRefresh()
                if success != nil{
                    Async.main {
                        self.dismissProgressDialog {
                            self.productsArray = success?.data ?? []
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    private func getArticles() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                ArticlesManager.instance.getArticles(AccessToken: accessToken, limit: 10, offset: "0") { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.articlesArray = success?.data ?? []
                                if AppInstance.instance.isLoginUser {
                                    self.getProducts()
                                }else {
                                    self.isLoading = false
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func addToCart(productId: Int) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.AddToCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("added in cart")
                            self.fetchCartItems()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    func removeFromCart(productId: Int) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.RemoveFromCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil{
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("Removed from cart")
                            self.fetchCartItems()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: SearchTableViewCellDelegate
extension TrendingVC: SearchTableViewCellDelegate {
    
    func searchBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.search.searchVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: ProductsCollectionTableCellDelegate
extension TrendingVC: ProductsCollectionTableCellDelegate {
    
    func cartButtonPressed(_ sender: UIButton, indexPath: IndexPath, products:[Product], cell: ProductsCollectionTableCell) {
        if products[indexPath.row].added_to_cart == 0 {
            if (products[indexPath.row].units ?? 0) < 1 {
                self.view.makeToast("This Product don't have enough of units")
                return
            }
            sender.setTitle("Remove from Cart", for: .normal)
            self.addToCart(productId: products[indexPath.row].id ?? 0)
            cell.object[indexPath.row].added_to_cart = 1
        } else {
            sender.setTitle("Add to Cart", for: .normal)
            self.removeFromCart(productId: products[indexPath.row].id ?? 0)
            cell.object[indexPath.row].added_to_cart = 0
        }
    }
    
    func productDetails(indexPath: IndexPath, products: [Product]) {
        self.view.endEditing(true)
        let vc = R.storyboard.products.productsVC()
        vc?.productID = products[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: EventTableCellDelegate
extension TrendingVC: EventTableCellDelegate {
    
    func selectArticle(_ articleArray: [Blog], indexPath: IndexPath, cell: EventTableCell) {
        self.view.endEditing(true)
        let vc = R.storyboard.settings.articlesDetailsVC()
        vc?.object = articleArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated:true)
    }
    
    func selectEvent(_ eventsArray: [Events], indexPath: IndexPath, cell: EventTableCell) {
        self.view.endEditing(true)
        let vc = R.storyboard.products.eventDetailVC()
        vc?.eventDetailObject = eventsArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: EmptyDataSetSource, EmptyDataSetDelegate
extension TrendingVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Not Found", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Something goes worng please trry again.", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
    
}

// MARK: MPMediaPickerControllerDelegate
extension TrendingVC: MPMediaPickerControllerDelegate {
    
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
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background {
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                if exportSession!.status == AVAssetExportSession.Status.completed {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                    Async.main {
                        self.uploadTrack(TrackData: data)
                    }
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    private func uploadTrack(TrackData: Data) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.file_path ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                vc?.uploadTrackModel = success
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: PlayListSectionOneTableItemDelegate
extension TrendingVC: PlayListSectionOneTableItemDelegate {
    
    func selectPlaylist(_ object: [Playlist], indexPath: IndexPath, cell: PlayListSectionOneTableItem) {
        self.view.endEditing(true)
        let vc = R.storyboard.playlist.showPlaylistDetailsVC()
        vc?.playlistObject = object[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated:true)
    }
    
}
