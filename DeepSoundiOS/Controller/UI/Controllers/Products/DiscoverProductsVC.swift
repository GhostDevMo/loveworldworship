//
//  DiscoverProductsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class DiscoverProductsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var lastCount = 0
    var lastOffSet = 0
    private var productsArray = [Product]()
    var isLoading = true
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.addButton.addShadow(offset: .init(width: 0, height: 4))
        tableView.register(UINib(resource: R.nib.productTableItem), forCellReuseIdentifier: R.reuseIdentifier.productTableItem.identifier)
        self.getProducts(priceMin: 0, priceMax: 0, category: "")
        self.tableView.tableFooterView = activityIndicator
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.addPullToRefresh {
            self.lastCount = 0
            self.lastOffSet = 0
            self.isLoading = true
            self.productsArray.removeAll()
            self.tableView.reloadData()
            self.getProducts(priceMin: 0, priceMax: 0, category: self.selectedCategory)
        }
    }
    
    @IBAction func addProduct(_ sender: UIButton) {
        let vc = R.storyboard.products.createProductVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func filterPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.products.filterProductsVC() {
            newVC.modalPresentationStyle = .custom
            newVC.transitioningDelegate = self
            newVC.delegate = self
            newVC.categoryID = selectedCategory
            self.present(newVC, animated: true)
        }
    }
    
    private func getProducts(priceMin:Int, priceMax:Int, category:String) {
        self.productsArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.getProducts(AccessToken: accessToken, priceTo: priceMin, priceFrom: priceMax, limit: 10, offSet: self.lastOffSet, category: category) { success, sessionError, error in
                Async.main {
                    self.tableView.stopPullToRefresh()
                }
                if success != nil {
                    Async.main({
                        self.dismissProgressDialog {
                            let data = success?.data ?? []
                            if self.lastOffSet == 0 {
                                self.productsArray = data
                            }else {
                                self.productsArray.append(contentsOf: data)
                            }
                            self.lastCount = data.count
                            self.lastOffSet = data.last?.id ?? 0
                            self.isLoading = false
                            self.tableView.reloadData()
                            self.tableView.tableFooterView?.isHidden=true
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
            }
        })
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

extension DiscoverProductsVC: UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout{
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.productsArray.count - 1) {
            if !(self.lastCount < 10) {
                DispatchQueue.main.async {
                    self.tableView.tableFooterView?.isHidden = false
                    self.activityIndicator.startAnimating()
                    self.getProducts(priceMin: 0, priceMax: 0, category: self.selectedCategory)
                }
            }
        }
    }
}

extension DiscoverProductsVC: ProductTableItemDelegate {
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
}

extension DiscoverProductsVC:FilterProductDelegate {
    func filterProducts(categoryID: String, priceMin: String, PriceMax: String) {
        self.selectedCategory = categoryID
        self.isLoading = true
        self.productsArray.removeAll()
        self.tableView.reloadData()
        self.getProducts(priceMin: Int(priceMin) ?? 0, priceMax: Int(PriceMax) ?? 0, category: String(categoryID))
    }
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension DiscoverProductsVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
