//
//  SearchPlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import DeepSoundSDK

class SearchPlaylistVC: BaseVC {
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
    private let randomString:String? = "a"
    private var playlistArray = [SearchModel.Playlist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH) { result in
            self.dismissProgressDialog {
                self.playlistArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let playlistResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.playlistArray = playlistResult?.playlist ?? []
                log.verbose("SongsCount = \(playlistResult?.playlist?.count)")
                self.collectionView.reloadData()
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                self.playlistArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let playlistResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.playlistArray = playlistResult?.playlist ?? []
                log.verbose("SongsCount = \(playlistResult?.playlist?.count)")
                self.collectionView.reloadData()
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["keyword":randomString])
    }
    private func setupUI(){
        collectionView.register(ProfilePlaylistCollectionCell.nib, forCellWithReuseIdentifier: ProfilePlaylistCollectionCell.identifier)
    }
    
    
    
}
extension SearchPlaylistVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.playlistArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
        
        let object = self.playlistArray[indexPath.row]
        cell?.searchPlayListBind(object)
        
        return cell!
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = R.storyboard.playlist.showPlaylistDetailsVC()
        vc?.searchPlaylistObject = self.playlistArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
        
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
extension SearchPlaylistVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("PLAYLIST", comment: "PLAYLIST"))
    }
}
