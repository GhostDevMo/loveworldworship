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
import Toast_Swift
import SDWebImage
import EmptyDataSet_Swift

class BlockUsersVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var blockUsersArray = [Publisher]()
    private var fetchSatus: Bool? = true
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    deinit {
        SwiftEventBus.unregister(self)
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
        self.tableViewSetUp()
        self.fetchBlockUsers()
    }
    
    // TableView SetUp
    func tableViewSetUp() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.blockedUsers_TableCell), forCellReuseIdentifier: R.reuseIdentifier.blockedUsers_TableCell.identifier)
        self.tableView.addPullToRefresh {
            self.tableView.reloadEmptyDataSet()
            self.blockUsersArray.removeAll()
            self.tableView.reloadData()
            self.fetchBlockUsers()
        }
    }
    
    private func fetchBlockUsers() {
        if Connectivity.isConnectedToNetwork() {
            if fetchSatus! {
                fetchSatus = false
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            } else {
                log.verbose("will not show Hud more...")
            }
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                BlockUsersManager.instance.getBlockUsers(Id: userId, AccessToken: accessToken, Offset: 0, Limit: 5, completionBlock: { (success, sessionError, error) in
                    Async.main {
                        self.tableView.stopPullToRefresh()
                    }
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.blockUsersArray = success?.data?.data ?? []
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
    
    private func UnblockUserPopup(id: Int, name: String, index: Int) {
        self.view.endEditing(true)
        guard let newVC = R.storyboard.popups.unblockUserPopUpVC() else {return}
        newVC.id = id
        newVC.name = name
        newVC.successHandler = { success in
            if success {
                self.fetchBlockUsers()
            }
        }
        self.present(newVC, animated: true)
    }
    
    private func unblockUser(id: Int, index: Int) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                BlockUsersManager.instance.unBlockUser(Id: id, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.blockUsersArray.remove(at: index)
                                self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension BlockUsersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.blockedUsers_TableCell.identifier) as! BlockedUsers_TableCell
        cell.selectionStyle = .none
        let object = self.blockUsersArray[indexPath.row]
        cell.usernameLabel.text = object.name ?? ""
        let url = URL.init(string: object.avatar ?? "")
        cell.userProfileImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.UnblockUserPopup(id:  self.blockUsersArray[indexPath.row].id ?? 0,
                              name:  self.blockUsersArray[indexPath.row].name ?? "",
                              index: indexPath.row)
    }
}

extension BlockUsersVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Users Found", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24), .foregroundColor : UIColor.textColor])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You don't have any block users.", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}
