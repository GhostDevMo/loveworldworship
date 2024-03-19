//
//  PlayListSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol PlayListSectionOneTableItemDelegate {
    func selectPlaylist(_ object: [Playlist], indexPath: IndexPath, cell: PlayListSectionOneTableItem)
}

class PlayListSectionOneTableItem: UITableViewCell {
        
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object = [Playlist]()
    var isLoading = true {
        didSet {
            if isLoading {
                self.object.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    var delegate: PlayListSectionOneTableItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.profilePlaylistCollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier)
    }
    
    func bind(_ object:[Playlist]){
        self.object = object
        self.collectionView.reloadData()
    }
}

extension PlayListSectionOneTableItem: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            return self.object.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
            cell?.startSkelting()
            return cell!
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
            cell?.stopSkelting()
            let object = self.object[indexPath.row]
            cell?.publicPlaylistBind(object)
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLoading {
            self.delegate?.selectPlaylist(self.object, indexPath: indexPath, cell: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }
}
