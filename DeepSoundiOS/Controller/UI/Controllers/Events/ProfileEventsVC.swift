//
//  ProfileEventsVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 14/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import Async

class ProfileEventsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventlistArray = [Events]()
    var parentVC: BaseVC?
    var isOtherUser = false
    var userID:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchUserProfile()
        self.tableView.addPullToRefresh {
            self.eventlistArray.removeAll()
            self.tableView.reloadData()
            self.fetchUserProfile()
        }
    }
    
    private func setupUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(UINib(resource:R.nib.eventShowTableItem), forCellReuseIdentifier: R.reuseIdentifier.eventShowTableItem.identifier)
    }
    
    private func fetchUserProfile() {
        var userId = 0
        if isOtherUser {
            userId = self.userID ?? 0
        }else {
            userId = AppInstance.instance.userId ?? 0
        }
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId,fetch: "events", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.eventlistArray = success?.data?.events ?? []
                            self.tableView.reloadData()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            //self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
}

extension ProfileEventsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventlistArray.count == 0 {
            return 1
        }
        return self.eventlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if eventlistArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
            cell.selectionStyle = .none
            cell.titleLabel.text = "No Events"
            cell.noDataLabel.text = "You don't have any events"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventShowTableItem.identifier) as! EventShowTableItem
        cell.stopSkelting()
        cell.selectionStyle = .none
        let object = self.eventlistArray[indexPath.row]
        cell.bind(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if eventlistArray.count != 0 {
            let vc = R.storyboard.products.eventDetailVC()
            vc?.eventDetailObject = self.eventlistArray[indexPath.row]
            self.parentVC?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if eventlistArray.count == 0 {
            return UITableView.automaticDimension
        }
        return 300.0
    }
}
