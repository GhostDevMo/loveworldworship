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
    
    private let randomString:String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
    private var artistArray = [Publisher]()
    private var isLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                if let isTyping = result?.userInfo?[AnyHashable("isTyping")] as? Bool, isTyping {
                    if !self.isLoading {
                        self.artistArray.removeAll()
                        self.isLoading = true
                        self.tableView.reloadData()
                        return
                    }
                }
                if let artistResult = result?.userInfo?[AnyHashable("receiveResult")] as? SearchModel.DataClass {
                    self.artistArray = artistResult.artist ?? []
                    let isHidden = self.artistArray.count == 0
                    self.showImage.isHidden = !isHidden
                    self.showStack.isHidden = !isHidden
                    self.searchBtn.isHidden = !isHidden
                    log.verbose("SongsCount = \(artistResult.artist?.count ?? 0)")
                    self.isLoading = false
                    self.tableView.reloadData()
                    return
                }
            }
        }
        
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
    
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["isRandomSearch": true])
    }
    private func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.artistTableCell), forCellReuseIdentifier: R.reuseIdentifier.artistTableCell.identifier)
    }
}

extension SearchArtistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }else {
            return self.artistArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
            cell.selectionStyle = .none
            cell.startSkelting()
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.artistTableCell.identifier, for: indexPath) as! ArtistTableCell
            cell.stopSkelting()
            cell.selectionStyle = .none
            cell.btnFollow.tag = indexPath.row
            cell.delegate = self
            cell.bind(artistArray[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            if self.artistArray[indexPath.row].artist == 0 {
                let vc = R.storyboard.dashboard.showProfile2VC()
                vc?.userID  = self.artistArray[indexPath.row].id ?? 0
//                vc?.profileUrl = self.artistArray[indexPath.row].url ?? ""
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                let vc = R.storyboard.discover.artistDetailsVC()
                vc?.artistObject = self.artistArray[indexPath.row]
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Warning Popup Delegate Methods -
extension SearchArtistVC: WarningPopupVCDelegate {
    func warningPopupOKButtonPressed(_ sender: UIButton,_ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        }else if sender.tag == 1003 {
            let newVC = R.storyboard.settings.settingWalletVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
}

// MARK: - Follow or UnFollow User Delegate Methods -
extension SearchArtistVC: followUserDelegate {
    func followUser(_ index: Int, _ sender: UIButton) {
        if !AppInstance.instance.isLoginUser {
            self.showLoginAlert(delegate: self)
            return
        }
        let userId = self.artistArray[sender.tag].id ?? 0
        if userId == AppInstance.instance.userId {
            self.view.makeToast(NSLocalizedString(("you cannot follow to yourself!"), comment: ""))
            return
        }
        artistArray[sender.tag].is_following = !(artistArray[sender.tag].is_following)
        if sender.currentTitle == "Follow" {
            sender.setTitle("Following", for: .normal)
            sender.backgroundColor = .hexStringToUIColor(hex: "FFF8ED")
            sender.setTitleColor(.mainColor, for: .normal)
            self.followUser(userId: userId)
        }else {
            sender.setTitle("Follow", for: .normal)
            sender.backgroundColor = .mainColor
            sender.setTitleColor(.white, for: .normal)
            self.unFollowUser(userId: userId)
        }
    }
    
    func followUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
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
    
    func unFollowUser(userId: Int) {
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
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
