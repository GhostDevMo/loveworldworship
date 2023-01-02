//
//  PlayListSectionOneTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PlayListSectionOneTableItem: UITableViewCell {
    
   
    @IBOutlet weak var collectionView: UICollectionView!

     var object = [PublicPlaylistModel.Playlist]()
    var vc: PlaylistVC?
    var noLoggedVC:NotLoggedInPlaylistVC?

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
        collectionView.register(ProfilePlaylistCollectionCell.nib, forCellWithReuseIdentifier: ProfilePlaylistCollectionCell.identifier)
         }
    
         func bind(_ object:[PublicPlaylistModel.Playlist]){
             self.object = object
          self.collectionView.reloadData()
         }
         
    
}
extension PlayListSectionOneTableItem:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object.count ?? 0

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell

        let object = self.object[indexPath.row]
        cell?.publicPlaylistBind(object)
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            self.vc != nil{
            let vc = R.storyboard.playlist.showPlaylistDetailsVC()
                  vc?.publicPlaylistObject = self.object[indexPath.row]
                  self.vc?.navigationController?.pushViewController(vc!, animated:true)
            
        }else if self.noLoggedVC != nil{
            let vc = R.storyboard.playlist.showPlaylistDetailsVC()
                  vc?.publicPlaylistObject = self.object[indexPath.row]
                  self.noLoggedVC?.navigationController?.pushViewController(vc!, animated:true)
        }
      
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2 - 12
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
    
 
}
