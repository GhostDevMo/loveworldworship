//
//  PlayListSectionTwoTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PlayListSectionTwoTableItem: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var isLoading = true {
        didSet {
            if isLoading {
                self.object.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    var object = [Blog]()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.articlesCollectionItem), forCellWithReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier)
    }
    
    func bind(_ object:[Blog]) {
        self.object = object
        self.collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension PlayListSectionTwoTableItem: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 5
        }else {
            return self.object.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
            cell.startSkelting()
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
            cell.stopSkelting()
            let object = self.object[indexPath.row]
            cell.bind(object)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let vc = R.storyboard.settings.articlesDetailsVC()
        //        vc?.object = self.object[indexPath.row]
        //        self.vc?.navigationController?.pushViewController(vc!, animated:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - 30
        return CGSize(width: width, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}
