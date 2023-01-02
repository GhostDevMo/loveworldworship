//
//  FollowingsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
//import Floaty
import SwiftEventBus
import DeepSoundSDK

class FollowingsVC: BaseVC {
    
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    var userID:Int? = 0
    private var floaty = Floaty()
    private var followingsArray = [FollowingModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private var fetchSatus:Bool? = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showImage.tintColor = .mainColor
         self.fetchFollowing()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            self.view.makeToast(InterNetError)
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
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    deinit{
        SwiftEventBus.unregister(self)
    }
    
    private func setupUI(){
        self.showLabel.text = (NSLocalizedString("No Users Found", comment: ""))
        self.title = (NSLocalizedString("Followings", comment: ""))
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.followingTableView.separatorStyle = .none
        followingTableView.register(Followings_TableCell.nib, forCellReuseIdentifier: Followings_TableCell.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        followingTableView.addSubview(refreshControl)
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
//        self.view.addSubview(floaty)
        
    }
    @objc func refresh(sender:AnyObject) {
        self.followingsArray.removeAll()
        self.followingTableView.reloadData()
        self.fetchFollowing()
        refreshControl.endRefreshing()
    }
    private func fetchFollowing(){
        if Connectivity.isConnectedToNetwork(){
            self.followingsArray.removeAll()
            
            if fetchSatus!{
                fetchSatus = false
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            }else{
                log.verbose("will not show Hud more...")
            }
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                FollowManager.instance.getFollowings(Id: userId, AccessToken: accessToken, Offset: 0, Limit: 10, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.followingsArray = success?.data?.data ?? []
                                if self.followingsArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.followingTableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.followingTableView.reloadData()
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
        return self.followingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Followings_TableCell.identifier) as? Followings_TableCell
        cell?.vc = self
        cell?.delegate = self
        cell?.indexPath = indexPath.row
        cell?.selectionStyle = .none
        let object = self.followingsArray[indexPath.row]
        cell?.usernameLabel.text = object.username ?? ""
        let url = URL.init(string:object.avatar ?? "")
        cell?.userProfileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        return cell!
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.followingsArray[indexPath.row].artist == 0{
            let vc = R.storyboard.dashboard.showProfileVC()
            vc?.userID  = self.followingsArray[indexPath.row].id ?? 0
            vc?.profileUrl = self.followingsArray[indexPath.row].url ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            let vc = R.storyboard.discover.userInfoVC()
            vc?.followingObject = self.followingsArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension FollowingsVC:followUserDelegate{
    func followUser(index: Int, button: UIButton, status: Bool) {
        let userId = self.followingsArray[index].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        
        if status{
            
            button.backgroundColor = UIColor.ButtonColor
            button.setTitle((NSLocalizedString(("Following"), comment: "")), for: .normal)
            button.setTitleColor(.white, for: .normal)
            self.followUser(index: index)
            
        }else{
            button.backgroundColor = .white
            button.setTitle((NSLocalizedString(("Follow"), comment: "")), for: .normal)
            button.borderColorV = UIColor.ButtonColor
            button.setTitleColor(UIColor.hexStringToUIColor(hex:  "FFA143"), for: .normal)
            self.unFollowUser(index: index)
        }
    }
    func followUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.followingsArray[index].id ?? 0
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
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
    func unFollowUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.followingsArray[index].id ?? 0
            
             self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
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
