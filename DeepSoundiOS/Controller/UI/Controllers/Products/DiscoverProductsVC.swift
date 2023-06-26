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
import FittedSheets
class DiscoverProductsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    private var productsArray = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(ProductTableItem.nib, forCellReuseIdentifier: ProductTableItem.identifier)
        self.getProducts(priceMin: 0, priceMax: 0, category: "")
    }
    @IBAction func addProduct(_ sender: Any) {
        let vc = R.storyboard.products.createProductVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func filterPressed(_ sender: Any) {
       let vc  =  R.storyboard.products.filterProductsVC()!
        vc.delegate = self
        let controller = SheetViewController(controller: vc, sizes: [.fixed(420), .fullscreen])
        self.present(controller, animated: true, completion: nil)
    }
    private func getProducts(priceMin:Int,priceMax:Int,category:String){
        self.showProgressDialog(text: "Loading...")
        self.productsArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.getProducts(AccessToken: accessToken, priceTo: priceMin, priceFrom: priceMax, category: category) { success, sessionError, error in
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
        return self.productsArray.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableItem.identifier) as! ProductTableItem
        cell.selectionStyle = .none
        cell.vc = self
        let object = self.productsArray[indexPath.row]
        cell.bind(object)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.products.productsVC()
        vc?.productDetails = self.productsArray[indexPath.row]
//              vc!.artistArray = self.artistArray ?? []
        self.navigationController?.pushViewController(vc!, animated: true)
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}
extension DiscoverProductsVC:FilterProductDelegate{
    func filterProducts(categoryID: Int, priceMin: String, PriceMax: String) {
        self.getProducts(priceMin: Int(priceMin) ?? 0, priceMax: Int(PriceMax) ?? 0, category: String(categoryID))
    }
}
