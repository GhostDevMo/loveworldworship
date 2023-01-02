//
//  CreateProductTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CreateProductTableItem: UITableViewCell {
    @IBOutlet weak var categoryBtn: UIButton!
    
    @IBOutlet weak var addImagesLabel: UILabel!
    @IBOutlet weak var relatedToSongBtn: UIButton!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var totalItemsUnitTextFiled: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    private let imagePickerController = UIImagePickerController()
    var vc:CreateProductVC?
    
    var category:Int? = nil
    var related:Int? = nil
    
    var images = [UIImage]()
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionview.register(CreateProductCollectionItem.nib, forCellWithReuseIdentifier: CreateProductCollectionItem.identifier)
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:[String:Any]){
        if object.isEmpty{
            self.collectionview.isHidden = false
            self.addImagesLabel.isHidden = false
        }else{
            let id:Int? = 0
            let title = object["title"] as? String
            let desc = object["desc"] as? String
            let tags = object["tags"] as? String
            let price = object["formatted_price"] as? String
            let units = object["units"] as? Int
            let catID = object["cat_id"] as? Int
            let relatedSong = object["related_song"] as? [String:Any]
            let songID = relatedSong?["id"] as? Int
            related  = songID
            category  = catID
            self.titleTextField.text = title ?? ""
            self.descriptionTextView.text = desc ?? ""
            self.tagsTextField.text = tags ?? ""
            self.priceTextField.text = price ?? ""
            self.totalItemsUnitTextFiled.text = "\(units ?? 0) "
            for item in AppInstance.instance.userProfile?.data?.latestsongs ?? []{
                if songID ?? 0 == item.id ?? 0{
                    self.relatedToSongBtn.setTitle(item.title ?? "", for: .normal)
                    break
                }
            }
            let category = AppInstance.instance.options["products_categories"] as? [String:Any]
            let catName = category?["\(catID ?? 0)"] as? String
            self.categoryBtn.setTitle(catName ?? "", for: .normal)
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
    
    @IBAction func relatedToSongPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Related to song", message: "", preferredStyle: .actionSheet)
        for item in AppInstance.instance.userProfile?.data?.latestsongs ?? []{
            print("value = \(item.title ?? "")")
            let button = UIAlertAction(title: item.title ?? "", style: .default) { action in
              print("value = \(item.title ?? "")")
                self.relatedToSongBtn.setTitle(item.title ?? "", for: .normal)
                self.related = item.id ?? 0
            }
            alert.addAction(button)
        }
        let close = UIAlertAction(title: "Close", style: .destructive, handler: nil)
        alert.addAction(close)
        self.vc?.present(alert, animated: true, completion: nil)
    }
    @IBAction func categoryPressed(_ sender: Any) {
        let category = AppInstance.instance.options["products_categories"] as? [String:Any]
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .actionSheet)
        for (key,value ) in category ?? [:] {
            let button = UIAlertAction(title: value as? String, style: .default) { action in
              print("value = \(value as? String)")
                print("key = \(key )")
                self.categoryBtn.setTitle(value as! String , for: .normal)
                self.category = Int(key)
            }
            alert.addAction(button)
            
        }
        let close = UIAlertAction(title: "Close", style: .destructive, handler: nil)
        alert.addAction(close)
        self.vc?.present(alert, animated: true, completion: nil)
        
    }
    
    private func SelectImage(){
        let alert = UIAlertController(title: "", message: (NSLocalizedString("Select Source", comment: "")), preferredStyle: .alert)
        let camera = UIAlertAction(title: (NSLocalizedString("Camera", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.vc?.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: (NSLocalizedString("Gallery", comment: "")), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.vc?.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
    }
    
}
extension CreateProductTableItem:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateProductCollectionItem.identifier, for: indexPath) as? CreateProductCollectionItem
            cell?.imageShow.image = R.image.addImagepLace()
            cell?.bind(section: indexPath.section, indexpath: indexPath.row)
            return cell!
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateProductCollectionItem.identifier, for: indexPath) as? CreateProductCollectionItem
            cell?.imageShow.image = self.images[indexPath.row]
            cell?.bind(section: indexPath.section, indexpath: indexPath.row)
            cell?.cell = CreateProductTableItem()
            return cell!
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
        return CGSize(width: 130, height: 100)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
    }
}
extension  CreateProductTableItem:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.images.append(image)
        self.collectionview.reloadData()
        self.vc?.dismiss(animated: true, completion: nil)
    }
}
