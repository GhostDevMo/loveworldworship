//
//  CartTableItem.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 22/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CartTableItem: UITableViewCell {
//    ShowImage
//    titleLabel
    @IBOutlet weak var ShowImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    var vc:CartVC?
    var id:Int? = 0
    var indexPath = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(_ object:[String:Any],index:Int){
        let productID = object["product_id"] as? Int
        let product = object["product"] as? [String:Any]
        let title = product?["title"] as? String
        let images = object["images"] as? [[String:Any]]
        let imageobject = images?[0] as? [String:Any]
        let image = imageobject?["image"] as? String
        self.titleLabel.text = title ?? ""
        let url = URL.init(string:image ?? "")
        self.ShowImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        self.id = productID ?? 0
        self.indexPath = index
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeFromCart(_ sender: Any) {
        self.vc?.removeFromCart(productId: self.id ?? 0, index: self.indexPath ?? 0)

    }
    
    
}
