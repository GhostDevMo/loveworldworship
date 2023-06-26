//
//  SelectPrice-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 24/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SelectPrice_TableCell: UITableViewCell {
    
    @IBOutlet weak var priceNameLabel
    : UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    private var status:Bool? = false
    var priceIdArray = [PriceModel.Datum]()
    var indexPath:Int? = 0
    var delegate: didSetPriceDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectPressed(_ sender: Any) {
        self.status = !status!
        if status!{
            self.delegate?.didSetPrice(Image: self.checkImage, status: status ?? false, idsArray: priceIdArray, Index: indexPath!)
        }else{
            self.delegate?.didSetPrice(Image: self.checkImage, status: status ?? false, idsArray: priceIdArray, Index: indexPath!)
        }
    }
}
