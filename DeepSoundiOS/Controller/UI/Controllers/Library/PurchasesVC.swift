//
//  PurchasesVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import EmptyDataSet_Swift

class PurchasesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var purchasesArray = [Purchase]()
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchPurchasesData()
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
        self.title = (NSLocalizedString("Purchases", comment: ""))
        self.tableView.addPullToRefresh {
            self.tableView.reloadEmptyDataSet()
            self.purchasesArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchPurchasesData()
        }
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.purchaseTableItem), forCellReuseIdentifier: R.reuseIdentifier.purchaseTableItem.identifier)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }
        
    private func fetchPurchasesData(){
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PurchaseManager.instance.getPurchases(AccessToken: accessToken, userId: userId, limit: 10, offset: 0) { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.purchasesArray = success?.data ?? []
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    }else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension PurchasesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            return self.purchasesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseTableItem.identifier, for: indexPath) as? PurchaseTableItem
            cell?.startSkelting()
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseTableItem.identifier, for: indexPath) as? PurchaseTableItem
            cell?.selectedBackgroundView()
            cell?.selectionStyle = .none
            cell?.stopSkelting()
            let object = self.purchasesArray[indexPath.row]
            cell?.bind(object, index: indexPath.row)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isLoading {            
            AppInstance.instance.AlreadyPlayed = false
            self.didSelectSong(purchasesArray: self.purchasesArray, indexPath: indexPath)
        }
    }
    
    func didSelectSong(purchasesArray: [Purchase], indexPath: IndexPath) {
        self.view.endEditing(true)
        var songArray:[Song] = []
        purchasesArray.forEach { (object) in
            if let data = object.songData {
                songArray.append(data)
            }
        }
        if songArray[indexPath.row].audio_id != popupContentController?.musicObject?.audio_id  {
            AppInstance.instance.AlreadyPlayed = false
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        }
        let object = songArray[indexPath.row]
        AppInstance.instance.popupPlayPauseSong = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
        }
        addToRecentlyWatched(trackId: object.id ?? 0)
        self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true) {
            popupContentController?.musicObject = object
            popupContentController?.musicArray = songArray
            popupContentController?.currentAudioIndex = indexPath.row
            popupContentController?.delegate = self
                popupContentController?.setup()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoading {
            return 300.0
        }else {
            return 300.0
        }
    }
}

// MARK: - EmptyView Delegate Methods -
extension PurchasesVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Purchase songs", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have not any purchase song yet! ", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}

extension PurchasesVC: BottomSheetDelegate {
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
