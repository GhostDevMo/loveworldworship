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
import Toast_Swift

class NotificationVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    // MARK: - Properties
    
    private var notifcationArray = [Notifiations]()
    private var isLoading = true
    
    // MARK: - View life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchNotification()
        self.showLabel.text = NSLocalizedString("There is no Notification", comment: "There is no Notification")
        self.showImage.tintColor = .mainColor
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
    
    // MARK: - Selectors
    
    @IBAction func notificationSettingsPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.settings.settingNotificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: - Helper Functions
extension NotificationVC {
    
    private func setupUI() {
        self.title = NSLocalizedString("Notification", comment: "Notification")
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.tableView.addPullToRefresh {
            self.refresh()
        }
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.notifications_TableCell), forCellReuseIdentifier: R.reuseIdentifier.notifications_TableCell.identifier)
    }
    
    private func refresh() {
        self.isLoading = true
        self.notifcationArray.removeAll()
        self.tableView.reloadData()
        self.fetchNotification()
    }
    
}

// MARK: API Services
extension NotificationVC {
    
    private func fetchNotification() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            _ = AppInstance.instance.userId ?? 0
            Async.background {
                NotificationManager.instance.getNotification(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    self.tableView.stopPullToRefresh()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.notifiations ?? [])")
                                self.notifcationArray = success?.notifiations ?? []
                                if self.notifcationArray.isEmpty {
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                } else {
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                }
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UITableView Delegate and Datasource methods
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }
        return self.notifcationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notifications_TableCell.identifier) as? Notifications_TableCell
            cell?.startSkelting()
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notifications_TableCell.identifier) as? Notifications_TableCell
        cell?.stopSkelting()
        cell?.selectedBackgroundView()
        cell?.selectionStyle = .none
        let object = self.notifcationArray[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let object = self.notifcationArray[indexPath.row]
            switch object.n_type {
            case "new_track", "status_changed":
                if let newVC = R.storyboard.discover.artistDetailsVC() {
                    newVC.artistObject = object.uSER_DATA
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            case "follow_user", "liked_track":
                let vc = R.storyboard.dashboard.showProfile2VC()
                vc?.userID  = object.uSER_DATA?.id ?? 0
                self.navigationController?.pushViewController(vc!, animated: true)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
}
