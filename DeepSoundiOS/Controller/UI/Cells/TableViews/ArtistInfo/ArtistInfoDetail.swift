//
//  ArtistInfoDetail.swift
//  DeepSoundiOS
//
//  Created by Moghees on 26/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
class ArtistInfoDetail: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var songArray = [UserInfoModel.Latestsong]()
    private var topSongArray = [UserInfoModel.Latestsong]()
    private var storeSongsArray = [UserInfoModel.Latestsong]()
    private var activitiesArray = [UserInfoModel.Activity]()
    var type:ArtistInfoSections = .latestsongs
    var isloading = true
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(DashboardNewRelease_CollectionCell.nib, forCellWithReuseIdentifier: DashboardNewRelease_CollectionCell.identifier)
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bind(_ object: [UserInfoModel.Latestsong]?, type: ArtistInfoSections,isloading: Bool = true){
            self.songArray = object!
            self.type = type
            self.isloading = isloading
            self.collectionView.reloadData()
        }
    
}
extension ArtistInfoDetail:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if isloading{
            return 10
        }
        else{
            return self.songArray.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // if type == .latestsongs{
        if isloading{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            cell?.startSkelting()
            return cell!
        }
        else
        {
            
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
            cell?.stopSkelting()
                let object = self.songArray[indexPath.row]
                cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
                cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music - \(object.countViews)"
                let url = URL.init(string:object.thumbnail ?? "")
                cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
                return cell!
        }
//        }else if type == .topsongs{
//
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
//            let object = self.songArray[indexPath.row]
//            cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
//            cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music - \(object.countViews)"
//            let url = URL.init(string:object.thumbnail ?? "")
//            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
//            return cell!
//        }else if type == .playlist{
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardNewRelease_CollectionCell.identifier, for: indexPath) as? DashboardNewRelease_CollectionCell
//            let object = self.songArray[indexPath.row]
//            cell?.titleLabel.text = object.title?.htmlAttributedString ?? ""
//            cell?.MusicCountLabel.text = "\(object.categoryName ?? "") Music"
//            let url = URL.init(string:object.thumbnail ?? "")
//            cell?.thumbnailimage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
//            return cell!
//
//        }
//        else{
//            return UICollectionViewCell()
//        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 230)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
