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
import Toast_Swift

class UploadAlbumVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var genresTF: UITextField!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var songTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var selectPictureBtn: UIButton!
    
    // MARK: - Properties
    
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    private var selectedImage: UIImage? = nil
    private var priceString: String? = ""
    private var genresString: String? = ""
    var albumObject: UpdateAlbumModel?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Create and share Album. Each Album is custom created and organized to help you find the best music for your preference.", comment: "Create and share Album. Each Album is custom created and organized to help you find the best music for your preference.")
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
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    @IBAction func pricePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.popups.selectPriceVC()
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func genresPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.genresPopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectPicturePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                self.view.makeToast("Camera not Supported!..........")
                return
            }
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
    
    @IBAction func createPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.songTitleTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Enter Album Title")
            return
        } else if self.selectedImage == nil {
            self.view.makeToast("Please select Album image")
            return
        } else {
            self.uploadThumbnail(thumbnailData: (self.selectedImage?.jpegData(compressionQuality: 0.1))!)
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        if self.albumObject != nil {
            self.title = NSLocalizedString("Upload Album", comment: "")
            self.createBtn.setTitle("UPDATE", for: .normal)
            self.songTitleTextField.text = self.albumObject?.title ?? ""
            self.descriptionTextView.text = self.albumObject?.description ?? ""
            self.genresTF.text = self.albumObject?.genre
            self.priceTF.text = "\(self.albumObject?.price ?? 0)"
            let imageThumb = URL.init(string:self.albumObject?.imageString ?? "")
            trackImage.sd_setImage(with: imageThumb, placeholderImage:R.image.imagePlacholder())
            self.selectedImage = trackImage.image
        }
    }
    
    private func uploadThumbnail(thumbnailData:Data) {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrackManager.instance.uploadTrackThumbnail(AccesToken: accessToken, thumbnailData:thumbnailData) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.thumbnail ?? "")")
                                
                                if self.albumObject != nil{
                                    self.updateAlbum(thumbnailString: success?.thumbnail ?? "")
                                }else{
                                    self.submitAlbum(thumbnailString: success?.thumbnail ?? "")
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
    
    private func submitAlbum(thumbnailString: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let title = self.songTitleTextField.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let genre = self.genresString ?? ""
            let price = self.priceString ?? ""
            Async.background {
                AlbumManager.instance.submitAlbum(AccessToken: accessToken, AlbumTitle: title, AlbumDescription: description, AlbumGenreGenresString: genre, AlbumPriceString: price, thumbnailPath: thumbnailString) { (success, sessionError, error) in
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
    
    private func updateAlbum(thumbnailString: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let title = self.songTitleTextField.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let genre = self.genresString ?? ""
            let price = self.priceString ?? ""
            let albumID = self.albumObject?.AlbumID ?? ""
            Async.background {
                AlbumManager.instance.updateAlbum(AccessToken: accessToken,albumID:albumID, AlbumTitle: title, AlbumDescription: description, AlbumGenreGenresString: genre, AlbumPriceString: price, thumbnailPath: thumbnailString) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast("Album has been updated")
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

// MARK: - Extensions

// MARK: GenresPopupVCDelegate
extension UploadAlbumVC: GenresPopupVCDelegate {
    
    func handleGenresSelection(id: Int, cateogryName: String) {
        self.genresString = "\(id)"
        self.genresTF.text = cateogryName
        log.verbose("String to send on =\(cateogryName)")
    }
    
}

// MARK: getPriceStringDelegate
extension UploadAlbumVC: getPriceStringDelegate {
    
    func getPriceString(String: String,nameString:String) {
        self.priceString = String
        self.priceTF.text = nameString
        log.verbose("String to send on =\(String)")
    }
    
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension UploadAlbumVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.trackImage.image = image
            self.selectedImage = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
