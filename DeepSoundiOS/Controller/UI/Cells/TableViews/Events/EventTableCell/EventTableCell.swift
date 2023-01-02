//
//  EventTableCell.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class EventTableCell: UITableViewCell {
    
    var object = [[String:Any]]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    var vc1:PlaylistVC?
    func setupUI(){
        self.collection.delegate = self
        self.collection.dataSource = self
        collection.register(UINib(nibName: "EventsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "EventsCollectionCell")
        
    }
    func bind(_ object:[[String:Any]]){
        self.object = object
        self.collection.reloadData()
        
    }
    @IBOutlet weak var collection: UICollectionView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EventTableCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object.count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventsCollectionCell", for: indexPath) as? EventsCollectionCell
        let object = self.object[indexPath.row]
        cell?.bind(object)
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width - 30
        return CGSize(width: width, height: 250)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = R.storyboard.products.eventDetailVC()
        vc?.eventDetailObject = self.object[indexPath.row]
        
        self.vc1?.navigationController?.pushViewController(vc!, animated: true)
    }
 
}
