//
//  PlaylistPopUpVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 09/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
class PlaylistPopUpVC: UIViewController {
    
    @IBOutlet weak var CLOSE: UIButton!
    @IBOutlet weak var Copy: UIButton!
    @IBOutlet weak var Share: UIButton!
    @IBOutlet weak var EditPlaylist: UIButton!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var DeletePlaylist: UIButton!
    
    var delegate:deletePlaylisttPopupDelegate?
    var updatePlaylistDelegate:updatePlaylistDelegate?
    var copyDelegate:showToastStringDelegate?
    var playlistObject: PlaylistModel.Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CLOSE.setTitle((NSLocalizedString("CLOSE", comment: "")), for: .normal)
        self.Copy.setTitle((NSLocalizedString("Copy", comment: "")), for: .normal)
        self.Share.setTitle((NSLocalizedString("Share", comment: "")), for: .normal)
        self.DeletePlaylist.setTitle((NSLocalizedString("Delete Playlist", comment: "")), for: .normal)
        self.EditPlaylist.setTitle((NSLocalizedString("Edit Playlist", comment: "")), for: .normal)
        self.playlistLabel.text = (NSLocalizedString("Playlist", comment: ""))
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
    
    @IBAction func copyPressed(_ sender: Any){
        UIPasteboard.general.string = playlistObject?.url ?? ""
       self.copyDelegate?.showToastString(string: "Text copied to clipboard")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sharePressed(_ sender: Any){
        self.share(shareString: playlistObject?.url ?? "")
    }
    @IBAction func editPressed(_ sender: Any){
        self.dismiss(animated: true) {
            self.updatePlaylistDelegate?.updatePlaylistPlaylist(status: true, object:self.playlistObject!)
        }
    }
    @IBAction func deletePressed(_ sender: Any){
        self.dismiss(animated: true) {
            self.delegate?.deletePlaylistPopup(status: true, playlistID: self.playlistObject?.id ?? 0)
        }
        
    }
    @IBAction func closePressed(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    private func share(shareString:String?){
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
