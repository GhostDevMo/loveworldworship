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
import EmptyDataSet_Swift

class ArticlesVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var articlesArray = [Blog]()
    private var refreshControl = UIRefreshControl()
    var isLoading = true
    var articleOffSet = "0"
    var articleLastCount = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showImage.tintColor  = .mainColor
        self.setupUI()
        self.getArticles()
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
    
    private func setupUI() {
        self.showLabel.text = (NSLocalizedString("There Are no Articles yet", comment: ""))
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.collectionView.addPullToRefresh {
            self.articlesArray.removeAll()
            self.articleOffSet = "0"
            self.isLoading = true
            self.collectionView.reloadData()
            self.getArticles()
        }
        self.collectionView.emptyDataSetSource = self
        self.collectionView.emptyDataSetDelegate = self
        collectionView.register(UINib(resource: R.nib.articlesCollectionItem), forCellWithReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier)
    }
    
    private func getArticles() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                ArticlesManager.instance.getArticles(AccessToken: accessToken, limit: 10, offset: self.articleOffSet) { (success, sessionError, error) in
                    self.collectionView.stopPullToRefresh()
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                let listArray = success?.data ?? []
                                if self.articleOffSet == "0" {
                                    self.articlesArray = listArray
                                    self.isLoading = false
                                }else{
                                    self.articlesArray.append(contentsOf: listArray)
                                }
                                self.articleLastCount = listArray.count
                                self.articleOffSet = listArray.last?.id ?? "0"
                                if self.articlesArray.isEmpty {
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                }
                                self.collectionView.reloadData()
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
        if isLoading {
            return 7
        }else {
            return self.articlesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
            cell.startSkelting()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
            cell.stopSkelting()
            let object = self.articlesArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.settings.articlesDetailsVC()
            vc?.object = self.articlesArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == (self.articlesArray.count - 1) {
            if !(self.articleLastCount < 10) {
                DispatchQueue.main.async {
                    self.getArticles()
                }
            }
        }
    }
    
}

extension ArticlesVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black
        let message = (NSLocalizedString("There Are no Articles yet", comment: ""))
        return message.stringToAttributed
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}
