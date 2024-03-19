//
//  PlayListBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by iMac on 13/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import Toast_Swift

protocol PlayListBottomSheetDelegate {
    func editButton(_ sender: UIButton, object: Playlist)
}

class PlayListBottomSheetController: BaseVC, PanModalPresentable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var lblSongCount: UILabel!
    @IBOutlet weak var lblPlaylistName: UILabel!
    @IBOutlet weak var imgPlaylist: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    // MARK: - Properties
    
    var delegate: PlayListBottomSheetDelegate?
    var selectedPlaylist: Playlist? {
        didSet {
            if let selectedPlaylist = self.selectedPlaylist {
                self.bind(selectedPlaylist)
            }
        }
    }
    var panScrollable: UIScrollView?
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        if let selectedPlaylist = self.selectedPlaylist {
            self.bind(selectedPlaylist)
        }
    }
    
    init(playlist: Playlist, delegate: PlayListBottomSheetDelegate) {
        super.init(nibName: PlayListBottomSheetController.name, bundle: nil)
        self.selectedPlaylist = playlist
        self.delegate = delegate
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let str = self.selectedPlaylist?.url {
            self.share(shareString: str)
        }
    }
    
    @IBAction func editPlaylistButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) { [self] in
            if let object = selectedPlaylist {
                self.delegate?.editButton(sender, object: object)
            }
        }
    }
    
    @IBAction func deletePlaylistButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let warningPopupVC = R.storyboard.popups.warningPopupVC()
        warningPopupVC?.delegate = self
        warningPopupVC?.titleText = "Delete your playlist"
        warningPopupVC?.messageText = "Are you sure you want to delete this playlist?"
        warningPopupVC?.okText = "Delete"
        warningPopupVC?.cancelText = "Cancel"
        self.present(warningPopupVC!, animated: true, completion: nil)
        warningPopupVC?.okButton.tag = 10001
    }
    
}

// MARK: - Extensions

// MARK: Helper Functions
extension PlayListBottomSheetController {
    
    func setupUI() {
        topCorners(bgView: self.mainView, cornerRadius: 24, maskToBounds: true)
    }
    
    func bind(_ object: Playlist) {
        let thumbnailURL = URL.init(string: object.thumbnail_ready ?? "")
        self.imgPlaylist.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblPlaylistName.text = object.name ?? ""
        self.lblSongCount.text = "\(object.songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs"))"
    }
    
    private func share(shareString: String) {
        let someText:String = shareString
        let objectsToShare:URL = URL(string: shareString)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

// MARK: WarningPopupVCDelegate
extension PlayListBottomSheetController: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 10001 {
            if let object = self.selectedPlaylist?.id {
                self.deletePlaylist(playlistID: object)
            }
        }
    }
    
    private func deletePlaylist(playlistID: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                PlaylistManager.instance.deletePlaylist(playlistId: playlistID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                SwiftEventBus.postToMainThread("ReloadPlayListData")
                                self.dismiss(animated: true)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            }
        } else {
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(InterNetError)
            }
        }
    }
    
}
