//
//  CartVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import RswiftResources
import SwiftEventBus
import DeepSoundSDK
import Toast_Swift

class CartVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    
    // MARK: - Properties
    
    var addressArray: [AddressData] = []
    var cartArray: [CartModel] = []
    var selectedAddressID: Int = 0
    var selectedProductIndex: IndexPath = []
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initConfigure()
    }
    
    // MARK: - Selectors
    
    @IBAction func buyBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.cartArray.count == 0 {
            self.view.makeToast("Your Cart is Empty!.")
            return
        }
        if self.selectedAddressID == 0 {
            self.view.makeToast("Please Select Address")
            return
        }
        self.buyProductAPI()
    }
    
    // MARK: - Helper Functions
    
    func initConfigure() {
        if #available(iOS 15.0, *) {
            self.tableView.isPrefetchingEnabled = false
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.cartTableItem), forCellReuseIdentifier: R.reuseIdentifier.cartTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.sectionHeaderTableItem), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.addressTableItem), forCellReuseIdentifier: R.reuseIdentifier.addressTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.addNewAddressCell), forCellReuseIdentifier: R.reuseIdentifier.addNewAddressCell.identifier)
        self.fetchCartItems()
        self.tableView.addPullToRefresh {
            self.addressArray.removeAll()
            self.cartArray.removeAll()
            self.tableView.reloadData()
            self.selectedAddressID = 0
            self.fetchCartItems()
        }
        SwiftEventBus.onMainThread(self, name: "ReloadProductData") { result in
            var price = 0
            for i in self.cartArray {
                let pri = (i.product.price ?? 0) * i.units
                price += pri
            }
            self.lblTotal.isHidden = false
            self.lblTotal.text = "$\(price)"
        }
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension CartVC {
    
    private func fetchCartItems() {
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.getCart(AccessToken: accessToken) { success, sessionError, error in
                Async.main {
                    self.tableView.stopPullToRefresh()
                }
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.cartArray = success?.array ?? []
                            var price = 0
                            for i in self.cartArray {
                                let pri = (i.product.price ?? 0) * i.units
                                price += pri
                            }
                            self.lblTotal.isHidden = false
                            self.lblTotal.text = "$\(price)"
                            self.getAddress()
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
    
    func removeFromCart(productId: Int, index: Int) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProductManager.instance.RemoveFromCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                Async.main {
                    self.tableView.stopPullToRefresh()
                }
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.cartArray.remove(at: index)
                            self.view.makeToast("Removed from cart")
                            self.tableView.reloadData()
                            SwiftEventBus.postToMainThread("ReloadProductData")
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
    
    func changeQTYFromCart(productId: Int, qty: Int) {
        Async.background {
            ProductManager.instance.changeQTYProductAPI(qty: qty, productID: productId) { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("Change Qty Successfully!.")
                            SwiftEventBus.postToMainThread("ReloadProductData")
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
    
    private func getAddress() {
        if Connectivity.isConnectedToNetwork() {
            self.addressArray = []
            let access_token = AppInstance.instance.accessToken ?? ""
            Async.background {
                AddressManger.instance.getAddress(access_token: access_token, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.addressArray = success?.data ?? []
                                self.tableView.reloadData()
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
    
    private func buyProductAPI() {
        self.showProgressDialog(text: "Loading...")
        ProductManager.instance.buyProduct(address_id: self.selectedAddressID) { success, sessionError, error in
            Async.main {
                self.dismissProgressDialog {
                    if let error = error {
                        self.view.makeToast(error.localizedDescription)
                        log.error("error = \(error.localizedDescription)")
                        return
                    }
                    if let success = success {
                        self.view.makeToast(success, duration: 1.0)
                        SwiftEventBus.postToMainThread("ReloadProductData")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    if let sessionError = sessionError {
                        log.error("sessionError = \(sessionError)")
                        self.view.makeToast(sessionError, duration: 1.0)
                    }
                }
            }
        }
    }
    
}

// MARK: TableView Cell
extension CartVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.cartArray.count != 0 {
                return self.cartArray.count + 1
            }
            return 2
        case 1:
            if self.addressArray.count != 0 {
                return self.addressArray.count + 2
            }
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.btnSeeAll.isHidden = true
                cell.titleLabel.text = "Carts"
                cell.selectionStyle = .none
                return cell
            } else {
                if self.cartArray.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addNewAddressCell.identifier, for: indexPath) as! AddNewAddressCell
                    cell.selectionStyle = .none
                    cell.lblTitle.text = "Your Cart is empty!."
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cartTableItem.identifier, for: indexPath) as! CartTableItem
                    let object = self.cartArray[indexPath.row-1]
                    cell.indexPath = indexPath
                    cell.qtyLbl.text = "QTY : \(object.units)"
                    cell.bind(object.product, index: indexPath.row-1)
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }
            }
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as! SectionHeaderTableItem
                cell.stopSkelting()
                cell.selectionStyle = .none
                cell.btnSeeAll.isHidden = true
                cell.titleLabel.text = "Shipping Details"
                cell.selectionStyle = .none
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addNewAddressCell.identifier, for: indexPath) as! AddNewAddressCell
                cell.lblTitle.text = "Add New Address"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addressTableItem.identifier, for: indexPath) as! AddressTableItem
                cell.indexPath = indexPath
                cell.delegate = self
                let object = self.addressArray[indexPath.row-2]
                cell.bind(object)
                let image = self.selectedAddressID == (object.id ?? 0) ? R.image.icon_checkmark() : R.image.icon_uncheckmark()
                cell.btnSelect.setImage(image, for: .normal)
                cell.selectionStyle = .none
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if cartArray.count != 0 {
                self.view.endEditing(true)
                let vc = R.storyboard.products.productsVC()
                vc?.productID = cartArray[indexPath.row-1].product_id
                self.navigationController?.pushViewController(vc!, animated: true)
                return
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                self.view.endEditing(true)
                guard let newVC = R.storyboard.settings.myAddressesVC() else {return}
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
}

// MARK: CartItemDelegate
extension CartVC: CartItemDelegate {
    
    func removeItem(_ indexPath: IndexPath, _ sender: UIButton) {
        let id = self.cartArray[indexPath.row-1].product_id
        self.removeFromCart(productId: id, index: indexPath.row-1)
    }
    
    func qtyItem(_ indexPath: IndexPath, _ sender: UIButton) {
        self.selectedProductIndex = indexPath
        guard let newVC = R.storyboard.popups.productQtyPopupVC() else {return}
        newVC.delegate = self
        self.present(newVC, animated: true)
    }
    
}

// MARK: ProductQtyPopupDelegate
extension CartVC: ProductQtyPopupDelegate {
    
    func selectedQTY(_ selected: Int) {
        let id = self.cartArray[self.selectedProductIndex.row-1].product_id
        changeQTYFromCart(productId: id, qty: selected)
        self.cartArray[self.selectedProductIndex.row-1].units = selected
        self.tableView.reloadData()
    }
    
}

// MARK: MyAddressCellDelegate
extension CartVC: MyAddressCellDelegate {
    
    func selectAddressButtonTap(indexPath: IndexPath) {
        self.selectedAddressID = self.addressArray[indexPath.row-2].id ?? 0
        self.tableView.reloadData()
    }
    
}
