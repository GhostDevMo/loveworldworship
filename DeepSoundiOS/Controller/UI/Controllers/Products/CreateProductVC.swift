//
//  CreateProductVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class CreateProductVC: BaseVC {
    
    @IBOutlet weak var table: UITableView!
    var productDetails = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "CreateProductTableItem", bundle: nil), forCellReuseIdentifier: "CreateProductTableItem")
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if productDetails.isEmpty{
            let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateProductTableItem
            if cell?.titleTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter title")
            }else if cell?.descriptionTextView.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Description")
            }else if cell?.tagsTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Tags")
            }else if cell?.priceTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter price")
            }else if cell?.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if cell?.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if cell?.related == nil{
                self.view.makeToast("Please select related songs")
            }else if cell?.category == nil{
                self.view.makeToast("Please select category")
            }else if cell?.images.count == 0 {
                self.view.makeToast("Please select alteast one image")
            }else{
                self.createProduct(title: cell?.titleTextField.text ?? "", description: cell?.descriptionTextView.text ?? "", tags: cell?.tagsTextField.text ?? "", price: cell?.priceTextField.text ?? "", unit: cell?.totalItemsUnitTextFiled.text ?? "", related: cell?.related ?? 0, category: cell?.category ?? 0, Media: cell?.images ?? [])
                
            }
        }else{
            let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateProductTableItem
            if cell?.titleTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter title")
            }else if cell?.descriptionTextView.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Description")
            }else if cell?.tagsTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Tags")
            }else if cell?.priceTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter price")
            }else if cell?.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if cell?.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if cell?.related == nil{
                self.view.makeToast("Please select related songs")
            }else if cell?.category == nil{
                self.view.makeToast("Please select category")
            }else{
                let id = productDetails["id"] as? Int
                self.updateProduct(id:id ?? 0,title: cell?.titleTextField.text ?? "", description: cell?.descriptionTextView.text ?? "", tags: cell?.tagsTextField.text ?? "", price: cell?.priceTextField.text ?? "", unit: cell?.totalItemsUnitTextFiled.text ?? "", related: cell?.related ?? 0, category: cell?.category ?? 0)
                
            }
        }
        
    }
    func createProduct(title:String,description:String,tags:String,price:String,unit:String,related:Int,category:Int,Media:[UIImage]){
        let accessToken = AppInstance.instance.accessToken ?? ""
        var dataArr = [Data]()
        
        for item in Media{
            dataArr.append(item.pngData() ?? Data())
        }
        self.showProgressDialog(text: "Loading...")
        Async.background({
            ProductManager.instance.createProduct(AccesToken: accessToken, title:title , desc: description, tags: tags, price: price, unit: unit, related: related, category: category, mediaData: dataArr) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let message = success?["message"] as? String
                            self.view.makeToast(message ?? "")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let error = sessionError?["error"] as? String
                            
                            self.view.makeToast((NSLocalizedString(error ?? "", comment: "")))
                            log.error("sessionError = \(error  ?? "")")
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
    func updateProduct(id:Int,title:String,description:String,tags:String,price:String,unit:String,related:Int,category:Int){
        let accessToken = AppInstance.instance.accessToken ?? ""
        var dataArr = [Data]()
        
        self.showProgressDialog(text: "Loading...")
        Async.background({
            
            ProductManager.instance.updateProduct(id:id,AccesToken: accessToken, title:title , desc: description, tags: tags, price: price, unit: unit, related: related, category: category) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let message = success?["message"] as? String
                            self.view.makeToast(message ?? "")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            let error = sessionError?["error"] as? String
                            
                            self.view.makeToast((NSLocalizedString(error ?? "", comment: "")))
                            log.error("sessionError = \(error  ?? "")")
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
extension CreateProductVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "CreateProductTableItem") as! CreateProductTableItem
        cell.vc = self
        cell.bind(self.productDetails)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

