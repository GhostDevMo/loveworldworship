//
//  UploadTrackVC.swift
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
import Toast_Swift

class UploadTrackVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var songTitleTextField: UITextField!
    @IBOutlet weak var songTitleTextFieldView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var lyricsTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var tagsTextFieldView: UIView!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var ageRestrictionTextField: UITextField!
    @IBOutlet weak var allowDownloadsTextField: UITextField!
    @IBOutlet weak var publishButton: UIButton!
    
    // MARK: - Properties
    
    var uploadTrackModel: UploadTrackModel?
    private let moreDropdown = DropDown()
    private let moreDropDown1 = DropDown()
    private let imagePickerController = UIImagePickerController()
    private var privacyText: Int? = 1
    private var selectedImage: UIImage? = nil
    private var priceString: String? = ""
    private var genresString: String? = ""
    private var ageRestriction: Int? = 0
    private var downloadPermission:Int? = 0
    var trackObject: UpdateTrackModel?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Genres Button Action
    @IBAction func genresButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.popups.selectGenresVC()
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    // Price Button Action
    @IBAction func priceButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.popups.selectPriceVC()
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    // Age Restriction Button Action
    @IBAction func ageRestrictionButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        moreDropdown.show()
    }
    
    // Download Button Action
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        moreDropDown1.show()
    }
    
    // Private Radio Button Action
    @IBAction func privateButtonAction(_ sender: UIButton) {
        self.privateButton.setImage(R.image.ic_check_radio(), for: .normal)
        self.publicButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 0
    }
    
    // Public Radio Button Action
    @IBAction func publicButtonAction(_ sender: UIButton) {
        self.publicButton.setImage(R.image.ic_check_radio(), for: .normal)
        self.privateButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.privacyText = 1
    }
    
    // Upload Image Button Action
    @IBAction func uploadImageButtonAction(_ sender: UIButton) {
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
    
    // Publish Button Action
    @IBAction func publishButtonAction(_ sender: UIButton) {
        if self.songTitleTextField.text!.isEmpty{
            self.view.makeToast("Enter playlist name")
        } else if self.trackImage.image == nil {
            self.view.makeToast("Please select Track image")
        } else {
            self.uploadThumbnail(thumbnailData: (self.selectedImage?.jpegData(compressionQuality: 0.1))!)
        }
        
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.textFieldSetUp()
        self.textViewSetup()
        self.setupUI()
        self.customizeDropdown()
        self.customizeDownloadDropdown()
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
    
    func textFieldSetUp() {
        self.songTitleTextField.attributedPlaceholder = NSAttributedString(
            string: "Song Title",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
        self.songTitleTextField.delegate = self
        self.tagsTextField.attributedPlaceholder = NSAttributedString(
            string: "Tag(s)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
        self.tagsTextField.delegate = self
        self.genresTextField.attributedPlaceholder = NSAttributedString(
            string: "Genres",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
        self.priceTextField.attributedPlaceholder = NSAttributedString(
            string: "Price",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
        self.ageRestrictionTextField.attributedPlaceholder = NSAttributedString(
            string: "Age Restriction",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
        self.allowDownloadsTextField.attributedPlaceholder = NSAttributedString(
            string: "Allow Downloads",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textColor as Any]
        )
    }
    
    func textViewSetup() {
        self.descriptionTextView.textContainer.lineFragmentPadding = 0
        self.descriptionTextView.textContainerInset = .zero
        self.descriptionTextView.contentInset = .zero
        self.descriptionTextView.addPlaceholder("Description", with: UIColor.textColor)
        self.descriptionTextView.delegate = self
        
        self.lyricsTextView.textContainer.lineFragmentPadding = 0
        self.lyricsTextView.textContainerInset = .zero
        self.lyricsTextView.contentInset = .zero
        self.lyricsTextView.addPlaceholder("Lyrics", with: UIColor.textColor)
        self.lyricsTextView.delegate = self
    }
    
    func setTextViewHeight(textView: UITextView) -> Double {
        textView.sizeToFit()
        if textView.text.isEmpty || textView.contentSize.height <= 100 {
            return 100
        } else {
            return textView.contentSize.height
        }
    }
    
    private func setupUI() {
        self.headerLabel.text = "Upload Song"
        self.publishButton.setTitle("Publish", for: .normal)
        self.publicButton.setImage(R.image.ic_check_radio(), for: .normal)
        self.privateButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.titleLabel.text = "Add All information about this audio file " + (self.uploadTrackModel?.file_name ?? "")
        self.setData()
    }
    
    func setData() {
        if self.trackObject != nil {
            self.headerLabel.text = "Edit Song"
            self.publishButton.setTitle("Submit", for: .normal)
            self.songTitleTextField.text = self.trackObject?.trackTitle ?? ""
            self.descriptionTextView.text = self.trackObject?.trackDescription ?? ""
            self.lyricsTextView.text = self.trackObject?.trackLyrics ?? ""
            self.tagsTextField.text = self.trackObject?.tags ?? ""
            self.genresTextField.text = self.trackObject?.genres ?? ""
            self.priceTextField.text = String(self.trackObject?.price ?? 0.0)
            
            if self.trackObject?.availability == 0 {
                self.privateButton.setImage(R.image.ic_check_radio(), for: .normal)
                self.publicButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
                self.privacyText = 0
            } else {
                self.publicButton.setImage(R.image.ic_check_radio(), for: .normal)
                self.privateButton.setImage(R.image.ic_uncheck_radio(), for: .normal)
                self.privacyText = 1
            }
            
            if self.trackObject?.ageRestriction == 0 {
                self.ageRestrictionTextField.text = "All ages can listen this song"
                self.ageRestriction = 0
            } else {
                self.ageRestrictionTextField.text = "Only +18"
                self.ageRestriction = 1
            }
            
            if self.trackObject?.downloads == 0 {
                self.allowDownloadsTextField.text = "NO"
                self.downloadPermission = 0
            } else {
                self.allowDownloadsTextField.text = "YES"
                self.downloadPermission = 1
            }
            
            let imageThumb = URL.init(string: self.trackObject?.trackImage ?? "")
            trackImage.sd_setImage(with: imageThumb , placeholderImage:R.image.imagePlacholder())
            self.selectedImage = trackImage.image
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.descriptionTextViewHeight.constant = self.setTextViewHeight(textView: self.descriptionTextView)
                self.lyricsTextViewHeight.constant = self.setTextViewHeight(textView: self.lyricsTextView)
            }
        }
    }
    
    func customizeDropdown() {
        moreDropdown.dataSource = [
            "All ages can listen this song",
            "Only +18"
        ]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.ageRestrictionTextField
        moreDropdown.width = self.ageRestrictionTextField.frame.width
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                self.ageRestrictionTextField.text = item
                self.ageRestriction = 0
            } else if index == 1 {
                self.ageRestrictionTextField.text = item
                self.ageRestriction = 1
            }
            print("Index = \(index)")
        }
    }
    
    func customizeDownloadDropdown() {
        moreDropDown1.dataSource = [
            "Yes",
            "No"
        ]
        moreDropDown1.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropDown1.textColor = UIColor.white
        moreDropDown1.anchorView = self.allowDownloadsTextField
        moreDropDown1.width = self.allowDownloadsTextField.frame.width
        moreDropDown1.direction = .any
        moreDropDown1.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.allowDownloadsTextField.text = item
                self.downloadPermission = 1
            } else if index == 1 {
                self.allowDownloadsTextField.text = item
                self.downloadPermission = 0
            }
            print("Index = \(index)")
        }
    }
    
    private func uploadThumbnail(thumbnailData: Data) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrackManager.instance.uploadTrackThumbnail(AccesToken: accessToken, thumbnailData: thumbnailData) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.thumbnail ?? "")")
                                if self.trackObject != nil {
                                    self.updateTrack(thumbnailString: success?.thumbnail ?? "")
                                } else {
                                    self.submitTrack(thumbnailString: success?.thumbnail ?? "")
                                }
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func submitTrack(thumbnailString: String) {
        if Connectivity.isConnectedToNetwork() {
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
            
            let params = [
                API.Params.AccessToken: accessToken,
                API.Params.allow_downloads: downloads,
                API.Params.lyrics: lyrics,
                API.Params.Title: title,
                API.Params.Description: description,
                API.Params.Tag: tags,
                API.Params.CategoryId: genre,
                API.Params.SongPrice: price,
                API.Params.Privacy: privacy,
                API.Params.AgeRestriction: restriction,
                API.Params.SongLocation: self.uploadTrackModel?.file_path ?? "",
                API.Params.SongThumbnail: thumbnailString,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ] as [String : Any]
            Async.background {
                TrackManager.instance.submitTrack(params: params) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.navigationController?.popViewController(animated: true)
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func updateTrack(thumbnailString: String) {
        if Connectivity.isConnectedToNetwork() {
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
            
            let params = [
                API.Params.AccessToken: accessToken,
                API.Params.songId: songID,
                API.Params.allow_downloads: downloads,
                API.Params.lyrics: lyrics,
                API.Params.Title: title,
                API.Params.Description: description,
                API.Params.Tag: tags,
                API.Params.CategoryId: genre,
                API.Params.SongPrice: price,
                API.Params.Privacy: privacy,
                API.Params.AgeRestriction: restriction,
                API.Params.SongThumbnail: thumbnailString,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ] as [String : Any]
            Async.background {
                TrackManager.instance.updateTrack(params: params) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast("Song has been updated")
                                
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
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: getGenresStringDelegate
extension UploadTrackVC: getGenresStringDelegate {
    
    func getGenresString(String: String, nameString: String) {
        self.genresString = String
        self.genresTextField.text = nameString
        log.verbose("String to send on =\(String)")
    }
    
}

// MARK: getPriceStringDelegate
extension UploadTrackVC: getPriceStringDelegate {
    
    func getPriceString(String: String, nameString: String) {
        self.priceString = String
        self.priceTextField.text = nameString
        log.verbose("String to send on =\(String)")
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension UploadTrackVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.trackImage.image = image
        self.selectedImage = image
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: UITextFieldDelegate Methods
extension UploadTrackVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case songTitleTextField:
            self.songTitleTextFieldView.borderColorV = .mainColor
        case tagsTextField:
            self.tagsTextFieldView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case songTitleTextField:
            self.songTitleTextFieldView.borderColorV = .clear
        case tagsTextField:
            self.tagsTextFieldView.borderColorV = .clear
        default:
            break
        }
    }
    
}

// MARK: UITextViewDelegate Methods
extension UploadTrackVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case self.descriptionTextView:
            self.descriptionTextViewHeight.constant = self.setTextViewHeight(textView: self.descriptionTextView)
        case self.lyricsTextView:
            self.lyricsTextViewHeight.constant = self.setTextViewHeight(textView: self.lyricsTextView)
        default:
            break
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            self.descriptionView.borderColorV = .mainColor
        case lyricsTextView:
            self.lyricsView.borderColorV = .mainColor
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            self.descriptionView.borderColorV = .clear
        case lyricsTextView:
            self.lyricsView.borderColorV = .clear
        default:
            break
        }
    }
    
}
