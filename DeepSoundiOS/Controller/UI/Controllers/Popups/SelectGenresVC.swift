//
//  SelectGenresVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 24/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class SelectGenresVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DONE: UIButton!
    @IBOutlet weak var Close: UIButton!
    @IBOutlet weak var ChooseGenres: UILabel!
    
    var delegate:getGenresStringDelegate!
    private var genresArray = [GenresModel.Datum]()
    private var idsArray = [Int]()
    private var nameArray = [String]()
    private var genresIdString:String? = ""
   private var genresNameString:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Close.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.DONE.setTitle((NSLocalizedString("DONE", comment: "")), for: .normal)
        self.ChooseGenres.text = (NSLocalizedString("Choose Genres", comment: ""))
        self.setupUI()
        self.fetchGenres()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        var stringArray = self.idsArray.map { String($0) }
        self.genresIdString = stringArray.joined(separator: ",")
        log.verbose("genresIdString = \(self.genresIdString)")
        
        var nameStringArray = self.nameArray.map { String($0) }
        self.genresNameString = nameStringArray.joined(separator: ",")
        log.verbose("priceNameString = \(self.genresNameString)")
        self.dismiss(animated: true) {
            self.delegate.getGenresString(String: self.genresIdString ?? "", nameString: self.genresNameString ?? "")
          
        }
    }
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        tableView.register(SelectGenres_TableCell.nib, forCellReuseIdentifier: SelectGenres_TableCell.identifier)
    }
    
    private func fetchGenres(){
        self.genresArray.removeAll()
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.data ?? [])")
                            self.genresArray = success?.data ?? []
                            self.tableView.reloadData()
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
            })
        })
    }
}
extension SelectGenresVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectGenres_TableCell.identifier) as? SelectGenres_TableCell
        cell?.genresNameLabel.text = self.genresArray[indexPath.row].cateogryName ?? ""
        cell?.delegate = self
        cell?.genresIdArray = self.genresArray
        cell?.indexPath = indexPath.row
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
}
extension SelectGenresVC:didSetGenrestDelegate{
    func didSetGenres(Image: UIImageView, status: Bool, idsArray: [GenresModel.Datum], Index: Int) {
        if status{
            
            Image.image = R.image.ic_checked()
            self.idsArray.append(idsArray[Index].id ?? 0)
             self.nameArray.append(idsArray[Index].cateogryName ?? "")
            log.verbose("genresIdArray = \(self.idsArray)")
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
                if values == idsArray[Index].cateogryName{
                    self.nameArray.remove(at: index)
                    break
                }
            }
            log.verbose("genresString = \(genresIdString)")
            log.verbose("genresIdArray = \(self.idsArray)")
             log.verbose("nameArray = \(self.nameArray)")
        }
    }
}
