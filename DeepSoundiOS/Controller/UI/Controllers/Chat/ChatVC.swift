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
class ChatVC: BaseVC {
    
    @IBOutlet weak var noMsgLabel: UILabel!
    @IBOutlet weak var noMsgImage: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    var chatMessagesArray: [GetChatsModel.Datum] = []
    private var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.noMsgImage.tintColor = .mainColor
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.fetchChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupUI(){
        
        self.title = "Chats"
        self.noMsgImage.isHidden = true
        self.noMsgLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register(ChatTableItem.nib, forCellReuseIdentifier: ChatTableItem.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        self.chatMessagesArray.removeAll()
        self.tableView.reloadData()
        self.fetchChats()
        refreshControl.endRefreshing()
    }
    //MARK: - Methods
    private func fetchChats(){
        if Connectivity.isConnectedToNetwork(){
            chatMessagesArray.removeAll()
            
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            Async.background({
                ChatManager.instance.getChats(AccessToken: accessToken, limit: 10, offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                
                                self.chatMessagesArray = success?.data ?? []
                                
                                if self.chatMessagesArray.isEmpty{
                                    
                                    self.noMsgImage.isHidden = false
                                    self.noMsgLabel.isHidden = false
                                }else{
                                    self.noMsgImage.isHidden = true
                                    self.noMsgLabel.isHidden = true
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
                }
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatMessagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableItem.identifier, for: indexPath) as! ChatTableItem
        
        if chatMessagesArray.count == 0{
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let object = chatMessagesArray[indexPath.row]
        cell.bind(object)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object = chatMessagesArray[indexPath.row]
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.toUserId  = object.user.id ?? 0
        vc?.usernameString = object.user.username ?? ""
        vc?.lastSeenString =  object.user.lastActive ?? 0
        vc?.profileImageString = object.user.avatar ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
}
