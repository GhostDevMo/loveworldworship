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

class ManageSessionsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private  var refreshControl = UIRefreshControl()
    var sessionArray = [SessionModel.Datum]()
    private var fetchSatus:Bool? = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchData()
        
    }
    
    func setupUI(){
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.title = (NSLocalizedString("Manage Sessions", comment: ""))
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.tableView.separatorStyle = .none
        tableView.register(ManageSessionTableItem.nib, forCellReuseIdentifier: ManageSessionTableItem.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        fetchSatus = true
        self.sessionArray.removeAll()
        self.tableView.reloadData()
        self.fetchData()
        
    }
    
    private func fetchData(){
        if fetchSatus!{
            fetchSatus = false
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        }else{
            log.verbose("will not show Hud more...")
        }
        
        self.sessionArray.removeAll()
        self.tableView.reloadData()
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            SessionManager.instance.getSessions(AccessToken: accessToken) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            if (success?.data?.isEmpty)!{
                                self.refreshControl.endRefreshing()
                            }else {
                                
                                self.sessionArray = (success?.data) ?? []
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
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
        
    }
    
}
extension ManageSessionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}


extension ManageSessionsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessionArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:ManageSessionTableItem.identifier) as! ManageSessionTableItem
        cell.vc = self
        let object = self.sessionArray[indexPath.row]
        cell.bind(object, index: indexPath.row)
        
        return cell
    }
    
}
