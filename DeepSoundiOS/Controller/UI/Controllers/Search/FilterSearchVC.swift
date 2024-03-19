//
//  FilterSearchVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 24/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK

class FilterSearchVC: UIViewController, PanModalPresentable {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var ApplyFilterBtn: UIButton!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var panScrollable: UIScrollView?
    var categoryID:String?
    var shortFormHeight: PanModalHeight {
        return .contentHeight(350.0)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(350.0)
    }
    
    var priceString:String? = ""
    var genresString:String? = ""
    private var pricceIdArray = [Int]()
    private var genrecIdArray = [Int]()
    private let imageArray = [
        R.image.icn_dollar_1(),
        R.image.ic_musicType()
    ]
    private let nameArray = ["Price", "Genres"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Filter", comment: "Filter")
        self.selectAllBtn.setTitle(NSLocalizedString("Select All", comment: "Select All"), for: .normal)
        self.ApplyFilterBtn.setTitle(NSLocalizedString("APPLY FILTER", comment: "APPLY FILTER"), for: .normal)
        self.ApplyFilterBtn.backgroundColor = .ButtonColor
        self.selectAllBtn.setTitleColor(.ButtonColor, for: .normal)
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
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        selectAll()
    }
    @IBAction func applyFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_FILTER, userInfo: ["priceString":self.priceString ?? "", "genresString":self.genresString ?? ""])
        })
    }
    
    private func setupUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let XIB = UINib(resource: R.nib.selectFilter_TableCell)
        self.tableView.register(XIB, forCellReuseIdentifier: R.reuseIdentifier.selectFilter_TableCell.identifier)
    }
    
    private func selectAll(){
        self.priceString  = ""
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PriceManager.instance.getPrice(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.data ?? [])")
                            success?.data?.forEach({ (it) in
                                self.pricceIdArray.append(it.id ?? 0)
                            })
                            let priceStringMap = self.pricceIdArray.map { String($0)}
                            self.priceString = priceStringMap.joined(separator: ",")
                            log.verbose("priceString = \(self.priceString ?? "")")
                            self.fetchGenres()
                        })
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                        })
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func fetchGenres() {
        self.genresString = ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.debug("userList = \(success?.data ?? [])")
                        success?.data?.forEach({ (it) in
                            self.genrecIdArray.append(it.id ?? 0)
                        })
                        let genresStringMap = self.genrecIdArray.map { String($0)}
                        self.genresString = genresStringMap.joined(separator: ",")
                        log.verbose("priceString = \(self.genresString ?? "")")
                        self.dismiss(animated: true, completion: {
                            SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_FILTER, userInfo: ["priceString":self.priceString ?? "", "genresString":self.genresString ?? ""])
                        })
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.view.makeToast(sessionError?.error ?? "")
                        log.error("sessionError = \(sessionError?.error ?? "")")
                    })
                }else {
                    Async.main({
                        self.view.makeToast(error?.localizedDescription ?? "")
                        log.error("error = \(error?.localizedDescription ?? "")")
                    })
                }
            })
        })
    }
}
extension FilterSearchVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectFilter_TableCell.identifier, for: indexPath) as? SelectFilter_TableCell
        cell?.selectionStyle = .none
        cell?.filterIcon.image = self.imageArray[indexPath.row]
        cell?.filterTextLabel.text = self.nameArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = R.storyboard.popups.selectGenresVC()
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
            
        }else if indexPath.row == 0 {
            let vc = R.storyboard.popups.selectPriceVC()
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
}

extension FilterSearchVC:getGenresStringDelegate{
    func getGenresString(String: String,nameString:String) {
        self.genresString  = String
        log.verbose("String to send on =\(String)")
    }
}

extension FilterSearchVC:getPriceStringDelegate{
    func getPriceString(String: String,nameString:String) {
        self.priceString = String
        log.verbose("String to send on =\(String)")
    }
}
