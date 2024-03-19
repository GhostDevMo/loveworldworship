//
//  CreateProductCollectionItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol ImageRemoveButtonDelegate {
    func removeButton(_ indexPath: IndexPath,_ sender: UIButton)
}

class CreateProductCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var imageShow: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var selectedIndexPath: IndexPath?
    var delegate: ImageRemoveButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func cancelPressed(_ sender: UIButton) {
        if let selectedIndexPath = self.selectedIndexPath {
            self.delegate?.removeButton(selectedIndexPath, sender)
        }
    }
}
