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
    var notLoggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
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
        collectionView.register(DashboardSectionTwoCollectionItem.nib, forCellWithReuseIdentifier: DashboardSectionTwoCollectionItem.identifier)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSectionTwoCollectionItem.identifier, for: indexPath) as? DashboardSectionTwoCollectionItem
            cell?.startSkelting()
            return cell!
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSectionTwoCollectionItem.identifier, for: indexPath) as? DashboardSectionTwoCollectionItem
            cell?.stopSkelting()
            let object = self.object[indexPath.row]
            cell?.bind(object)
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.notLoggedInVC != nil{
            let vc = R.storyboard.discover.genresSongsVC()
            vc?.genresId = self.object[indexPath.row].id ?? 0
            vc?.titleString = self.object[indexPath.row].cateogryName ?? ""
            
            self.notLoggedInVC?.navigationController?.pushViewController(vc!, animated: true)
        }else  if self.loggedInVC != nil{
            let vc = R.storyboard.discover.genresSongsVC()
            vc?.genresId = self.object[indexPath.row].id ?? 0
            vc?.titleString = self.object[indexPath.row].cateogryName ?? ""
            
            self.loggedInVC?.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 150)
        
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

