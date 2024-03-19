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
import EmptyDataSet_Swift

class StationsFullVC: BaseVC {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    var stationArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        self.tableview.separatorStyle = .none
        self.tableview.register(UINib(resource: R.nib.stationsTableItem), forCellReuseIdentifier: R.reuseIdentifier.stationsTableItem.identifier)
        searchTF.placeholder = NSLocalizedString("Search...", comment: "Search...")
        searchTF.delegate = self
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
    }
    
    private func fetchStations(keyWord:String){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                stationManager.instance.getStations(AccessToken: accessToken, keyword: keyWord) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.stationArray = success ?? []
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
        return self.stationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.stationsTableItem.identifier) as! StationsTableItem
        // cell.delegate = self
        cell.vc = self
        cell.selectionStyle = .none
        let object = self.stationArray[indexPath.row]
        cell.bind(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
extension StationsFullVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let keyword = textField.text ?? ""
        self.fetchStations(keyWord: keyword)
    }
}

extension StationsFullVC: addStationDelegate {
    func addStation(object: [String : Any]) {
        
    }
}

// MARK: - EmptyView Delegate Methods -
extension StationsFullVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Sad No Result!....", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "We cannot find keyword you are searching for maybe a little spelling mistake?", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
}
