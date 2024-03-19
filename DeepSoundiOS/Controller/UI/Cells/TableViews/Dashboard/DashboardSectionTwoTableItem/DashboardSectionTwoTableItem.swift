//
//  DashboardSectionTwoTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class DashboardSectionTwoTableItem: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var object = [GenresModel.Datum]()
    var delegate: DashaboardSectionTableItemDelegate?
    
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
    
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(resource: R.nib.dashboardSectionTwoCollectionItem), forCellWithReuseIdentifier: R.reuseIdentifier.dashboardSectionTwoCollectionItem.identifier)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
    }
    
    func bind(_ object:[GenresModel.Datum]){
        self.object = object
        self.collectionView.reloadData()
    }
}
extension DashboardSectionTwoTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading == true{
            return 10
        }
        else{
            return self.object.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardSectionTwoCollectionItem.identifier, for: indexPath) as! DashboardSectionTwoCollectionItem
            cell.startSkelting()
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardSectionTwoCollectionItem.identifier, for: indexPath) as! DashboardSectionTwoCollectionItem
            cell.stopSkelting()
            let object = self.object[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.selectGenres(object: self.object, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        
        return CGSize(width: 80, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 0)
    }
}

