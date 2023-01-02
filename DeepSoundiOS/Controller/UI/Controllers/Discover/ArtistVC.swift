//
//  ArtistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import Async
//import Floaty
import SwiftEventBus
import DeepSoundSDK

class ArtistVC: BaseVC {
    
    @IBOutlet weak var followersTableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    var userID:Int? = 0
    private var floaty = Floaty()
    private var artistArray = [ArtistModel.Datum]()
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
   
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    deinit{
        SwiftEventBus.unregister(self)
    }
    
    private func setupUI(){
        self.showLabel.text = (NSLocalizedString("No Users Found", comment: ""))
        self.title = (NSLocalizedString("Artist", comment: ""))
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.followersTableView.separatorStyle = .none
        followersTableView.register(Followers_TableCell.nib, forCellReuseIdentifier: Followers_TableCell.identifier)
        followersTableView.register(ArtistTableCell.nib, forCellReuseIdentifier: ArtistTableCell.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        followersTableView.addSubview(refreshControl)
        
       
        
    }
    @objc func refresh(sender:AnyObject) {
        self.artistArray.removeAll()
        self.followersTableView.reloadData()
        self.fetchFollowing()
        refreshControl.endRefreshing()
    }
    private func fetchFollowing(){
        if Connectivity.isConnectedToNetwork(){
            self.artistArray.removeAll()
            
            if fetchSatus!{
                fetchSatus = false
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            }else{
                log.verbose("will not show Hud more...")
            }
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                ArtistManager.instance.getDiscover(AccessToken: accessToken, Limit: 10, Offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.artistArray = success?.data?.data ?? []
                                if self.artistArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.followersTableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.followersTableView.reloadData()
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
    
    @objc func didTapFollowArtist(sender:UIButton){
        
        let userId = self.artistArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        if self.artistArray[sender.tag].lastFollowID == 0{
            
            sender.backgroundColor = UIColor.white
            sender.setTitle((NSLocalizedString(("Following"), comment: "")), for: .normal)
            sender.setTitleColor((UIColor.hexStringToUIColor(hex:  "FFA143")), for: .normal)
            sender.borderColorV = UIColor.ButtonColor
            sender.borderWidthV = 0.5
            self.followUser(index: sender.tag)
            
        }else{
            sender.backgroundColor = .ButtonColor
            sender.setTitle((NSLocalizedString(("Follow"), comment: "")), for: .normal)
            sender.setTitleColor(UIColor.white, for: .normal)
            self.unFollowUser(index: sender.tag)
        }
    }
    func followUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.artistArray[index].id ?? 0
            if userId == AppInstance.instance.userId {
                self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
                return
            }
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
            let userId = self.artistArray[index].id ?? 0
           
            self.showProgressDialog(text: (NSLocalizedString(("Loading..."), comment: "")))
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast((NSLocalizedString(("User has been unfollowed"), comment: "")))
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

extension ArtistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTableCell.identifier) as? ArtistTableCell
       // cell?.loggedHomeVC = self
        cell?.selectionStyle = .none
        cell?.btnMore.tag = indexPath.row
        cell?.btnMore.addTarget(self, action: #selector(didTapFollowArtist(sender:)), for: .touchUpInside)
        cell?.bind(self.artistArray[indexPath.row])
        return cell!
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
         let vc = storyBoard.instantiateViewController(withIdentifier: "ArtistInfoVC") as! ArtistInfoVC
        vc.artistObject = self.artistArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
}
