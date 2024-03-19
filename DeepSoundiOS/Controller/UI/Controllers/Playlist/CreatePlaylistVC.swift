//
//  CreatePlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 20/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import Toast_Swift

class CreatePlaylistVC: BaseVC, PanModalPresentable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var lblPrivacyTittle: UITextField!
    @IBOutlet weak var playlistNameTextField: UITextField!
    @IBOutlet weak var lblHeader: UILabel!
    
    // MARK: - Properties
    
    var panScrollable: UIScrollView?
    private let imagePickerController = UIImagePickerController()
    private var privacy: Int? = 0
    private var selectedImage: UIImage? = nil
    var selectedPlayList: Playlist?
    var shortFormHeight: PanModalHeight {
        return .contentHeight(525.0)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(525.0)
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
    
    // MARK: - Selectors
   
    @IBAction func showPrivacyView(_ sender: UIButton) {
        guard let newVC = R.storyboard.popups.privacyPopupVC() else { return }
        newVC.delegate = self
        self.present(newVC, animated: true)
    }
    
    @IBAction func selectPicturePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        if self.playlistNameTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Enter playlist name")
            return
        }
        
        if self.playlistImage.image == nil {
            self.view.makeToast("Please select playlist image")
            return
        }
        
        if sender.currentTitle == "Update" {
            self.updatePlaylist()
            return
        } else {
            self.createPlaylist()
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        if let selectedPlayList = selectedPlayList {
            self.lblHeader.text = "Update PlayList"
            self.createBtn.setTitle("Update", for: .normal)
            self.lblPrivacyTittle.text = selectedPlayList.privacy_text
            self.playlistNameTextField.text = selectedPlayList.name
            let url = URL(string: selectedPlayList.thumbnail_ready ?? "")
            self.playlistImage.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
            self.privacy = selectedPlayList.privacy
        } else {
            self.lblPrivacyTittle.text = "Public"
            self.lblHeader.text = "Create PlayList"
        }
    }
    
    private func createPlaylist() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let thumbnailData = self.selectedImage?.jpegData(compressionQuality: 0.2)
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let privacy = self.privacy ?? 0
            let name = self.playlistNameTextField.text ?? ""
            Async.background {
                PlaylistManager.instance.createPlaylist(userId: userId, AccesToken: accessToken, Name: name, Privacy: privacy, Thumbnail_data: thumbnailData, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                SwiftEventBus.postToMainThread("ReloadPlayListData")
                                self.dismiss(animated: true, completion: {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.appDelegate.window?.rootViewController?.view.makeToast("Playlist has been created")
                                })
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
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func updatePlaylist() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let thumbnailData = self.selectedImage?.jpegData(compressionQuality: 0.2)
            let accessToken = AppInstance.instance.accessToken ?? ""
            let playlistId = self.selectedPlayList?.id ?? 0
            let privacy = self.privacy ?? 0
            let name = self.playlistNameTextField.text ?? ""
            Async.background({
                PlaylistManager.instance.updatePlaylist(PlaylistId: playlistId, AccesToken: accessToken, Name: name, Privacy: privacy, Thumbnail_data: thumbnailData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                SwiftEventBus.postToMainThread("ReloadPlayListData")
                                self.dismiss(animated: true, completion: {
                                    log.debug("success = \(success?.status ?? 0)")
                                    self.appDelegate.window?.rootViewController?.view.makeToast("Playlist has been updated")
                                })
                            }
                        })
                    }else if sessionError != nil {
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
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: PrivacyPopupDelegate
extension CreatePlaylistVC: PrivacyPopupDelegate {
    
    func selectedPrivacyType(_ text: String) {
        self.privacy = (text == "Public") ? 0 : 1
        self.lblPrivacyTittle.text = text
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension CreatePlaylistVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.playlistImage.image = image
            self.selectedImage = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
