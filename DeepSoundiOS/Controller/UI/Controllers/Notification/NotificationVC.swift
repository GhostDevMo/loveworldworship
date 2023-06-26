//
//  NotificationVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus

class NotificationVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var notifcationArray = [NotificationModel.Notifiation]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchNotification()
        self.setupUI()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.showLabel.text = NSLocalizedString("There is no Notification", comment: "There is no Notification")
        self.showImage.tintColor = .mainColor
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
        
        self.title =    NSLocalizedString("Notification", comment: "Notification")
     
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register(Notifications_TableCell.nib, forCellReuseIdentifier: Notifications_TableCell.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        self.notifcationArray.removeAll()
        self.tableView.reloadData()
        self.fetchNotification()
        refreshControl.endRefreshing()
    }
    
    
    @IBAction func notificationSettingsPressed(_ sender: Any) {
        let vc = R.storyboard.settings.settingNotificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func fetchNotification(){
        if Connectivity.isConnectedToNetwork(){
            self.notifcationArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                NotificationManager.instance.getNotification(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.notifiations ?? [])")
                                self.notifcationArray = success?.notifiations ?? []
                                if self.notifcationArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.tableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.tableView.reloadData()
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
extension NotificationVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifcationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Notifications_TableCell.identifier) as? Notifications_TableCell
        cell?.selectionStyle = .none
        let object = self.notifcationArray[indexPath.row]
        cell?.nameLabel.text = object.userData?.name?.htmlAttributedString ?? ""
        cell?.showTextLabel.text = object.nText ?? ""
        let url = URL.init(string:object.userData?.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if object.nType == "follow_user"{
            cell?.showImage.image = R.image.ic_notificationUser()
        }else{
            cell?.showImage.image = R.image.ic_notificationLike()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
            let vc = R.storyboard.dashboard.showProfileVC()
            vc?.userID  = self.notifcationArray[indexPath.row].userData?.id ?? 0
            vc?.profileUrl = self.notifcationArray[indexPath.row].userData?.url ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
     
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}
