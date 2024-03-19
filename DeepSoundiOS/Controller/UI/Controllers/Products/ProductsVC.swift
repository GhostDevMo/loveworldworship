//
//  ProductsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import ExpyTableView
import SwiftEventBus
import DeepSoundSDK
import Async

class ProductsVC: BaseVC {
    
    @IBOutlet weak var table: ExpyTableView!
    
    private var isLoading = true
    var productID:Int = 0
    var productDetails: Product?
    var reviewsArray: [ReviewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(UINib(resource: R.nib.productsRelatedItem), forCellReuseIdentifier: R.reuseIdentifier.productsRelatedItem.identifier)
        table.register(UINib(resource: R.nib.productHeaderItem), forCellReuseIdentifier: R.reuseIdentifier.productHeaderItem.identifier)
        table.register(UINib(resource: R.nib.productsSectionItem), forCellReuseIdentifier: R.reuseIdentifier.productsSectionItem.identifier)
        table.register(UINib(resource: R.nib.expandableTextTableItem), forCellReuseIdentifier: R.reuseIdentifier.expandableTextTableItem.identifier)
        table.register(UINib(resource: R.nib.artistTableCell), forCellReuseIdentifier: R.reuseIdentifier.artistTableCell.identifier)
        table.register(UINib(resource: R.nib.expandableReviewTableItem), forCellReuseIdentifier: R.reuseIdentifier.expandableReviewTableItem.identifier)
        self.fetchProductByID()
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.popups.playlistPopUpVC()
        newVC?.isProduct = true
        newVC?.productDelegate = self
        self.present(newVC!, animated: true)
    }
}

//MARK: - API Services -
extension ProductsVC {
    
    private func fetchProductByID() {
        ProductManager.instance.getProductByID(productID: self.productID) { success, sessionError, error in
            Async.main {
                self.dismissProgressDialog {
                    if let error = error {
                        self.view.makeToast(error.localizedDescription)
                        log.error("error = \(error.localizedDescription)")
                        return
                    }
                    
                    if let success = success {
                        self.productDetails = success
                        self.fetchProductReviews()
                    }
                    
                    if let sessionError = sessionError {
                        log.error("sessionError = \(sessionError)")
                        self.view.makeToast(sessionError, duration: 1.0)
                    }
                }
            }
        }
    }
    
