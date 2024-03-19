//
//  CartTableItem.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 22/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol CartItemDelegate {
    func removeItem(_ indexPath: IndexPath, _ sender: UIButton)
    func qtyItem(_ indexPath: IndexPath, _ sender: UIButton)
}

class CartTableItem: UITableViewCell {

    @IBOutlet weak var publisherNameLbl: UILabel!
    @IBOutlet weak var ShowImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    var delegate: CartItemDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(_ object: Product, index:Int) {
        self.titleLabel.text = object.title
        let url = URL.init(string: object.images?.first?.image ?? "")
        self.publisherNameLbl.text = object.user_data?.dataValue?.name
        self.priceLbl.text = "$ \(object.formatted_price ?? "")"
        self.ShowImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func removeFromCart(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.removeItem(indexPath, sender)
        }
    }
    
    @IBAction func dropDownBtnAction(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.qtyItem(indexPath, sender)
        }
    }
}
