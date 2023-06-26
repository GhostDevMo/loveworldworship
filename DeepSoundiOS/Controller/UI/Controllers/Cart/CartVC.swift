//
//  CartVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
class CartVC: BaseVC {

//    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    
    var cartArray = [[String:Any]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionview.register(UINib(nibName: "CartCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CartCollectionCell")
//        self.navigationController?.navigationBar.isHidden = true
        tableview.register(UINib(nibName: "CartTableItem", bundle: nil), forCellReuseIdentifier: "CartTableItem")
        self.fetchCartItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func fetchCartItems(){
        self.showProgressDialog(text: "Loading...")
        self.cartArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.getCart(AccessToken: accessToken) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.cartArray = success ?? []
                            self.tableview.reloadData()
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
    func removeFromCart(productId:Int,index:Int){
        self.showProgressDialog(text: "Loading...")
       let accessToken = AppInstance.instance.accessToken ?? ""
       Async.background({
           ProductManager.instance.RemoveFromCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
               if success != nil{
                   Async.main({
                       self.dismissProgressDialog {
                        self.cartArray.remove(at: index)
                           self.view.makeToast("Removed from cart")
                        self.tableview.reloadData()
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
extension CartVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "CartTableItem", for: indexPath) as! CartTableItem
            cell.vc = self
    
    
            let object = self.cartArray[indexPath.row]
            cell.bind(object, index: indexPath.row)
    
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
}
//extension CartVC:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.cartArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "CartCollectionCell", for: indexPath) as! CartCollectionCell
//        cell.vc = self
//
//
//        let object = self.cartArray[indexPath.row]
//        cell.bind(object, index: indexPath.row)
//
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
//                let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
//                let size:CGFloat = (collectionview.frame.size.width - space) / 2.0
//                return CGSize(width: size, height: size)
//    }
//
//
//
//}
