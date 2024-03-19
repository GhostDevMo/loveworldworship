//
//  ProductsCollectionTableCell.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 15/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async

protocol ProductsCollectionTableCellDelegate {
    func cartButtonPressed(_ sender: UIButton, indexPath: IndexPath, products:[Product], cell: ProductsCollectionTableCell)
    func productDetails(indexPath: IndexPath, products:[Product])
}

class ProductsCollectionTableCell: UITableViewCell {

    @IBOutlet weak var colllection: UICollectionView!
    
    var object = [Product]()
    var delegate: ProductsCollectionTableCellDelegate?
    var isLoading = true {
        didSet {
            if isLoading {
                self.object.removeAll()
                self.colllection.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.colllection.delegate = self
        self.colllection.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colllection.register(UINib(resource: R.nib.productsCollectionItem), forCellWithReuseIdentifier: R.reuseIdentifier.productsCollectionItem.identifier)
    }
    func bind(_ object: [Product]){
        self.object = object
        self.colllection.reloadData()
        
    }
}

extension ProductsCollectionTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 5
        }else {
            return self.object.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = colllection.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.productsCollectionItem.identifier, for: indexPath) as? ProductsCollectionItem
            cell?.startSkelting()
            return cell!
        }else {
            let cell = colllection.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.productsCollectionItem.identifier, for: indexPath) as? ProductsCollectionItem
            cell?.stopSkelting()
            let object = self.object[indexPath.row]
            cell?.bind(object)
            cell?.buttonHandle = { sender in
                self.delegate?.cartButtonPressed(sender, indexPath: indexPath, products: self.object, cell: self)
            }
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.productDetails(indexPath: indexPath, products: self.object)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}


