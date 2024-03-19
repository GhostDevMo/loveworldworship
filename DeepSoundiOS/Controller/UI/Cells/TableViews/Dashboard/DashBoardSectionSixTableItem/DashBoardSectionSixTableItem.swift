//
//  DashBoardSectionSixTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashBoardSectionSixTableItem: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object = [Publisher]()
    var isloading = true
    var delegate: DashaboardSectionTableItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(resource: R.nib.dashboardArtist_CollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.dashboardArtist_CollectionCell.identifier)
    }
    func bind(_ object: [Publisher]){
        self.object = object
        self.collectionView.reloadData()
    }
    
}
extension DashBoardSectionSixTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading{
           return 10
        } else {
            return self.object.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardArtist_CollectionCell.identifier, for: indexPath) as! DashboardArtist_CollectionCell
            cell.startSkelting()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardArtist_CollectionCell.identifier, for: indexPath) as! DashboardArtist_CollectionCell
            cell.stopSkelting()
            let object = self.object[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isloading {
            self.delegate?.selectArtist(publisherArray: self.object, indexPath: indexPath, cell: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 155)
    }
}
