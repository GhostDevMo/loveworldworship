//
//  UpdatePlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class UpdatePlaylistVC: BaseVC {
    
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistNameTextField: UITextField!
    
    @IBOutlet weak var selectPictureBtn: UIButton!
    var playlistObject: Playlist?
    private let imagePickerController = UIImagePickerController()
    private var privacyText:Int? = 1
    private var selectedImage:UIImage? = nil
    
    var object :UpdatePlayLISTModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.playlistNameTextField.placeholder = NSLocalizedString("Playlist Name here ", comment: "Playlist Name here ")
        self.privacyLabel.text = NSLocalizedString("Privacy", comment: "Privacy")
        self.publicLabel.text = NSLocalizedString("Public", comment: "Public")
        self.privateLabel.text = NSLocalizedString("Private", comment: "Private")
        self.updateBtn.setTitle(NSLocalizedString("UPDATE", comment: "UPDATE"), for: .normal)
        self.topLabel.text = NSLocalizedString("Cerate and share playlist. Each playlist is custom created and organized to help you find the best music for your preference.", comment: "Cerate and share playlist. Each playlist is custom created and organized to help you find the best music for your preference.")
        self.selectPictureBtn.setTitle(NSLocalizedString("Select Pictures", comment: "Select Pictures"), for: .normal)
        self.updateBtn.backgroundColor = .ButtonColor
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func privatePressed(_ sender: UIButton) {
        self.privateBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.publicBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 0
    }
    @IBAction func publicPressed(_ sender: UIButton) {
        self.publicBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.privateBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 1
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
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func crossPressed(_ sender: UIButton) {
        self.playlistImage.image = R.image.imagePlacholder()
        self.crossBtn.isHidden = true
        
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        if self.playlistNameTextField.text!.isEmpty{
            self.view.makeToast("Enter playlist name")
            
        }else if self.playlistImage.image == R.image.imagePlacholder(){
            self.view.makeToast("Please select playlist image")
        }else{
              self.updatePlaylist()
        }
      
    }
    
    private func setupUI(){
        self.title = "Update Playlist"
        self.playlistNameTextField.text = object?.title ?? ""
        if (self.object?.imageString!.isEmpty)!{
            self.crossBtn.isHidden = true
        }else{
            self.crossBtn.isHidden = false
        }
        let url = URL.init(string:object?.imageString ?? "")
        self.playlistImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        self.selectedImage = self.playlistImage.image
        if self.object?.privacy == 1{
            self.publicBtn.setImage(R.image.ic_check_radio(), for: .normal)
            self.privateBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        }else{
            self.privateBtn.setImage(R.image.ic_check_radio(), for: .normal)
            self.publicBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        }
        
    }
    
    private func updatePlaylist(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let thumbnailData = self.selectedImage?.jpegData(compressionQuality: 0.2)
            let accessToken = AppInstance.instance.accessToken ?? ""
            let playlistId = object?.playlistID ?? 0
            let privacy = self.privacyText ?? 0
            let name = self.playlistNameTextField.text ?? ""
            Async.background({
                PlaylistManager.instance.updatePlaylist(PlaylistId: playlistId, AccesToken: accessToken, Name: name, Privacy: privacy, Thumbnail_data: thumbnailData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.view.makeToast("Playlist has been updated")
                               
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
extension  UpdatePlaylistVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.playlistImage.image = image
        self.selectedImage = image 
        if self.selectedImage == nil{
            self.crossBtn.isHidden = true
        }else{
            self.crossBtn.isHidden = false;
        }
        self.dismiss(animated: true, completion: nil)
    }
}
