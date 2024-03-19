//
//  ManageSessionsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import Toast_Swift
import DeepSoundSDK

class ManageSessionsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private  var refreshControl = UIRefreshControl()
    var sessionArray: [SessionModel.Datum] = []
    private var fetchSatus = true
    var deleteIndexPath = IndexPath(row: 0, section: 0)
    
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
        self.fetchData()
    }
    
    // TableView Setup
    func tableViewSetup() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.manageSessionTableItem), forCellReuseIdentifier: R.reuseIdentifier.manageSessionTableItem.identifier)
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        self.fetchSatus = true
        self.sessionArray.removeAll()
        self.tableView.reloadData()
        self.fetchData()
    }
    
}

//MARK: - Extensions

// MARK: Api Call
extension ManageSessionsVC {
    
    private func fetchData() {
        if Connectivity.isConnectedToNetwork() {
            if self.fetchSatus {
                self.fetchSatus = false
                self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            } else {
                log.verbose("will not show Hud more...")
            }
            self.sessionArray.removeAll()
            self.tableView.reloadData()
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                SessionManager.instance.getSessions(AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                if (success?.data?.isEmpty)! {
                                    self.refreshControl.endRefreshing()
                                } else {
                                    self.sessionArray = (success?.data) ?? []
                                    self.tableView.reloadData()
                                    self.refreshControl.endRefreshing()
                                }
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
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func deleteSession(id: Int, indexPath: IndexPath) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                SessionManager.instance.deleteSession(AccessToken: accessToken, id: id) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.sessionArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.view.makeToast(sessionError?.error ?? "")
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    } else {
                        Async.main {
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension ManageSessionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.manageSessionTableItem.identifier) as! ManageSessionTableItem
        let object = self.sessionArray[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.bind(object)
        return cell
    }
    
}

// MARK: ManageSessionCellDelegate Methods
extension ManageSessionsVC: ManageSessionCellDelegate {
    
    func handleCloseButtonTap(indexPath: IndexPath) {
        self.deleteIndexPath = indexPath
        if let alertPopupVC = R.storyboard.popups.alertPopupVC(){
            alertPopupVC.delegate = self
            alertPopupVC.titleText = "Warning"
            alertPopupVC.messageText = "Are you sure you want to log out from this device?"
            alertPopupVC.okText = "OK"
            alertPopupVC.cancelText = "CANCEL"
            self.present(alertPopupVC, animated: true, completion: nil)
            alertPopupVC.okButton.tag = indexPath.row
        }
    }
    
}

// MARK: AlertPopupVCDelegate Methods
extension ManageSessionsVC: AlertPopupVCDelegate {
    
    func alertPopupOKButtonPressed(_ sender: UIButton) {
        let id = self.sessionArray[self.deleteIndexPath.row].id ?? 0
        self.deleteSession(id: id, indexPath: self.deleteIndexPath)
    }
    
}
