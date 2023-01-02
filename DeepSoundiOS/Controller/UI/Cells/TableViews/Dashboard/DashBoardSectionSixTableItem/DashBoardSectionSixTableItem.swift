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
    
    var object  = [ArtistModel.Datum]()
    var notLoggedHomeVC:NotLoggedInHomeVC?
    var loggedHomeVC:Dashboard1VC?
    var isloading = true
    
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
        collectionView.register(DashboardArtist_CollectionCell.nib, forCellWithReuseIdentifier: DashboardArtist_CollectionCell.identifier)
    }
    func bind(_ object:[ArtistModel.Datum]){
        self.object = object
        self.collectionView.reloadData()
    }
    
}
extension DashBoardSectionSixTableItem:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isloading{
           return 10
        }
        else{
            return self.object.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isloading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardArtist_CollectionCell.identifier, for: indexPath) as? DashboardArtist_CollectionCell
            cell?.startSkelting()
            return cell!
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardArtist_CollectionCell.identifier, for: indexPath) as? DashboardArtist_CollectionCell
            cell?.stopSkelting()
            let object = self.object[indexPath.row]
            cell?.bind(object)
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.notLoggedHomeVC != nil{
            let vc = R.storyboard.discover.userInfoVC()
            vc?.artistObject = self.object[indexPath.row]
            self.notLoggedHomeVC?.navigationController?.pushViewController(vc!, animated: true)
        } else if self.loggedHomeVC != nil{
            let vc = R.storyboard.discover.userInfoVC()
            vc?.artistObject = self.object[indexPath.row]
            self.loggedHomeVC?.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 180, height: 230)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
