//
//  UploadAlbumVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

import Async
import DropDown
import DeepSoundSDK
import SwiftEventBus

class UploadAlbumVC: BaseVC {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var genresBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var songTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var selectPictureBtn: UIButton!
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    private var selectedImage:UIImage? = nil
    private var priceString:String? = ""
    private var genresString:String? = ""
    
    var albumObject:UpdateAlbumModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.createBtn.backgroundColor = .ButtonColor
        self.selectPictureBtn.borderColorV = .ButtonColor
        self.selectPictureBtn.setTitleColor(.ButtonColor, for: .normal)
        
        self.textViewPlaceHolder()
        
        self.topLabel.text = NSLocalizedString("Create and share Album. Each Album is custom created and organized to help you find the best music for your preference.", comment: "Create and share Album. Each Album is custom created and organized to help you find the best music for your preference.")
        self.selectPictureBtn.setTitle(NSLocalizedString("Select Pictures", comment: "Select Pictures"), for: .normal)
        self.songTitleTextField.placeholder = NSLocalizedString("Album Title", comment: "Album Title")
        self.genresBtn.setTitle(NSLocalizedString("Genres", comment: "Genres"), for: .normal)
        self.priceBtn.setTitle(NSLocalizedString("Price", comment: "Price"), for: .normal)
        self.createBtn.setTitle("CREATE", for: .normal)
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
    
    
    @IBAction func pricePressed(_ sender: Any) {
        let vc = R.storyboard.popups.selectPriceVC()
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @IBAction func genresPressed(_ sender: Any) {
        let vc = R.storyboard.popups.selectGenresVC()
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @IBAction func selectPicturePressed(_ sender: Any) {
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
    @IBAction func crossPressed(_ sender: Any) {
        self.trackImage.image = R.image.imagePlacholder()
        self.crossBtn.isHidden = true
        
    }
    
    @IBAction func createPressed(_ sender: Any) {
        if self.songTitleTextField.text!.isEmpty{
            self.view.makeToast("Enter Album name")
            
        }else if self.crossBtn.isHidden{
            self.view.makeToast("Please select Album image")
        }else{
            self.uploadThumbnail(thumbnailData: (self.selectedImage?.jpegData(compressionQuality: 0.1))!)
        }
        
    }
    private func setupUI(){
        self.title = NSLocalizedString("Upload Album", comment: "")
        self.crossBtn.isHidden = true
        
        if self.albumObject != nil{
                   self.crossBtn.isHidden = false
                   self.title = NSLocalizedString("Upload Album", comment: "")
                   self.createBtn.setTitle("UPDATE", for: .normal)
            self.songTitleTextField.text = self.albumObject?.title ?? ""
            self.descriptionTextView.text = self.albumObject?.description ?? ""
                 
            self.genresBtn.setTitle(self.albumObject?.genre ?? "", for: .normal)
            self.priceBtn.setTitle(String(self.albumObject?.price ?? 0.0), for: .normal)
                  
                   let imageThumb = URL.init(string:self.albumObject?.imageString ?? "")
                          trackImage.sd_setImage(with: imageThumb , placeholderImage:R.image.imagePlacholder())
                   self.selectedImage = trackImage.image
                   
               }
    }
    private func textViewPlaceHolder(){
        descriptionTextView.delegate = self
        descriptionTextView.text = "Your Description here..."
        descriptionTextView.textColor = UIColor.lightGray
        
    }
    
    private func uploadThumbnail(thumbnailData:Data){
        
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrackThumbnail(AccesToken: accessToken, thumbnailData:thumbnailData) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.thumbnail ?? "")")
                               
                                if self.albumObject != nil{
                                                                    self.updateAlbum(thumbnailString: success?.thumbnail ?? "")
                                                               }else{
                                                                     self.submitAlbum(thumbnailString: success?.thumbnail ?? "")
                                                               }
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
                }
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func submitAlbum(thumbnailString:String){
        
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let title = self.songTitleTextField.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let genre = self.genresString ?? ""
            let price = self.priceString ?? ""
            Async.background({
                AlbumManager.instance.submitAlbum(AccessToken: accessToken, AlbumTitle: title, AlbumDescription: description, AlbumGenreGenresString: genre, AlbumPriceString: price, thumbnailPath: thumbnailString) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.navigationController?.popViewController(animated: true)
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
                }
                
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func updateAlbum(thumbnailString:String){
          
          if Connectivity.isConnectedToNetwork(){
              self.showProgressDialog(text: "Loading...")
              let accessToken = AppInstance.instance.accessToken ?? ""
              let title = self.songTitleTextField.text ?? ""
              let description = self.descriptionTextView.text ?? ""
              let genre = self.genresString ?? ""
              let price = self.priceString ?? ""
            var albumID = self.albumObject?.AlbumID ?? ""
              Async.background({

                AlbumManager.instance.updateAlbum(AccessToken: accessToken,albumID:albumID, AlbumTitle: title, AlbumDescription: description, AlbumGenreGenresString: genre, AlbumPriceString: price, thumbnailPath: thumbnailString) { (success, sessionError, error) in
                      if success != nil{
                          Async.main({
                              self.dismissProgressDialog {
                                   self.view.makeToast("Album has been updated")
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
                  }
                  
              })
          }else{
              log.error("internetErrro = \(InterNetError)")
              self.view.makeToast(InterNetError)
          }
      }
}


extension UploadAlbumVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            self.descriptionTextView.text = ""
            textView.textColor = UIColor.black
        }
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        if textView.text.isEmpty {
            textView.text = "Your Description here..."
            textView.textColor = UIColor.lightGray
        }
        
    }
    
}

extension UploadAlbumVC:getGenresStringDelegate{
    func getGenresString(String: String,nameString:String) {
        self.genresString  = String
        self.genresBtn.setTitle(nameString, for: .normal)
        log.verbose("String to send on =\(String)")
    }
    
}
extension UploadAlbumVC:getPriceStringDelegate{
    func getPriceString(String: String,nameString:String) {
        self.priceString = String
        self.priceBtn.setTitle(nameString, for: .normal)
        log.verbose("String to send on =\(String)")
    }
}

extension  UploadAlbumVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.trackImage.image = image
        self.selectedImage = image ?? UIImage()
        if self.selectedImage == nil{
            self.crossBtn.isHidden = true
        }else{
            self.crossBtn.isHidden = false;
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

