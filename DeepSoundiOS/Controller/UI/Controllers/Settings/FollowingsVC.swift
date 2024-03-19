//
//  FollowingsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import EmptyDataSet_Swift

class FollowingsVC: BaseVC {
    
    @IBOutlet weak var followingTableView: UITableView!
    
    var userID:Int? = 0
    private var floaty = Floaty()
    private var followingsArray = [Publisher]()
    private var fetchSatus:Bool? = true
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchFollowing()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            self.view.makeToast(InterNetError)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    deinit{
        SwiftEventBus.unregister(self)
    }
    
    private func setupUI() {
        self.followingTableView.separatorStyle = .none
        followingTableView.register(UINib(resource: R.nib.artistTableCell), forCellReuseIdentifier: R.reuseIdentifier.artistTableCell.identifier)
        followingTableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        self.followingTableView.addPullToRefresh {
            self.isLoading = true
            self.followingsArray.removeAll()
            self.followingTableView.reloadData()
            self.fetchFollowing()
        }
        
        floaty.buttonColor = UIColor.hexStringToUIColor(hex: "FFA143")
        floaty.itemImageColor = .white
        let uploadItem = FloatyItem()
        uploadItem.hasShadow = true
        uploadItem.buttonColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
        uploadItem.circleShadowColor = UIColor.black
        uploadItem.titleShadowColor = UIColor.black
        uploadItem.titleLabelPosition = .left
        uploadItem.title = (NSLocalizedString("upload Single Song", comment: ""))
        uploadItem.iconImageView.image = R.image.ic_action_upload()
        uploadItem.handler = { item in
            
        }
        floaty.addItem(item: uploadItem)
    }
    
    private func fetchFollowing() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                FollowManager.instance.getFollowings(Id: userId, AccessToken: accessToken, Offset: 0, Limit: 10, completionBlock: { (success, sessionError, error) in
                    Async.main {
                        self.followingTableView.stopPullToRefresh()
                    }
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.followingsArray = success?.data?.data ?? []
                                self.isLoading = false
                                self.followingTableView.reloadData()
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
                })
                
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

extension FollowingsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }
        return self.followingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
            cell.startSkelting()
            cell.selectionStyle = .none
            return cell
        }else {
            if followingsArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
                cell.titleLabel.text = "No Users Found"
                cell.noDataLabel.text = "You don't have any following users."
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
            cell.stopSkelting()
            cell.selectionStyle = .none
            cell.btnFollow.tag = indexPath.row
            cell.delegate = self
            cell.bind(followingsArray[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            if followingsArray.count != 0 {
                if self.followingsArray[indexPath.row].artist == 0 {
                    let vc = R.storyboard.dashboard.showProfile2VC()
                    vc?.userID  = self.followingsArray[indexPath.row].id ?? 0
                    self.navigationController?.pushViewController(vc!, animated: true)
                }else{
                    let vc = R.storyboard.discover.artistDetailsVC()
                    vc?.artistObject = self.followingsArray[indexPath.row]
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Warning Popup Delegate Methods -
extension FollowingsVC: WarningPopupVCDelegate {
    func warningPopupOKButtonPressed(_ sender: UIButton,_ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        }else if sender.tag == 1003 {
            let newVC = R.storyboard.settings.settingWalletVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
}

extension FollowingsVC: followUserDelegate {
    func followUser(_ index: Int, _ sender: UIButton) {
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let userId = self.followingsArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        followingsArray[sender.tag].is_following = !(followingsArray[sender.tag].is_following)
        if sender.currentTitle == "Follow" {
            sender.setTitle("Following", for: .normal)
            sender.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
            sender.setTitleColor(.mainColor, for: .normal)
            self.followUser(userId: userId)
        }else {
            sender.setTitle("Follow", for: .normal)
            sender.backgroundColor = .mainColor
            sender.setTitleColor(.white, for: .normal)
            self.unFollowUser(userId: userId)
        }
    }
    
    func followUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString(("User has been Followed"), comment: ""))
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func unFollowUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString(("User has been unfollowed"), comment: ""))
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
