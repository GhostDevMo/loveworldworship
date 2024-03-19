//
//  ProductHeaderItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import ImageSlideshow
import SDWebImage
import Alamofire

protocol ProductDetailsDelegate {
    func addToCartBtn(_ sender: UIButton, qty: Int)
    func shareBtn(_ sender: UIButton)
    func copyBtn(_ sender: UIButton)
}

class ProductHeaderItem: UITableViewCell {

    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageSlide: ImageSlideshow!
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var unitTF: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var unitView: UIView!
    
    var imageSource = [SDWebImageSource]()
    var userID:Int? = 0
    var object: Product?
    var delegate: ProductDetailsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageSlide.contentScaleMode = UIViewContentMode.scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func isAnimation(_ animated: Bool) {
        self.backView.backgroundColor = animated ? .white : .mainColor
        self.unitView.backgroundColor = animated ? .white : .mainColor.withAlphaComponent(0.75)
    }
    
    func bind(_ object: Product) {
        self.object = object
        let categories = AppInstance.instance.optionsData?.products_categories
        let categoryName = categories?.dictionaryValue?["\(object.cat_id ?? 0)"] as? String
        self.titleLabel.text = object.title
        self.typeLabel.text = categoryName ?? ""
        self.priceLabel.text = "$\(object.formatted_price ?? "")"
        self.userID = object.user_id
        object.images?.forEach { it in
            if let image = it.image {
                self.imageSource.append(SDWebImageSource(urlString: image)!)
            }
          
        }
        self.imageSlide.setImageInputs(self.imageSource)
        self.unitTF.text = "1"
        
        if object.added_to_cart == 0 {
            self.btnCart.setTitle("Add to Cart", for: .normal)
        } else {
            self.btnCart.setTitle("Remove from Cart", for: .normal)
        }
        self.ratingView.rating = object.rating?.stringValue?.doubleValue() ?? 0.0
        self.ratingLabel.text = object.rating?.stringValue
    }
            
    @IBAction func cartBtnPressed(_ sender: UIButton) {
        if let qty = self.unitTF.text, let count = Int(qty) {
            self.delegate?.addToCartBtn(sender, qty: count)
        }
    }
}
