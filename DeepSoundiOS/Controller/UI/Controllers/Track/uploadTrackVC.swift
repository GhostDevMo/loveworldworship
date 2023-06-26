//
//  uploadTrackVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 31/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DropDown
import DeepSoundSDK
import SwiftEventBus

class uploadTrackVC: BaseVC {
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var ageBtn: UIButton!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var genresBtn: UIButton!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var songTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    private let moreDropdown = DropDown()
    private let moreDropDown1 = DropDown()
    private let imagePickerController = UIImagePickerController()
    private var privacyText:Int? = 1
    private var selectedImage:UIImage? = nil
    private var priceString:String? = ""
    private var genresString:String? = ""
    private var ageRestriction:Int? = 0
    private var downloadPermission:Int? = 0
    var songLink:String? = ""
    
    @IBOutlet weak var selectPicture: UIButton!
    var trackObject:UpdateTrackModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.customizeDropdown()
        self.customizeDownloadDropdown()
        self.textViewPlaceHolder()
        self.createBtn.backgroundColor = .ButtonColor
        self.selectPicture.borderColorV = .ButtonColor
        self.selectPicture.setTitleColor(.ButtonColor, for: .normal)
        
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
        if self.trackObject != nil{
            self.crossBtn.isHidden = false

            self.title = "Update Single Song"
            self.createBtn.setTitle("UPDATE", for: .normal)
            self.songTitleTextField.text = self.trackObject?.trackTitle ?? ""
            self.descriptionTextView.text = self.trackObject?.trackDescription ?? ""
            self.lyricsTextView.text = self.trackObject?.trackLyrics ?? ""
            self.tagsTextField.text = self.trackObject?.tags ?? ""
            self.genresBtn.setTitle(self.trackObject?.genres ?? "", for: .normal)
            self.priceBtn.setTitle(String(self.trackObject?.price ?? 0.0), for: .normal)
            if self.trackObject?.availability == 0{
                self.privateBtn.setImage(R.image.ic_check_radio(), for: .normal)
                self.publicBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
                self.privacyText = 0
            }else {
                self.publicBtn.setImage(R.image.ic_check_radio(), for: .normal)
                self.privateBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
                self.privacyText = 1
            }
            if self.trackObject?.ageRestriction == 0 {
                self.ageBtn.setTitle("All ages can listen this song", for: .normal)
                self.ageRestriction = 0
            }else {
                self.ageBtn.setTitle("Only +18", for: .normal)
                self.ageRestriction = 1
            }
            if self.trackObject?.downloads == 0{
                self.downloadBtn.setTitle("NO", for: .normal)
                self.downloadPermission = 0
            }else{
                self.downloadBtn.setTitle("YES", for: .normal)
                self.downloadPermission = 1
            }
            let imageThumb = URL.init(string:self.trackObject?.trackImage ?? "")
                   trackImage.sd_setImage(with: imageThumb , placeholderImage:R.image.imagePlacholder())
            self.selectedImage = trackImage.image
            
        }
    }
    
    
    
    @IBAction func downloadBtnPressed(_ sender: Any) {
        moreDropDown1.show()
    }
    @IBAction func agePressed(_ sender: Any) {
        moreDropdown.show()
        
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
    @IBAction func privatePressed(_ sender: Any) {
        self.privateBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.publicBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 0
    }
    @IBAction func publicPressed(_ sender: Any) {
        self.publicBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.privateBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 1
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
            self.view.makeToast("Enter playlist name")
            
        }else if self.crossBtn.isHidden{
            self.view.makeToast("Please select Track image")
        }else{
            self.uploadThumbnail(thumbnailData: (self.selectedImage?.jpegData(compressionQuality: 0.1))!)
        }
        
    }
    private func setupUI(){
        self.title = "Upload Single Song"
        self.crossBtn.isHidden = true
        self.publicBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.privateBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
    }
    private func textViewPlaceHolder(){
        descriptionTextView.delegate = self
        descriptionTextView.text = "Your Description here..."
        descriptionTextView.textColor = UIColor.lightGray
        
        lyricsTextView.delegate = self
        lyricsTextView.text = "Your Lyrics here..."
        lyricsTextView.textColor = UIColor.lightGray
    }
    func customizeDropdown(){
        moreDropdown.dataSource = [
            "All ages can listen this song",
            "Only +18"
        ]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.ageBtn
        moreDropdown.width = self.ageBtn.frame.width
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.ageBtn.setTitle(item, for: .normal)
                self.ageRestriction = 0 ?? 0
            }else if index == 1{
                self.ageBtn.setTitle(item, for: .normal)
                self.ageRestriction = 1 ?? 0
            }
            print("Index = \(index)")
        }
    }
    func customizeDownloadDropdown(){
        moreDropDown1.dataSource = [
            "Yes",
            "No"
        ]
        moreDropDown1.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropDown1.textColor = UIColor.white
        moreDropDown1.anchorView = self.ageBtn
        moreDropDown1.width = self.ageBtn.frame.width
        moreDropDown1.direction = .any
        moreDropDown1.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.downloadBtn.setTitle(item, for: .normal)
                self.downloadPermission = 1 ?? 0
            }else if index == 1{
                self.downloadBtn.setTitle(item, for: .normal)
                self.downloadPermission = 0 ?? 0
            }
            print("Index = \(index)")
        }
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
                                if self.trackObject != nil{
                                     self.updateTrack(thumbnailString: success?.thumbnail ?? "")
                                }else{
                                     self.submitTrack(thumbnailString: success?.thumbnail ?? "")
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
    
    private func submitTrack(thumbnailString:String){
        
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let title = self.songTitleTextField.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let tags = self.tagsTextField.text ?? ""
            let genre = self.genresString ?? ""
            let price = self.priceString ?? ""
            let privacy = self.privacyText ?? 0
            let restriction = self.ageRestriction ?? 0
            let downloads = self.downloadPermission ?? 0
            let lyrics = self.lyricsTextView.text ?? ""
            Async.background({
                TrackManager.instance.submitTrack(AccessToken: accessToken, SongTitle: title, SongDescription: description, SongTag: tags, SongGenresString: genre, SongPriceString: price, SongAvailibility: privacy, SongRestriction:restriction, Song_Path: self.songLink ?? "", thumbnailPath: thumbnailString,downloads:downloads,lyrics: lyrics) { (success, sessionError, error) in
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
    private func updateTrack(thumbnailString:String){
           
           if Connectivity.isConnectedToNetwork(){
               self.showProgressDialog(text: "Loading...")
               let accessToken = AppInstance.instance.accessToken ?? ""
            let songID = self.trackObject?.songID ?? ""
               let title = self.songTitleTextField.text ?? ""
               let description = self.descriptionTextView.text ?? ""
               let tags = self.tagsTextField.text ?? ""
               let genre = self.genresString ?? ""
               let price = self.priceString ?? ""
               let privacy = self.privacyText ?? 0
               let restriction = self.ageRestriction ?? 0
               let downloads = self.downloadPermission ?? 0
               let lyrics = self.lyricsTextView.text ?? ""
               Async.background({
                TrackManager.instance.updateTrack(AccessToken: accessToken,songID: songID, SongTitle: title, SongDescription: description, SongTag: tags, SongGenresString: genre, SongPriceString: price, SongAvailibility: privacy, SongRestriction:restriction, thumbnailPath: thumbnailString,downloads:downloads,lyrics: lyrics) { (success, sessionError, error) in
                       if success != nil{
                           Async.main({
                               self.dismissProgressDialog {
                                self.view.makeToast("Song has been updated")
                                   
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

extension uploadTrackVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.descriptionTextView{
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                self.descriptionTextView.text = ""
                textView.textColor = UIColor.black
            }
        }else{
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                self.lyricsTextView.text = ""
                textView.textColor = UIColor.black
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == self.descriptionTextView{
            if textView.text.isEmpty {
                textView.text = "Your Description here..."
                textView.textColor = UIColor.lightGray
            }
        }else{
            if textView.text.isEmpty {
                textView.text = "Your Lyrics here..."
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
}

extension uploadTrackVC:getGenresStringDelegate{
    func getGenresString(String: String,nameString:String) {
        self.genresString  = String
        self.genresBtn.setTitle(nameString, for: .normal)
        log.verbose("String to send on =\(String)")
    }
    
    
}
extension uploadTrackVC:getPriceStringDelegate{
    func getPriceString(String: String,nameString:String) {
        self.priceString = String
        self.priceBtn.setTitle(nameString, for: .normal)
        log.verbose("String to send on =\(String)")
    }
}

extension  uploadTrackVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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

