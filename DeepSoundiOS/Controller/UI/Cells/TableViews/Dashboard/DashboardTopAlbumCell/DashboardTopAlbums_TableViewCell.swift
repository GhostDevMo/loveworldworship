//
//  DashboardTopAlbums_TableViewCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK

protocol DashboardTopAlbumsTableViewCellDelegate {
    func selectAlbum(albumArray: [Album], indexPath: IndexPath, cell: DashboardTopAlbums_TableViewCell)
}

class DashboardTopAlbums_TableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var object: [Album] = []
    var delegate: DashboardTopAlbumsTableViewCellDelegate?
    var isloading = true {
        didSet {
            if isloading {
                self.object.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.dashboardTopAlbums_CollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.dashboardTopAlbums_CollectionCell.identifier)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
    }
    
    func bind(_ object: [Album]){
        self.object = object
        self.collectionView.reloadData()
    }
}

extension DashboardTopAlbums_TableViewCell:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading {
            return 10
        } else {
            return self.object.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardTopAlbums_CollectionCell.identifier, for: indexPath) as! DashboardTopAlbums_CollectionCell
            cell.startSkelting()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardTopAlbums_CollectionCell.identifier, for: indexPath) as! DashboardTopAlbums_CollectionCell
                cell.stopSkelting()
                let object = self.object[indexPath.row]
                cell.bind(object)
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isloading {
            self.delegate?.selectAlbum(albumArray: self.object, indexPath: indexPath, cell: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
}
