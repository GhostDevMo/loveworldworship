//
//  StationsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 08/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class StationsFullVC: BaseVC {

    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    private lazy var searchBar = UISearchBar(frame: .zero)
    
    var stationArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    private func setupUI(){
        self.tableview.separatorStyle = .none
        self.tableview.register(StationsTableItem.nib, forCellReuseIdentifier: StationsTableItem.identifier)
        searchBar.placeholder = NSLocalizedString("Search...", comment: "Search...")
            searchBar.delegate = self
        navigationItem.titleView = searchBar
        self.searchImage.isHidden = false
        self.showStack.isHidden = false
    }
    private func fetchStations(keyWord:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                stationManager.instance.getStations(AccessToken: accessToken, keyword: keyWord) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.stationArray = success ?? []
                                if self.stationArray.isEmpty {
                                     self.searchImage.isHidden = false
                                    self.showStack.isHidden = false
                                }else{
                                    self.searchImage.isHidden = true
                                   self.showStack.isHidden = true
                                }
                                self.tableview.reloadData()
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

extension StationsFullVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stationArray.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableItem.identifier) as? StationsTableItem
//        cell.delegate = self
        cell?.vc = self
        cell?.selectionStyle = .none
        let object = self.stationArray[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
extension StationsFullVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        let keyword = searchBar.text ?? ""
        self.fetchStations(keyWord: keyword)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
    }
}
extension StationsFullVC: addStationDelegate{
    func addStation(object: [String : Any]) {
       
    }
}
