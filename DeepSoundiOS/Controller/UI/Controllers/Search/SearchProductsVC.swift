//
//  SearchProductsVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 11/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import Async
import DeepSoundSDK

class SearchProductsVC: BaseVC {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
    private let randomString:String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
    var isLoading = true
    var productsArray = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
       
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                if let isTyping = result?.userInfo?[AnyHashable("isTyping")] as? Bool, isTyping {
                    if !self.isLoading {
                        self.productsArray.removeAll()
                        self.isLoading = true
                        self.tableView.reloadData()
                        return
                    }
                }
                if let artistResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass {
                    self.productsArray = artistResult.products ?? []
                    let isHidden = self.productsArray.count == 0
                    self.showImage.isHidden = !isHidden
                    self.showStack.isHidden = !isHidden
                    self.searchBtn.isHidden = !isHidden
                    log.verbose("SongsCount = \(artistResult.products?.count ?? 0)")
                    self.isLoading = false
                    self.tableView.reloadData()
                    return
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }    
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["isRandomSearch": true])
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.productTableItem), forCellReuseIdentifier: R.reuseIdentifier.productTableItem.identifier)
    }
}

extension SearchProductsVC: UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 7
        }else {
            return self.productsArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productTableItem.identifier) as! ProductTableItem
            cell.startSkelting()
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productTableItem.identifier) as! ProductTableItem
            cell.stopSkelting()
            cell.selectionStyle = .none
            cell.indexPath = indexPath
            cell.delegate = self
            let object = self.productsArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.products.productsVC()
            vc?.productID = self.productsArray[indexPath.row].id ?? 0
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}

extension SearchProductsVC: ProductTableItemDelegate {
    func cartButtonAction(_ sender: UIButton, indexPath: IndexPath) {
        self.view.endEditing(true)
        if !isLoading {
            if self.productsArray[indexPath.row].added_to_cart == 0 {
                sender.setTitle("Remove from Cart", for: .normal)
                self.addToCart(productId: self.productsArray[indexPath.row].id ?? 0)
                self.productsArray[indexPath.row].added_to_cart  = 1
            }else{
                sender.setTitle("Add to Cart", for: .normal)
                self.removeFromCart(productId: self.productsArray[indexPath.row].id ?? 0)
                self.productsArray[indexPath.row].added_to_cart = 0
            }
        }
    }
    
    func addToCart(productId:Int){
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.AddToCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast("added in cart")
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
  
    func removeFromCart(productId:Int){
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.RemoveFromCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast("Removed from cart")
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
