//
//  SettingNotificationVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 16/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds
class SettingNotificationVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.estimatedRowHeight = 70
        tableview.register(UINib(nibName: "SettingNotificationItem", bundle: nil), forCellReuseIdentifier: "SettingNotificationItem")
    }

}

extension SettingNotificationVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "Someone followed me"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnFollowUser ?? 0)
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnFollowUser ?? 0
            cell.delegate = self
            cell.indexPath = indexPath.row
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "Someone like/dislike on of my track"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnLikedTrack ?? 0)
            cell.indexPath = indexPath.row
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnLikedTrack ?? 0
            cell.delegate = self
            return cell
        case 02:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "Someone liked on of my comments"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnLikedComment ?? 0)
            cell.indexPath = indexPath.row
            
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnLikedComment ?? 0
            cell.delegate = self
            return cell
        case 03:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "Approve/Disapprove artist request"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnArtistStatusChanged ?? 0)
            cell.indexPath = indexPath.row
            
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnArtistStatusChanged ?? 0
            cell.delegate = self
            return cell
        case 04:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "Approve/Disapprove bank payment request"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnReceiptStatusChanged ?? 0)
            cell.indexPath = indexPath.row
            
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnReceiptStatusChanged ?? 0
            cell.delegate = self
            return cell
        case 05:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "One of my following artists uploaded a new track"
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnNewTrack ?? 0)
            cell.indexPath = indexPath.row
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnNewTrack ?? 0
            cell.delegate = self
            return cell
        case 06:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "One of my followers mentioned me in a comments "
            cell.bind(AppInstance.instance.userProfile?.data?.emailOnReviewedTrack ?? 0)
            cell.indexPath = indexPath.row
            
            cell.valueStatus = AppInstance.instance.userProfile?.data?.emailOnReviewedTrack ?? 0
            cell.delegate = self
            return cell
        case 07:
            let cell = tableView.dequeueReusableCell(withIdentifier:"SettingNotificationItem") as! SettingNotificationItem
            cell.notificationLabel.text = "One of my followers mentioned me in a comment's reply"
            cell.indexPath = indexPath.row
            cell.delegate = self
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
extension SettingNotificationVC:OnNotificationSettingsDelegate{
    func OnNotificationSettingsChanged(value: Int, index: Int, status: Bool) {
        if index == 0{
            updateNotification(key: "email_on_follow_user", Value: value)
        }else if index == 1{
            updateNotification(key: "email_on_liked_track", Value: value)
        }else if index == 2{
            updateNotification(key: "email_on_liked_comment", Value: value)
        }else if index == 3{
            updateNotification(key: "email_on_artist_status_changed", Value: value)
        }else if index == 4{
            updateNotification(key: "email_on_receipt_status_changed", Value: value)
        }else if index == 5{
            updateNotification(key: "email_on_new_track", Value: value)
        }else if index == 6{
            updateNotification(key: "email_on_reviewed_track", Value: value)
        }
        else if index == 7{
            updateNotification(key: "email_on_reviewed_track", Value: value)
        }
    }
    func updateNotification(key:String,Value:Int)  {
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userID = AppInstance.instance.userId ?? 0
        Async.background({
            NotificationManager.instance.updateNotificationSetting(AccessToken: accessToken, userID: userID, key: key, Value: Value) { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.verbose(success ?? "")
                            self.view.makeToast(success ?? "")
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
        })
        
    }
    
}
