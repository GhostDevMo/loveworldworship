//
//  SelectAPlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class SelectAPlaylistVC: BaseVC {
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var selectPlayList: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var playlistArray = [Playlist]()
    private var selectedIndexPath: IndexPath?
    private var playlistIdString:Int?
    var createPlaylistDelegate: createPlaylistDelegate?
    var trackId:Int?  = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchPlaylist()
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
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        if self.playlistIdString == nil {
            self.view.makeToast("Please Select Playlist")
            return
        }
        self.save()
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.createPlaylistDelegate?.createPlaylist(status: true)
        }
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.selectPlaylist_TableCell), forCellReuseIdentifier: R.reuseIdentifier.selectPlaylist_TableCell.identifier)
    }
    
    private func save() {
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.trackId ?? 0
            let playlistIdString = self.playlistIdString ?? 0
            Async.background({
                PlaylistManager.instance.addToPlaylist(trackId: trackId, AccessToken: accessToken, PlaylistIdString: playlistIdString, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.dismiss(animated: true, completion: {
                                    log.debug("statusCODE = \(success?.status ?? 0)")
                                    self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString(("Song has been added in playlist"), comment: ""))
                                })
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func fetchPlaylist() {
        if Connectivity.isConnectedToNetwork(){
            self.playlistArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.playlistArray = success?.playlists ?? []
                                self.tableView.reloadData()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    if self.tableView.contentSize.height > (self.view.frame.height * 0.6) {
                                        self.tableViewHeight.constant = (self.view.frame.height * 0.6)
                                    } else {
                                        self.tableViewHeight.constant = self.tableView.contentSize.height
                                    }
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
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}
extension SelectAPlaylistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectPlaylist_TableCell.identifier) as! SelectPlaylist_TableCell
        cell.playListIdArray = self.playlistArray
        cell.indexPath = indexPath.row
        let object = self.playlistArray[indexPath.row]
        cell.playlistNameLabel.text = object.name ?? ""
        let image = (self.selectedIndexPath == indexPath) ? R.image.icon_checkmark() : R.image.icon_uncheckmark()
        cell.checkImage.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.playlistArray[indexPath.row]
        self.selectedIndexPath = indexPath
        self.playlistIdString = object.id
        self.tableView.reloadData()
    }
}
