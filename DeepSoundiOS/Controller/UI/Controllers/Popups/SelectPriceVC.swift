//
//  SelectPriceVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 24/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class SelectPriceVC: BaseVC {

    @IBOutlet weak var CLOSE: UIButton!
    @IBOutlet weak var DONE: UIButton!
    @IBOutlet weak var ChoosePrice: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate:getPriceStringDelegate!
    
    private var priceArray = [PriceModel.Datum]()
    private var idsArray = [Int]()
    private var nameArray = [String]()
    private var priceIdString:String? = ""
    private var priceNameString:String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CLOSE.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.DONE.setTitle((NSLocalizedString("DONE", comment: "")), for: .normal)
        self.ChoosePrice.text = (NSLocalizedString("Choose Price", comment: ""))
        self.setupUI()
        self.fetchPrices()
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
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.selectPrice_TableCell), forCellReuseIdentifier: R.reuseIdentifier.selectPrice_TableCell.identifier)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        let stringArray = self.idsArray.map { String($0) }
        self.priceIdString = stringArray.joined(separator: ",")
        log.verbose("priceIdString = \(priceIdString ?? "")")
        
        let nameStringArray = self.nameArray.map { String($0) }
        self.priceNameString = nameStringArray.joined(separator: ",")
        log.verbose("priceNameString = \(priceNameString ?? "")")
        self.dismiss(animated: true) {
            self.delegate.getPriceString(String: self.priceIdString ?? "",nameString:self.priceNameString ?? "")
        }
    }
        
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func fetchPrices() {
        self.showProgressDialog(text: "Loading...")
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                PriceManager.instance.getPrice(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.data ?? [])")
                                self.priceArray = success?.data ?? []
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
        }
    }
}
extension SelectPriceVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.priceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectPrice_TableCell.identifier, for: indexPath) as? SelectPrice_TableCell
        cell?.priceNameLabel.text = "$\(self.priceArray[indexPath.row].price ?? "")"
        cell?.delegate = self
        cell?.priceIdArray = self.priceArray
        cell?.indexPath = indexPath.row
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }  
}

extension SelectPriceVC:didSetPriceDelegate{
    
    func didSetPrice(Image: UIImageView, status: Bool, idsArray: [PriceModel.Datum], Index: Int) {
        if status{
            Image.image = R.image.icCheckbox()
            self.idsArray.append(idsArray[Index].id ?? 0)
            self.nameArray.append(idsArray[Index].price ?? "")
            log.verbose("priceIdArray = \(self.idsArray)")
            log.verbose("nameArray = \(self.nameArray)")
        }else{
            Image.image = R.image.ic_uncheck()
            for (index,values) in self.idsArray.enumerated(){
                if values == idsArray[Index].id{
                    self.idsArray.remove(at: index)
                    break
                }
            }
            for (index,values) in self.nameArray.enumerated(){
                if values == idsArray[Index].price{
                    self.nameArray.remove(at: index)
                    break
                }
            }
            log.verbose("genresString = \(priceIdString)")
            log.verbose("priceIdArray = \(self.idsArray)")
            log.verbose("nameArray = \(self.nameArray)")
        }
    }
    
}
