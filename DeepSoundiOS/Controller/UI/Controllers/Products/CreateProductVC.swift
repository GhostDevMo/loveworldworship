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
    
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var addImagesLabel: UILabel!
    @IBOutlet weak var relatedToSongTF: UITextField!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var totalItemsUnitTextFiled: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var productDetails: Product?
    private let imagePickerController = UIImagePickerController()
    var category:Int?
    var related:Int?
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeConfigure()
        self.bind(self.productDetails)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func relatedToSongPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Related to song", message: "", preferredStyle: .actionSheet)
        for item in AppInstance.instance.userProfile?.data?.latestsongs?.first ?? []{
            print("value = \(item.title ?? "")")
            let button = UIAlertAction(title: item.title ?? "", style: .default) { action in
                print("value = \(item.title ?? "")")
                self.relatedToSongTF.text = item.title
                self.related = item.id ?? 0
            }
            alert.addAction(button)
        }
        let close = UIAlertAction(title: "Close", style: .destructive, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        let category = AppInstance.instance.optionsData?.products_categories
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .actionSheet)
        for (key,value) in category?.dictionaryValue ?? [:] {
            let button = UIAlertAction(title: value, style: .default) { action in
                print("value = \(value)")
                print("key = \(key )")
                self.categoryTF.text = value
                self.category = Int(key)
            }
            alert.addAction(button)
            
        }
        let close = UIAlertAction(title: "Close", style: .destructive, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        if productDetails != nil {
            if self.titleTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter title")
            }else if self.descriptionTextView.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Description")
            }else if self.tagsTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Tags")
            }else if self.priceTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter price")
            }else if self.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if self.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if self.related == nil{
                self.view.makeToast("Please select related songs")
            }else if self.category == nil{
                self.view.makeToast("Please select category")
            }else if self.images.count == 0 {
                self.view.makeToast("Please select alteast one image")
            }else{
                self.createProduct(title: self.titleTextField.text ?? "", description: self.descriptionTextView.text ?? "", tags: self.tagsTextField.text ?? "", price: self.priceTextField.text ?? "", unit: self.totalItemsUnitTextFiled.text ?? "", related: self.related ?? 0, category: self.category ?? 0, Media: self.images)
                
            }
        }else{
            if self.titleTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter title")
            }else if self.descriptionTextView.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Description")
            }else if self.tagsTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter Tags")
            }else if self.priceTextField.text?.isEmpty ?? false{
                self.view.makeToast("Please enter price")
            }else if self.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if self.totalItemsUnitTextFiled.text?.isEmpty ?? false{
                self.view.makeToast("Please enter total no of units")
            }else if self.related == nil{
                self.view.makeToast("Please select related songs")
            }else if self.category == nil{
                self.view.makeToast("Please select category")
            }else{
                let id = productDetails?.id
                self.updateProduct(id:id ?? 0,title: self.titleTextField.text ?? "", description: self.descriptionTextView.text ?? "", tags: self.tagsTextField.text ?? "", price: self.priceTextField.text ?? "", unit: self.totalItemsUnitTextFiled.text ?? "", related: self.related ?? 0, category: self.category ?? 0)
            }
        }
    }
    
    func bind(_ object: Product?) {
        if object == nil {
            self.collectionview.isHidden = false
            self.addImagesLabel.isHidden = false
        }else{
            related = object?.related_song?.dataValue?.id ?? 0
            category = object?.cat_id ?? 0
            self.titleTextField.text = object?.title
            self.descriptionTextView.text = object?.desc
            self.tagsTextField.text = object?.tags
            self.priceTextField.text = object?.formatted_price
            self.totalItemsUnitTextFiled.text = "\(object?.units ?? 0) "
            for item in AppInstance.instance.userProfile?.data?.latestsongs?.first ?? [] {
                if object?.related_song?.dataValue?.id ?? 0 == item.id ?? 0{
                    self.relatedToSongTF.text = item.title
                    break
                }
            }
            let category = AppInstance.instance.optionsData?.products_categories
            let catName = category?.dictionaryValue?["\(object?.cat_id ?? 0)"] as? String
            self.categoryTF.text = catName
            self.collectionview.isHidden = true
            self.addImagesLabel.isHidden = true
            //            let images = productDetails["images"] as? [[String:Any]]
            //            for item in images ?? []{
            //                let image = item["image"] as? String
            //                let url = URL(string: image ?? "")
            //                DispatchQueue.global().async {
            //                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            //                    DispatchQueue.main.async {
            //                        cell?.images.append(UIImage(data: data ?? Data()) ?? UIImage())
            //                    }
            //                }
            //
            //            }
        }
    }
    
    func initializeConfigure() {
        self.collectionview.register(UINib(resource: R.nib.createProductCollectionItem), forCellWithReuseIdentifier: R.reuseIdentifier.createProductCollectionItem.identifier)
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
    }
    
    private func SelectImage(){
        let alert = UIAlertController(title: "", message: (NSLocalizedString("Select Source", comment: "")), preferredStyle: .alert)
        let camera = UIAlertAction(title: (NSLocalizedString("Camera", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: (NSLocalizedString("Gallery", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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


extension CreateProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.images.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createProductCollectionItem.identifier, for: indexPath) as! CreateProductCollectionItem
            cell.imageShow.image = R.image.addImagepLace()
            cell.cancelBtn.isHidden = true
            cell.selectedIndexPath = indexPath
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createProductCollectionItem.identifier, for: indexPath) as! CreateProductCollectionItem
            cell.imageShow.image = self.images[indexPath.row]
            cell.cancelBtn.isHidden = false
            cell.selectedIndexPath = indexPath
            cell.delegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.SelectImage()
        default:
            log.verbose("Nothing Pressed")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 125)
        
    }
}

extension CreateProductVC: ImageRemoveButtonDelegate {
    func removeButton(_ indexPath: IndexPath, _ sender: UIButton) {
        self.images.remove(at: indexPath.row)
        self.collectionview.reloadData()
    }
}

extension CreateProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.images.append(image)
            self.collectionview.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
