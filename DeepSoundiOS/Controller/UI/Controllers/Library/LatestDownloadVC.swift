//
//  LatestDownloadVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus

class LatestDownloadVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var downloadSongsArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showImage.tintColor = .mainColor
        self.setupUI()
        self.getDownloadSongs()
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
    
    private func setupUI(){
        self.showLabel.text = (NSLocalizedString("You have not download any song yet", comment: ""))
        self.title = (NSLocalizedString("Latest Download", comment: ""))
        self.tableView.separatorStyle = .none
        tableView.register(LatestDownload_TableCell.nib, forCellReuseIdentifier: LatestDownload_TableCell.identifier)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    private func getDownloadSongs(){
        var allData =  UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song)
        if allData.isEmpty{
            self.tableView.isHidden = true
            self.showImage.isHidden = false
            self.showLabel.isHidden = false
        }else{
            self.tableView.isHidden = false
            self.showImage.isHidden = true
            self.showLabel.isHidden = true
            log.verbose("all data = \(allData)")
            for data in allData{
                let musicObject = try? PropertyListDecoder().decode(MusicPlayerModel.self ,from: data)
                if musicObject != nil{
                    log.verbose("musicObject = \(musicObject?.trackId)")
                    self.downloadSongsArray.append(musicObject!)
                    
                }else{
                    log.verbose("Nil values cannot be append in Array!")
                }
            }
        }
    }
    
}
extension LatestDownloadVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloadSongsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.downloadSongsArray.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
            cell?.selectionStyle = .none
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: LatestDownload_TableCell.identifier) as? LatestDownload_TableCell
            cell?.selectionStyle = .none
            
            cell?.vc = self
            let object = self.downloadSongsArray[indexPath.row]
            cell?.bind(object, index: indexPath.row)
            return cell!
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        popupContentController!.popupItem.title = self.downloadSongsArray[indexPath.row].name ?? ""
        popupContentController!.popupItem.subtitle = self.downloadSongsArray[indexPath.row].title ?? ""
        let cell  = tableView.cellForRow(at: indexPath) as? LatestDownload_TableCell
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
        AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        
        self.addToRecentlyWatched(trackId: self.downloadSongsArray[indexPath.row].trackId ?? 0)
        AppInstance.instance.popupPlayPauseSong = false
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = self.downloadSongsArray[indexPath.row]
            self.popupContentController!.musicArray = self.downloadSongsArray
            self.popupContentController!.currentAudioIndex = indexPath.row
            self.popupContentController?.setup()
            
            
        })
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.downloadSongsArray.count == 0{
            return 500.0
        }else{
            return 120.0
        }
    }
    
}

extension
LatestDownloadVC:showReportScreenDelegate{
    func showReportScreen(Status: Bool, IndexPath: Int,songLink:String) {
        if Status{
            let vc = R.storyboard.popups.reportVC()
            vc?.Id = self.downloadSongsArray[IndexPath].trackId ?? 0
            vc?.songLink = self.downloadSongsArray[IndexPath].audioString ?? ""
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
}
extension LatestDownloadVC:showToastStringDelegate{
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
}
