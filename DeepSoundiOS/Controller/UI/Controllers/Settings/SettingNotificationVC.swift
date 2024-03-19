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
import Toast_Swift

class SettingNotificationVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.tableViewSetup()
    }
    
    // TableView Setup
    func tableViewSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.settingNotificationItem), forCellReuseIdentifier: R.reuseIdentifier.settingNotificationItem.identifier)
    }

}

// MARK: - Extensions

// MARK: TableView Setup
extension SettingNotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingNotificationItem.identifier) as! SettingNotificationItem
        cell.delegate = self
        cell.indexPath = indexPath.row
        switch indexPath.row {
        case 0:
            cell.notificationLabel.text = "Someone followed me"
            switch AppInstance.instance.userProfile?.data?.email_on_follow_user {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 1:
            cell.notificationLabel.text = "Someone like/dislike one of my tracks"
            switch AppInstance.instance.userProfile?.data?.email_on_liked_track {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 02:
            cell.notificationLabel.text = "Someone reviewed one of my tracks"
            switch AppInstance.instance.userProfile?.data?.email_on_reviewed_track {
            case .string(let value):
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value):
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value):
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 03:
            cell.notificationLabel.text = "Someone liked one of my comments"
            switch AppInstance.instance.userProfile?.data?.email_on_liked_comment {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
            return cell
        case 04:
            cell.notificationLabel.text = "Approve/Disapprove artist request(s)"
            switch AppInstance.instance.userProfile?.data?.email_on_artist_status_changed {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
            return cell
        case 05:
            cell.notificationLabel.text = "Approve/Disapprove bank payment request(s)"
            switch AppInstance.instance.userProfile?.data?.email_on_receipt_status_changed {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 06:
            cell.notificationLabel.text = "One of my following artists uploaded a new track"
            switch AppInstance.instance.userProfile?.data?.email_on_new_track {
            case .string(let value) :
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value) :
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value) :
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 07:
            cell.notificationLabel.text = "One of my followers mentioned me in a comment"
            switch AppInstance.instance.userProfile?.data?.email_on_comment_mention {
            case .string(let value):
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value):
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value):
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        case 08:
            cell.notificationLabel.text = "One of my followers mentioned me in a comment's reply"
            switch AppInstance.instance.userProfile?.data?.email_on_comment_replay_mention {
            case .string(let value):
                cell.bind(Int(value) ?? 0)
                cell.valueStatus = Int(value)
            case .integer(let value):
                cell.bind(value)
                cell.valueStatus = Int(value)
            case .double(let value):
                cell.bind(Int(value))
                cell.valueStatus = Int(value)
            case .none:
                break
            }
        default:
            break
        }
        return cell
    }
    
}

// MARK: OnNotificationSettingsDelegate Methods
extension SettingNotificationVC: OnNotificationSettingsDelegate {
    
    func OnNotificationSettingsChanged(value: Int, index: Int, status: Bool) {
        switch index {
        case 0:
            self.updateNotification(key: "email_on_follow_user", value: value)
        case 1:
            self.updateNotification(key: "email_on_liked_track", value: value)
        case 2:
            self.updateNotification(key: "email_on_reviewed_track", value: value)
        case 3:
            self.updateNotification(key: "email_on_liked_comment", value: value)
        case 4:
            self.updateNotification(key: "email_on_artist_status_changed", value: value)
        case 5:
            self.updateNotification(key: "email_on_receipt_status_changed", value: value)
        case 6:
            self.updateNotification(key: "email_on_new_track", value: value)
        case 7:
            self.updateNotification(key: "email_on_comment_mention", value: value)
        case 8:
            self.updateNotification(key: "email_on_comment_replay_mention", value: value)
        default:
            break
        }
    }
    
    func updateNotification(key: String, value: Int) {
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userID = AppInstance.instance.userId ?? 0
        Async.background {
            NotificationManager.instance.updateNotificationSetting(AccessToken: accessToken, userID: userID, key: key, Value: value) { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.verbose(success ?? "")
                            self.view.makeToast(success ?? "")
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
}
