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
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var selectPlayList: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var PlaylistArray = [PlaylistModel.Playlist]()
    private var idsArray = [Int]()
    private var playlistIdString:String? = ""
    var createPlaylistDelegate:createPlaylistDelegate?
    var trackId:Int?  = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.close.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.done.setTitle((NSLocalizedString("DONE", comment: "")), for: .normal)
        self.create.setTitle((NSLocalizedString("CREATE", comment: "")), for: .normal)
        self.selectPlayList.text = (NSLocalizedString("Select a playlist", comment: ""))
        self.setupUI()
        self.fetchPlaylist()
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
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        var stringArray = self.idsArray.map { String($0) }
        self.playlistIdString = stringArray.joined(separator: ",")
        log.verbose("playlistIdString = \(playlistIdString)")
        self.save()
    }
    
    @IBAction func createPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.createPlaylistDelegate?.createPlaylist(status: true)
        }
    }
    
    private func setupUI(){
        
        self.tableView.separatorStyle = .none
        tableView.register(SelectPlaylist_TableCell.nib, forCellReuseIdentifier: SelectPlaylist_TableCell.identifier)
    }
    private func save(){
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let accessToken = AppInstance.instance.accessToken ?? ""
        let trackId = self.trackId ?? 0
        let playlistIdString = self.playlistIdString ?? ""
        
        Async.background({
            PlaylistManager.instance.addToPlaylist(trackId: trackId, AccessToken: accessToken, PlaylistIdString: playlistIdString, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.dismiss(animated: true, completion: {
                                log.debug("statusCODE = \(success?.status ?? 0)")
                                self.view.makeToast(NSLocalizedString(("Song has been added in playlist"), comment: ""))
                            })
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
    
    private func fetchPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.PlaylistArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({ PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? 0)")
                            self.PlaylistArray = success?.playlists ?? []
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
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}
extension SelectAPlaylistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.PlaylistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectPlaylist_TableCell.identifier) as? SelectPlaylist_TableCell
        cell?.delegate = self
        cell?.playListIdArray = self.PlaylistArray
        cell?.indexPath = indexPath.row
        let object = self.PlaylistArray[indexPath.row]
        cell?.playlistNameLabel.text = object.name ?? ""
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
extension SelectAPlaylistVC:didSetPlaylistDelegate{
    
    func didPlaylist(Image: UIImageView, status: Bool, idsArray: [PlaylistModel.Playlist], Index: Int) {
        if status{
            
            Image.image = R.image.ic_checked()
            self.idsArray.append(idsArray[Index].id ?? 0)
            log.verbose("genresIdArray = \(self.idsArray)")
            
        }else{
            
            Image.image = R.image.ic_uncheck()
            for (index,values) in self.idsArray.enumerated(){
                if values == idsArray[Index].id{
                    self.idsArray.remove(at: index)
                    break
                }
                
            }
            log.verbose("genresString = \(playlistIdString)")
            log.verbose("genresIdArray = \(self.idsArray)")
        }
    }
    
    
}
