//
//  CreateProductCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CreateProductCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var imageShow: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var cell:CreateProductTableItem?
    var index:Int? = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func bind(section:Int,indexpath:Int){
        if section == 0{
            self.cancelBtn.isHidden = true
        }else{
            self.cancelBtn.isHidden = false
            self.index = indexpath
        }
        
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.cell?.images.remove(at: self.index ?? 0)
        self.cell?.collectionview.reloadData()
    }
}