    private func fetchProductReviews() {
        ProductManager.instance.getProductReviews(productID: self.productID) { success, sessionError, error in
            Async.main {
                self.dismissProgressDialog {
                    if let error = error {
                        self.view.makeToast(error.localizedDescription)
                        log.error("error = \(error.localizedDescription)")
                        return
                    }
                    
                    if let success = success {
                        self.reviewsArray = success.data
                        self.isLoading = false
                        self.table.reloadData()
                    }
                    
                    if let sessionError = sessionError {
                        if sessionError.error != nil {
                            log.error("sessionError = \(sessionError.error ?? "")")
                            self.view.makeToast(sessionError.error, duration: 1.0)
                        }else {
                            log.error("sessionError = \(sessionError.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError.errors?.error_text, duration: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    private func followUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
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
    
    private func unFollowUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString(("User has been unfollowed"), comment: ""))
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
    
    private func changeQTYFromCart(productId: Int, qty: Int) {
        Async.background({
            ProductManager.instance.changeQTYProductAPI(qty: qty, productID: productId) { success, sessionError, error in
                if success != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("Change Qty Successfully!.")
                            SwiftEventBus.postToMainThread("ReloadProductData")
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
    
    private func addToCart(productId: Int, qty: Int) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.AddToCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("added in cart")
                            self.changeQTYFromCart(productId: productId, qty: qty)
                        }
                    })
                }else if sessionError != nil {
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
    
    private func removeFromCart(productId: Int) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.RemoveFromCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("Removed from cart")
                            SwiftEventBus.postToMainThread("ReloadProductData")
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
}

extension ProductsVC:ExpyTableViewDataSource,ExpyTableViewDelegate{
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        print("section = \(section)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 1+self.reviewsArray.count
        case 4:
            return 2
        case 5:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productsSectionItem.identifier) as! ProductsSectionItem
        cell.selectionStyle = .none
        isLoading ? cell.startSkelting() : cell.stopSkelting()
        switch section {
        case 2:
            cell.title.text = "Description"
        case 3:
            cell.title.text = "Reviews"
        case 4:
            cell.title.text = "Tag(s)"
        case 5:
            cell.title.text = "Profile"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        switch section {
        case 0:
            return false
        case 1:
            return false
        case 2:
            return true
        case 3:
            return true
        case 4:
            return true
        case 5:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productHeaderItem.identifier) as! ProductHeaderItem
                cell.selectionStyle = .none
                cell.startSkelting()
                cell.isAnimation(true)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productsRelatedItem.identifier) as! ProductsRelatedItem
                cell.backView.backgroundColor = .white
                cell.startSkelting()
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableTextTableItem.identifier) as! ExpandableTextTableItem
                cell.selectionStyle = .none
                cell.startSkelting()
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableReviewTableItem.identifier) as! ExpandableReviewTableItem
                cell.selectionStyle = .none
                cell.startSkelting()
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableTextTableItem.identifier) as! ExpandableTextTableItem
                cell.selectionStyle = .none
                cell.startSkelting()
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier) as! ArtistTableCell
                cell.selectionStyle = .none
                cell.startSkelting()
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productHeaderItem.identifier) as! ProductHeaderItem
                cell.stopSkelting()
                cell.isAnimation(false)
                cell.selectionStyle = .none
                cell.delegate = self
                if let productDetails = productDetails {
                    cell.bind(productDetails)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productsRelatedItem.identifier) as! ProductsRelatedItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.backView.backgroundColor = .mainColor.withAlphaComponent(0.5)
                let relatedSong = self.productDetails?.related_song?.dataValue?.title
                cell.bind(relatedSong ?? "")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableTextTableItem.identifier) as! ExpandableTextTableItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                let desc = self.productDetails?.desc
                cell.bind(desc ?? "")
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableReviewTableItem.identifier) as! ExpandableReviewTableItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                let object = reviewsArray[indexPath.row-1]
                cell.bind(object)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandableTextTableItem.identifier) as! ExpandableTextTableItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                let tags = self.productDetails?.tags
                cell.bind(tags ?? "")
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier) as! ArtistTableCell
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.delegate = self
                cell.indexPath = indexPath.row
                if let object = self.productDetails?.user_data?.dataValue {
                    cell.bind(object)
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            if indexPath.section == 1 {
                var songsArray: [Song] = []
                if let object = self.productDetails?.related_song?.dataValue {
                    if object.audio_id != popupContentController?.musicObject?.audio_id  {
                        AppInstance.instance.AlreadyPlayed = false
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                    }
                    songsArray.append(object)
                    popupContentController?.popupItem.title = object.publisher?.name ?? ""
                    popupContentController?.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
                    popupContentController?.popupBar.progressViewStyle = .bottom
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: URL(string: object.thumbnail ?? ""))
                    popupContentController?.popupItem.image = imageView.image
                    AppInstance.instance.popupPlayPauseSong = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                    }
                    self.addToRecentlyWatched(trackId: object.id ?? 0)
                    self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                        popupContentController?.musicObject = object
                        popupContentController?.musicArray = songsArray
                        popupContentController?.currentAudioIndex = 0//indexPath.row
                        popupContentController?.delegate = self
                        popupContentController?.setup()
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProductsVC: followUserDelegate {
    func followUser(_ index: Int, _ sender: UIButton) {
        if !isLoading {
            if AppInstance.instance.getUserSession() {
                let userId = self.productDetails?.user_data?.dataValue?.id ?? 0
                if userId == AppInstance.instance.userId {
                    self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
                    return
                }
                if sender.currentTitle == "Follow" {
                    sender.setTitle("Following", for: .normal)
                    sender.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
                    sender.setTitleColor(.mainColor, for: .normal)
                    self.followUser(userId: userId)
                }else {
                    sender.setTitle("Follow", for: .normal)
                    sender.backgroundColor = .mainColor
                    sender.setTitleColor(.white, for: .normal)
                    self.unFollowUser(userId: userId)
                }
            }else{
                let vc = R.storyboard.popups.loginPopupVC()
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
}

extension ProductsVC: ProductDetailsDelegate {
    func shareBtn(_ sender: UIButton) {
        if !isLoading {
            self.view.endEditing(true)
            self.share(shareString: self.productDetails?.url)
        }
    }
    
    private func share(shareString:String?) {
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func copyBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        UIPasteboard.general.string = self.productDetails?.url ?? ""
        self.view.makeToast("Text copied to clipboard")
    }
    
    func addToCartBtn(_ sender: UIButton, qty: Int) {
        if !isLoading {
            if self.productDetails?.added_to_cart == 1 {
                sender.setTitle("Add to Cart", for: .normal)
                self.removeFromCart(productId: self.productDetails?.id ?? 0)
                self.productDetails?.added_to_cart = 0
            }else {
                if let id = self.productDetails?.id {
                    if (self.productDetails?.units ?? 0) < 1 {
                        self.view.makeToast("This Product don't have enough of units")
                        return
                    }
                    sender.setTitle("Remove from Cart", for: .normal)
                    self.addToCart(productId: id, qty: qty)
                    self.productDetails?.added_to_cart = 1
                }
            }
        }
    }
}

extension ProductsVC: BottomSheetDelegate {
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
