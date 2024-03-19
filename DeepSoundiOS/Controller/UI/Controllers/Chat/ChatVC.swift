//
//  ChatVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/12/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import Toast_Swift

class ChatVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emptyView: UIStackView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Properties
    
    var chatMessagesArray: [ChatConversationModel] = []
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.tableView.addPullToRefresh {
            self.chatMessagesArray.removeAll()
            self.tableView.reloadData()
            self.fetchChats()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.fetchChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.chatScreenTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatScreenTableItem.identifier)
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension ChatVC {
    
    private func fetchChats() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                ChatManager.instance.getChats(AccessToken: accessToken, limit: 10, offset: 0) { (success, sessionError, error) in
                    Async.main {
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.stopPullToRefresh()
                    }
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.chatMessagesArray = success?.data ?? []
                                if self.chatMessagesArray.isEmpty {
                                    self.emptyView.isHidden = false
                                } else {
                                    self.emptyView.isHidden = true
                                    self.tableView.reloadData()
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
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatMessagesArray.count == 0 {
            return 0
        }
        return chatMessagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatScreenTableItem.identifier, for: indexPath) as! ChatScreenTableItem
        if chatMessagesArray.count == 0 {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let object = chatMessagesArray[indexPath.row]
        cell.selectedImageView.isHidden = true
        cell.bind(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = chatMessagesArray[indexPath.row]
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.userData = object.user
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
