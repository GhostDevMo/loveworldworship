//
//  productHeadrItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import ImageSlideshow
import SDWebImage
import Alamofire


class productHeadrItem: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageSlide: ImageSlideshow!
    
    @IBOutlet weak var backView: UIView!
    var imageSource = [SDWebImageSource]()
    var vc : ProductsVC?
    var userID:Int? = 0
    var object = [String:Any]()
    override func awakeFromNib() {
        super.awakeFromNib()
        imageSlide.contentScaleMode = UIViewContentMode.scaleAspectFill
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backView.backgroundColor = .lightMainColor

    }
    func bind(_ object:[String:Any]){
        self.object = object
       let userID = object["user_id"] as?  Int
        let title = object["title"] as? String
        let catID = object["cat_id"] as? Int
        let images = object["images"] as! [[String:Any]]
        let price = object["formatted_price"] as? String
        let categories = AppInstance.instance.options["products_categories"] as? [String:Any]
        let categoryName = categories?["\(catID ?? 0)"] as? String
        self.typeLabel.text = categoryName ?? ""
        self.priceLabel.text = "$\(price ?? "")"
        self.userID = userID ?? 0

        images.forEach { it in
            let image = it["image"] as? String
            self.imageSource.append(SDWebImageSource    (urlString: image ?? "")!)
          
        }
        self.imageSlide.setImageInputs(self.imageSource ?? [])
    }
    @IBAction func morePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Product", message: "", preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "Share", style: .default) { action in
            log.verbose("Share")
        }
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            log.verbose("Copy")
        }
        let edit = UIAlertAction(title: "Edit", style: .default) { action in
            log.verbose("Edit")
            let vc = R.storyboard.products.createProductVC()
            vc?.productDetails = self.object ?? [:]
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        if self.userID ?? 0 == AppInstance.instance.userId ?? 0{
            alert.addAction(edit)
        }
        alert.addAction(share)
        alert.addAction(copy)
        alert.addAction(cancel)
        self.vc?.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.vc?.navigationController?.popViewController(animated: true)
    }
}
