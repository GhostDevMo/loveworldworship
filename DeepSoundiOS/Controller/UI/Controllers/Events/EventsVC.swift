//
//  EventsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 22/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class EventsVC: BaseVC {
    

    @IBOutlet weak var tableView: UITableView!
    private var EventlistArray = [[String:Any]]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchMyEvents()
    }
    
    @IBAction func createEventPressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Events", bundle: nil)
         let vc = storyBoard.instantiateViewController(withIdentifier: "CreateEventVC") as! CreateEventVC
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(EventShowTableItem.nib, forCellReuseIdentifier: EventShowTableItem.identifier)
      
        refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
              refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
              self.tableView.addSubview(refreshControl)
        
    }
    @objc func refresh(sender:AnyObject) {
          self.EventlistArray.removeAll()
          self.tableView.reloadData()
        self.fetchMyEvents()
          refreshControl.endRefreshing()
      }
    private func fetchMyEvents(){
        
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                EventManager.instance.getEvents(AccessToken: accessToken, limit: 10, offset: 56) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.EventlistArray = success ?? []
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
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
extension EventsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.EventlistArray.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventShowTableItem.identifier) as? EventShowTableItem
        let object = self.EventlistArray[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.products.eventDetailVC()
        vc?.eventDetailObject = self.EventlistArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
}
