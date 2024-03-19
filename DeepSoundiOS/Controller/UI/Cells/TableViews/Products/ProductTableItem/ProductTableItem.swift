//
//  ProductTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 13/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol ProductTableItemDelegate {
    func cartButtonAction(_ sender: UIButton, indexPath: IndexPath)
}

class ProductTableItem: UITableViewCell {
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    var id:Int? = 0
    var cartStatus:Int? = 0
    var indexPath:IndexPath?
    var delegate: ProductTableItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainView.cornerRadiusV = 15.0
        topCorners(bgView: self.imageProduct, cornerRadius: 15.0, maskToBounds: true)
        self.mainView.addShadow()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(_ object: Product) {
        self.name.text = object.title
        self.price.text = "$\(object.formatted_price ?? "")"
        self.id = object.id ?? 0
        self.cartStatus = object.added_to_cart ?? 0
        
        let url = URL.init(string:object.images?.first?.image ?? "")
        self.imageProduct.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        let categories = AppInstance.instance.optionsData?.products_categories
        let categoryName = categories?.dictionaryValue?["\(object.cat_id ?? 0)"] as? String
        self.type.text = categoryName
        
        if self.cartStatus == 0 {
            self.addToCartButton.setTitle("Add to Cart", for: .normal)
            self.cartStatus = 0
        }else{
            self.addToCartButton.setTitle("Remove from Cart", for: .normal)
            self.cartStatus = 1
        }
    }
    
    @IBAction func addToCartPressed(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.cartButtonAction(sender, indexPath: indexPath)
        }
    }
}
