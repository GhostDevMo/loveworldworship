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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var id:Int? = 0
    var cartStatus:Int? = 0
    var buttonHandle: ((_ sender: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.cornerRadiusV = 15.0
        topCorners(bgView: self.image, cornerRadius: 15.0, maskToBounds: true)
        self.mainView.addShadow()
        addToCartButton.backgroundColor = .ButtonColor
        price.textColor = .ButtonColor
    }
    
    func bind(_ object: Product){
        self.name.text = object.title
        self.price.text = "$\(object.formatted_price ?? "")"
        self.id = object.id
        self.cartStatus = object.added_to_cart
        let url = URL.init(string: object.images?.first?.image ?? "")
        self.image.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        let categories = AppInstance.instance.optionsData?.products_categories
        let categoryName = categories?.dictionaryValue?["\(object.cat_id ?? 0)"] as? String
        self.type.text = categoryName ?? ""        
        if self.cartStatus == 0 {
            self.addToCartButton.setTitle("Add to Cart", for: .normal)
            self.cartStatus = 0
        } else {
            self.addToCartButton.setTitle("Remove from Cart", for: .normal)
            self.cartStatus = 1
        }
    }
    
    @IBAction func addToCartPressed(_ sender: UIButton) {
        self.buttonHandle?(sender)
    }
}
