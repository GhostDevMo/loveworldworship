//
//  DashboardSectionThreeTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import DeepSoundSDK
import Async

protocol DashaboardSectionTableItemDelegate {
    func selectSong(songArray: [Song], indexPath: IndexPath, cell: DashboardSectionThreeTableItem)
    func selectArtist(publisherArray: [Publisher], indexPath: IndexPath, cell: DashBoardSectionSixTableItem)
    func selectPlaylist(playlistArray: [Playlist], indexPath: IndexPath, cell: DashboardSectionThreeTableItem)
    func selectGenres(object: [GenresModel.Datum], indexPath: IndexPath)
}

extension DashaboardSectionTableItemDelegate {
    func selectPlaylist(playlistArray: [Playlist], indexPath: IndexPath, cell: DashboardSectionThreeTableItem) {}
}

class DashboardSectionThreeTableItem: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object: [Song] = []
    var delegate: DashaboardSectionTableItemDelegate?
    var isloading = true {
        didSet {
            if isloading {
                self.object.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    var playlistArray:[Playlist] = []
    var isPlaylist = false
    
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
        self.collectionView.register(UINib(resource: R.nib.dashboardNewRelease_CollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.dashboardNewRelease_CollectionCell.identifier)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
    }
    
    func bind(_ object: [Song]){
        self.object = object
        self.collectionView.reloadData()
    }
    
    func bindPlaylist(_ object: [Playlist]) {
        self.playlistArray = object
        self.collectionView.reloadData()
    }
}

extension DashboardSectionThreeTableItem: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isPlaylist {
            return self.playlistArray.count
        }else {
            if isloading {
                return 10
            } else {
                if self.object.count >= 10 {
                    return 10
                }
                return self.object.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isPlaylist {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardNewRelease_CollectionCell.identifier, for: indexPath) as! DashboardNewRelease_CollectionCell
            cell.stopSkelting()
            let object = self.playlistArray[indexPath.row]
            cell.bindPlaylist(object)
            return cell
        }else {
            if isloading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardNewRelease_CollectionCell.identifier, for: indexPath) as! DashboardNewRelease_CollectionCell
                cell.startSkelting()
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardNewRelease_CollectionCell.identifier, for: indexPath) as! DashboardNewRelease_CollectionCell
                cell.stopSkelting()
                let object = self.object[indexPath.row]
                cell.bind(object)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isPlaylist {
            self.delegate?.selectPlaylist(playlistArray: self.playlistArray, indexPath: indexPath, cell: self)
        }else {
            self.delegate?.selectSong(songArray: self.object, indexPath: indexPath, cell: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 164, height: 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
}

extension String {
    func doubleValue() -> Double? {
        return Double(self)?.rounded(toPlaces: 2)
    }
}
