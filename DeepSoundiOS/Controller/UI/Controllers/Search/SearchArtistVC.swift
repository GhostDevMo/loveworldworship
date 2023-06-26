//
//  SearchArtistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import Async
import DeepSoundSDK

class SearchArtistVC: BaseVC {
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
    private let randomString:String? = "a"
    private var artistArray = [SearchModel.Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH) { result in
            self.dismissProgressDialog {
                 self.artistArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let artistResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.artistArray = artistResult?.artist ?? []
                log.verbose("SongsCount = \(artistResult?.artist?.count)")
                self.tableView.reloadData()
            }
            
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                self.artistArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let artistResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                self.artistArray = artistResult?.artist ?? []
                log.verbose("SongsCount = \(artistResult?.artist?.count)")
                self.tableView.reloadData()
            }
            
        }
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
    
    
    @IBAction func searchPressed(_ sender: Any) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["keyword":randomString])
    }
    private func setupUI(){
        //        self.tableView.isHidden = true
        self.tableView.separatorStyle = .none
        tableView.register(SearchArtist_TableCell.nib, forCellReuseIdentifier: SearchArtist_TableCell.identifier)
        self.tableView.register(ArtistTableCell.nib, forCellReuseIdentifier: ArtistTableCell.identifier)
    }
    @objc func didTapFollowArtist(sender:UIButton){
        
        let userId = self.artistArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        if artistArray[sender.tag].lastFollowID == 0{
            
            sender.backgroundColor = UIColor.white
            sender.setTitle((NSLocalizedString(("Following"), comment: "")), for: .normal)
            sender.setTitleColor((UIColor.hexStringToUIColor(hex:  "FFA143")), for: .normal)
            sender.borderColorV = UIColor.ButtonColor
            sender.borderWidthV = 0.5
            self.followUser(index: sender.tag)
            
        }else{
            sender.backgroundColor = .ButtonColor
            sender.setTitle((NSLocalizedString(("Follow"), comment: "")), for: .normal)
            sender.setTitleColor(UIColor.white, for: .normal)
            self.unFollowUser(index: sender.tag)
        }
    }
    
}
extension SearchArtistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTableCell.identifier) as? ArtistTableCell
       // cell?.loggedHomeVC = self
        cell?.selectionStyle = .none
        cell?.btnMore.tag = indexPath.row
        cell?.btnMore.addTarget(self, action: #selector(didTapFollowArtist(sender:)), for: .touchUpInside)
        cell?.bindSearchArtist(artistArray[indexPath.row])
        return cell!
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.artistArray[indexPath.row].artist == 0{
            let vc = R.storyboard.dashboard.showProfileVC()
            vc?.userID  = self.artistArray[indexPath.row].id ?? 0
            vc?.profileUrl = self.artistArray[indexPath.row].url ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            let vc = R.storyboard.discover.userInfoVC()
            vc?.artistSearchObject = self.artistArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
extension SearchArtistVC:followUserDelegate{
    func followUser(index: Int, button: UIButton, status: Bool) {
        let userId = self.artistArray[index].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast("you cannot follow to yourself!")
            return
        }
        if status{
            
            button.backgroundColor = UIColor.hexStringToUIColor(hex: "FFA143")
            button.setTitle("Following", for: .normal)
            button.setTitleColor(.white, for: .normal)
            self.followUser(index: index)
            
        }else{
            button.backgroundColor = .white
            button.setTitle("Follow", for: .normal)
            button.borderColorV = UIColor.hexStringToUIColor(hex:  "FFA143")
            button.setTitleColor(UIColor.hexStringToUIColor(hex:  "FFA143"), for: .normal)
            self.unFollowUser(index: index)
        }
    }
    func followUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.artistArray[index].id ?? 0
            if userId == AppInstance.instance.userId {
                self.view.makeToast("you cannot follow to yourself!")
                return
            }
            
            self.showProgressDialog(text: "Loading...")
            Async.background({
                
                FollowManager.instance.followUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been Followed")
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    func unFollowUser(index: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.artistArray[index].id ?? 0
            
            self.showProgressDialog(text: "Loading...")
            Async.background({
                FollowManager.instance.unFollowUser(Id: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("User has been unfollowed")
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

extension SearchArtistVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("ARTIST", comment: "ARTIST"))
    }
}
