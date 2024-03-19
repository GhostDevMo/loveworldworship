//
//  AlbumsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import Async
import Toast_Swift

class AlbumsVC: BaseVC {
    
    // MARK: - IBOutles
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var albumsArray = [Album]()
    var parentVC: BaseVC?
    var isOtherUser = false
    var userID: Int?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchUserProfile()
        self.tableView.addPullToRefresh {
            self.albumsArray.removeAll()
            self.tableView.reloadData()
            self.fetchUserProfile()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.profileAlbumsTableCell), forCellReuseIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier)
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
    }
    
    private func fetchUserProfile() {
        var userId = 0
        if isOtherUser {
            userId = self.userID ?? 0
        } else {
            userId = AppInstance.instance.userId ?? 0
        }
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, fetch: "albums", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.albumsArray = success?.data?.albums?.first ?? []
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
                            // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension AlbumsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if albumsArray.count == 0 {
            return 1
        }
        return albumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if albumsArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
            cell.titleLabel.text = "No Albums"
            cell.noDataLabel.text = "You have no Albums in list"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
        cell.selectionStyle = .none
        let object = albumsArray[indexPath.row]
        cell.bind(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if albumsArray.count == 0 {
            return UITableView.automaticDimension
        }
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if albumsArray.count != 0 {
            let vc = R.storyboard.dashboard.showAlbumVC()
            vc?.albumObject = albumsArray[indexPath.row]
            self.parentVC?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}
