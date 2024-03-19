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
    @IBOutlet weak var addButton: UIButton!
    
    var isLoading = true
    private var eventlistArray = [Events]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchMyEvents()
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.events.createEventVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.eventShowTableItem), forCellReuseIdentifier: R.reuseIdentifier.eventShowTableItem.identifier)
        self.addButton.addShadow(offset: .init(width: 0, height: 4))
        self.tableView.addPullToRefresh {
            self.eventlistArray.removeAll()
            self.isLoading = true
            self.tableView.reloadData()
            self.fetchMyEvents()
        }
    }
    
    private func fetchMyEvents() {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                EventManager.instance.getEvents(AccessToken: accessToken, limit: 10, offset: 0) { success, sessionError, error in
                    if success != nil {
                        self.tableView.stopPullToRefresh()
                        Async.main({
                            self.dismissProgressDialog {
                                let data = success?.data ?? []
                                self.eventlistArray = data.filter { event in
                                    print((event.time ?? 0))
                                    return Int(Date().timeIntervalSince1970) < (event.time ?? 0)
                                }
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
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

extension EventsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return 5
        }else {
            return self.eventlistArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventShowTableItem.identifier) as? EventShowTableItem
            cell?.startSkelting()
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventShowTableItem.identifier) as? EventShowTableItem
            cell?.stopSkelting()
            cell?.selectionStyle = .none
            let object = self.eventlistArray[indexPath.row]
            cell?.bind(object)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.products.eventDetailVC()
            vc?.eventDetailObject = self.eventlistArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}
