//
//  EventsSeeAll.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds
class EventsSeeAll: BaseVC {
    var object = [[String:Any]]()
    private var EventlistArray = [[String:Any]]()

    @IBOutlet weak var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func fetchMyEvents(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.getEvents(AccessToken: accessToken, limit: 10, offset: 56) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.EventlistArray = success ?? []
                               // self.tableView.reloadData()
//                                self.fetchMyEvents()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
//                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
//                    if success != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.debug("userList = \(success?.status ?? 0)")
//                                self.PlaylistArray = success?.playlists ?? []
//                                self.tableView.reloadData()
//                            }
//
//                        })
//                    }else if sessionError != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//
//                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
//                                log.error("sessionError = \(sessionError?.error ?? "")")
//                            }
//                        })
//                    }else {
//                        Async.main({
//                            self.dismissProgressDialog {
//                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
//                                log.error("error = \(error?.localizedDescription ?? "")")
//                            }
//                        })
//                    }
//                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension EventsSeeAll:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = R.storyboard.products.eventDetailVC()
//        self.vc1?.navigationController?.pushViewController(vc!, animated: true)
//    }
 
}
