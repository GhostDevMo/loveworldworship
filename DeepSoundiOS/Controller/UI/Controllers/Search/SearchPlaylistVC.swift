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
    
    private let randomString:String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
    private var playlistArray = [Playlist]()
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                if let isTyping = result?.userInfo?[AnyHashable("isTyping")] as? Bool, isTyping {
                    if !self.isLoading {
                        self.playlistArray.removeAll()
                        self.isLoading = true
                        self.collectionView.reloadData()
                        return
                    }
                }
                if let playlistResult = result?.userInfo?[AnyHashable("receiveResult")] as? SearchModel.DataClass {
                    self.playlistArray = playlistResult.playlist ?? []
                    let isHidden = self.playlistArray.count == 0
                    self.showImage.isHidden = !isHidden
                    self.showStack.isHidden = !isHidden
                    self.searchBtn.isHidden = !isHidden
                    log.verbose("SongsCount = \(playlistResult.playlist?.count ?? 0)")
                    self.isLoading = false
                    self.collectionView.reloadData()
                    return
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["isRandomSearch": true])
    }
    private func setupUI(){
        self.collectionView.register(UINib(resource: R.nib.profilePlaylistCollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier)
    }
}

extension SearchPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            return self.playlistArray.count
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
            let object = self.playlistArray[indexPath.row]
            cell?.searchPlayListBind(object)
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.playlist.showPlaylistDetailsVC()
            vc?.playlistObject = self.playlistArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2
        return CGSize(width: width, height: 230)
    }
}
