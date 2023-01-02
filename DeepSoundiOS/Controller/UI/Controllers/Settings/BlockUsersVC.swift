//
//  BlockUsersVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class BlockUsersVC: BaseVC {
    
    
    @IBOutlet weak var blockUsersTableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var blockUsersArray = [GetBlockUsersModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private var fetchSatus:Bool? = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showImage.tintColor = .mainColor
        self.showLabel.text = (NSLocalizedString("There are no users", comment: ""))
        self.fetchBlockUsers()
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
        self.title = (NSLocalizedString("Block Users", comment: ""))
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.blockUsersTableView.separatorStyle = .none
        blockUsersTableView.register(BlockedUsers_TableCell.nib, forCellReuseIdentifier: BlockedUsers_TableCell.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        blockUsersTableView.addSubview(refreshControl)
    }
    @objc func refresh(sender:AnyObject) {
        self.blockUsersArray.removeAll()
        self.blockUsersTableView.reloadData()
        self.fetchBlockUsers()
        refreshControl.endRefreshing()
    }
    private func fetchBlockUsers(){
        if Connectivity.isConnectedToNetwork(){
            self.blockUsersArray.removeAll()
            
            if fetchSatus!{
                fetchSatus = false
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            }else{
                log.verbose("will not show Hud more...")
            }
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                BlockUsersManager.instance.getBlockUsers(Id: userId, AccessToken: accessToken, Offset: 0, Limit: 5, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.blockUsersArray = success?.data?.data ?? []
                                if self.blockUsersArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.blockUsersTableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.blockUsersTableView.reloadData()
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
    private func UnblockUserPopup(id:Int,name:String,index:Int){
        let alert = UIAlertController(title: (NSLocalizedString("Unblock", comment: "")), message: (NSLocalizedString("Are you sure you want to unblock this \(name)", comment: "")), preferredStyle: .alert)
        let unblock = UIAlertAction(title: (NSLocalizedString("UNBLOCK", comment: "")), style: .default) { (action) in
            log.verbose("Unblock")
            self.unblockUser(id: id, index: index)
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("CANCEL", comment: "")), style: .cancel, handler: nil)
        alert.addAction(unblock)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    private func unblockUser(id:Int,index:Int){
          if Connectivity.isConnectedToNetwork(){
              
              self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
              let accessToken = AppInstance.instance.accessToken ?? ""
              Async.background({
                  BlockUsersManager.instance.unBlockUser(Id: id, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                      if success != nil{
                          Async.main({
                              self.dismissProgressDialog {
                                  log.debug("success = \(success?.status ?? 0)")
                                self.blockUsersArray.remove(at: index)
                                self.blockUsersTableView.reloadData()
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
extension BlockUsersVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:BlockedUsers_TableCell.identifier) as? BlockedUsers_TableCell
        cell?.selectionStyle = .none
        let object = self.blockUsersArray[indexPath.row]
        cell?.usernameLabel.text = object.username ?? ""
        let url = URL.init(string:object.avatar ?? "")
        cell?.userProfileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.UnblockUserPopup(id:  self.blockUsersArray[indexPath.row].id ?? 0, name:  self.blockUsersArray[indexPath.row].name ?? "", index: indexPath.row)
     
    }
    
}

