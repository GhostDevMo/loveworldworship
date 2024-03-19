//
//  MyAddressesVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import Toast_Swift
import DeepSoundSDK

class MyAddressesVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Properties
    
    var addressArray: [AddressData] = []
    private var refreshControl = UIRefreshControl()
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - Selectors    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Add Button Action
    @IBAction func addButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.settings.createAddressVC() {
            newVC.delegate = self
            newVC.isEditAddress = false
            newVC.headerTitle = "Create Address"
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupUI()
        self.tableViewSetup()
        self.getAddress()
    }
    
    private func setupUI() {
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        self.showImage.tintColor = .mainColor
        self.showLabel.text = (NSLocalizedString("no address", comment: ""))
        self.addButton.addShadow(offset: .init(width: 0, height: 4))
    }
    
    // TableView Setup
    func tableViewSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.myAddressCell), forCellReuseIdentifier: R.reuseIdentifier.myAddressCell.identifier)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender: AnyObject) {
        self.addressArray = []
        self.tableView.reloadData()
        self.getAddress()
    }

}

// MARK: - Extensions

// MARK: Api Call
extension MyAddressesVC {
    
    private func getAddress() {
        if Connectivity.isConnectedToNetwork() {
            self.addressArray = []
            let access_token = AppInstance.instance.accessToken ?? ""
            Async.background {
                AddressManger.instance.getAddress(access_token: access_token, completionBlock: { (success, sessionError, error) in
                    self.refreshControl.endRefreshing()
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.addressArray = success?.data ?? []
                                if self.addressArray.count == 0 {
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                } else {
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                }
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
    
    private func deleteAddress(id: Int, index: Int) {
        if Connectivity.isConnectedToNetwork() {
            let access_token = AppInstance.instance.accessToken ?? ""
            Async.background {
                AddressManger.instance.deleteAddress(access_token: access_token, id: id, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message)
                                self.addressArray.remove(at: index)
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

// MARK: TableView Setup
extension MyAddressesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myAddressCell.identifier, for: indexPath) as! MyAddressCell
        let address = self.addressArray[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setData(object: address)
        return cell
    }
    
}

// MARK: MyAddressCellDelegate Methods
extension MyAddressesVC: MyAddressCellDelegate {
    
    func handleEditButtonTap(indexPath: IndexPath) {
        let address = self.addressArray[indexPath.row]
        if let newVC = R.storyboard.settings.createAddressVC() {
            newVC.delegate = self
            newVC.isEditAddress = true
            newVC.address = address
            newVC.headerTitle = "Edit Address"
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func handleDeleteButtonTap(indexPath: IndexPath) {
        if let alertPopupVC = R.storyboard.popups.alertPopupVC(){
            alertPopupVC.delegate = self
            alertPopupVC.titleText = "Delete Address"
            alertPopupVC.messageText = "Are You Sure Delete Address"
            alertPopupVC.okText = "YES"
            alertPopupVC.cancelText = "NO"
            self.present(alertPopupVC, animated: true, completion: nil)
            alertPopupVC.okButton.tag = indexPath.row
        }
    }
    
}

// MARK: AlertPopupVCDelegate Methods
extension MyAddressesVC: AlertPopupVCDelegate {
    
    func alertPopupOKButtonPressed(_ sender: UIButton) {
        let address = self.addressArray[sender.tag]
        self.deleteAddress(id: address.id ?? 0, index: sender.tag)
    }
    
}

// MARK: CreateAddressVCDelegate Methods
extension MyAddressesVC: CreateAddressVCDelegate {
    
    func refreshAddressData() {
        self.getAddress()
    }
    
}
