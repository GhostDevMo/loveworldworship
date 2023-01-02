//
//  ProductsCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 15/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class ProductsCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var id:Int? = 0
    var cartStatus:Int? = 0
    var cell:ProductsCollectionTableCell?
    var vc:DiscoverProductsVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addToCartButton.backgroundColor = .ButtonColor
        price.textColor = .ButtonColor
    }
    func bind(_ object:[String:Any]){
        let id = object["id"] as? Int
        let name = object["title"] as? String
        let price = object["formatted_price"] as? String
        let images = object["images"] as? [[String:Any]]
        let imageObject = images?[0] as? [String:Any]
        let catID = object["cat_id"] as? Int
        let image = imageObject?["image"] as? String
        let addToCartStatus = object["added_to_cart"] as? Int
        self.name.text = name ?? ""
        self.price.text = "$\(price ?? "")"
        self.id = id ?? 0
        self.cartStatus = addToCartStatus ?? 0
        
        
        let url = URL.init(string:image ?? "")
        self.image.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        let categories = AppInstance.instance.options["products_categories"] as? [String:Any]
        let categoryName = categories?["\(catID ?? 0)"] as? String
        self.type.text = categoryName ?? ""
        
        if self.cartStatus == 0{
            self.addToCartButton.setTitle("Add to Cart", for: .normal)
            self.cartStatus = 0
        }else{
            self.addToCartButton.setTitle("Remove from Cart", for: .normal)
            self.cartStatus = 1
        }
    }
    
    @IBAction func addToCartPressed(_ sender: Any) {
        if  vc != nil{
            if self.cartStatus  == 0{
                self.addToCartButton.setTitle("Remove from Cart", for: .normal)
                self.vc?.addToCart(productId: self.id ?? 0)
                self.cartStatus  = 1
    //            self.cell?.colllection.reloadData()
            }else{
                self.addToCartButton.setTitle("Add to Cart", for: .normal)
                self.vc?.removeFromCart(productId: self.id ?? 0)
                self.cartStatus  = 0
    //            self.cell?.colllection.reloadData()
            }
        }else{
            if self.cartStatus  == 0{
                self.addToCartButton.setTitle("Remove from Cart", for: .normal)
                self.cell?.addToCart(productId: self.id ?? 0)
                self.cartStatus  = 1
    //            self.cell?.colllection.reloadData()
            }else{
                self.addToCartButton.setTitle("Add to Cart", for: .normal)
                self.cell?.removeFromCart(productId: self.id ?? 0)
                self.cartStatus  = 0
    //            self.cell?.colllection.reloadData()
            }
        }
        
       
        
        
    }
}
