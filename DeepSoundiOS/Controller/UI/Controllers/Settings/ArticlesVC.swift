//
//  ArticlesVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class ArticlesVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var articlesArray = [GetArticlesModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var recentlyPlayedMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showImage.tintColor  = .mainColor
        self.setupUI()
        self.getArticles()
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
    
    private func setupUI(){
        self.title = (NSLocalizedString("Articles", comment: ""))
        self.showLabel.text = (NSLocalizedString("There Are no Articles yet", comment: ""))
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.register(ArticlesCollectionItem.nib, forCellWithReuseIdentifier: ArticlesCollectionItem.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        self.articlesArray.removeAll()
        self.collectionView.reloadData()
        self.getArticles()
        refreshControl.endRefreshing()
        
    }
    private func getArticles(){
        if Connectivity.isConnectedToNetwork(){
            self.articlesArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            
            Async.background({
                ArticlesManager.instance.getArticles(AccessToken: accessToken, limit: 10, offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.articlesArray = success?.data ?? []
                                if self.articlesArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.collectionView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.collectionView.reloadData()
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}
extension ArticlesVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.articlesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticlesCollectionItem.identifier, for: indexPath) as? ArticlesCollectionItem
        let object = self.articlesArray[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = R.storyboard.settings.articlesDetailsVC()
        vc?.object = self.articlesArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectionView.frame.width, height: 230)
        
    }
    //        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //            return 8
    //        }
    //
    //        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //            return 8
    //        }
    //        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    //        }
    
    
    
}
