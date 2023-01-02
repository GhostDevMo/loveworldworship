//
//  ProductsCollectionTableCell.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 15/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
class ProductsCollectionTableCell: UITableViewCell {

    @IBOutlet weak var colllection: UICollectionView!
    var object = [[String:Any]]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.colllection.delegate = self
        self.colllection.dataSource = self
    }
    var vc: PlaylistVC?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        colllection.register(UINib(nibName: "ProductsCollectionItem", bundle: nil), forCellWithReuseIdentifier: "ProductsCollectionItem")
    }
    func bind(_ object:[[String:Any]]){
        self.object = object
        self.colllection.reloadData()
        
    }
     func addToCart(productId:Int){
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.AddToCart(AccessToken: accessToken, productID: productId) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            self.vc?.view.makeToast("added in cart")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            
                            self.vc?.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            
                            self.vc?.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
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
                       self.vc?.dismissProgressDialog {
                           self.vc?.view.makeToast("Removed from cart")
                       }
                   })
               }else if sessionError != nil{
                   Async.main({
                       self.vc?.dismissProgressDialog {
                           
                           self.vc?.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                           log.error("sessionError = \(sessionError ?? "")")
                       }
                   })
               }else {
                   Async.main({
                       self.vc?.dismissProgressDialog {
                           
                           self.vc?.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                           log.error("error = \(error?.localizedDescription ?? "")")
                       }
                   })
               }
           }
       })
   }
    
    
}
extension ProductsCollectionTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colllection.dequeueReusableCell(withReuseIdentifier: "ProductsCollectionItem", for: indexPath) as? ProductsCollectionItem
        cell?.cell = ProductsCollectionTableCell()
        let object = self.object[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = R.storyboard.products.productsVC()
        vc?.productDetails = self.object[indexPath.row]
//              vc!.artistArray = self.artistArray ?? []
        self.vc?.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 10, height: 320)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
    
    
}


