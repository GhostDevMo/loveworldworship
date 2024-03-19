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
    var playlistObject: Playlist?
    var productDelegate: ProductDetailsDelegate?
    
    var isProduct = false
    var isEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        if isProduct {
            self.DeletePlaylist.isHidden = true
            self.EditPlaylist.isHidden = true
            self.playlistLabel.text = "Product"
        }
        
        if isEvent {
            self.DeletePlaylist.isHidden = true
            self.EditPlaylist.isHidden = true
            self.playlistLabel.text = "Events"
        }
    }
    
    @IBAction func copyPressed(_ sender: UIButton) {
        if isProduct || isEvent {
            self.dismiss(animated: true) {
                self.productDelegate?.copyBtn(sender)
            }
            return
        }
        UIPasteboard.general.string = playlistObject?.url ?? ""
       self.copyDelegate?.showToastString(string: "Text copied to clipboard")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(_ sender: UIButton){
        if isProduct || isEvent {
            self.dismiss(animated: true) {
                self.productDelegate?.shareBtn(sender)
            }
            return
        }
        self.share(shareString: playlistObject?.url ?? "")
    }
    
    @IBAction func editPressed(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.updatePlaylistDelegate?.updatePlaylistPlaylist(status: true, object:self.playlistObject!)
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.delegate?.deletePlaylistPopup(status: true, playlistID: self.playlistObject?.id ?? 0)
        }
        
    }
    
    @IBAction func closePressed(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func share(shareString:String?) {
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
