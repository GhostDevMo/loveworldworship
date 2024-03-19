//
//  CreateStoryVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import MediaPlayer
import Async

class CreateStoryVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageStory: UIImageView!
    @IBOutlet weak var imageSong: UIImageView!
    @IBOutlet weak var whoCanSeeTF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var btnCreate: UIButton!
    
    // MARK: - Properties
    
    var musicData: Data?
    var imageData: Data?
    var whoCanSeeType: String?
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnCreate.addShadow(offset: .init(width: 0, height: 2), radius: 5, opacity: 0.5)
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
    
    @IBAction func whoCanSeeBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let newVC = R.storyboard.popups.whoCanSeePopupVC() else { return }
        newVC.delegate = self
        self.present(newVC, animated: true)
    }
    
    @IBAction func createBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.imageData == nil {
            self.view.makeToast("Please select Cover image")
            return
        }
        
        if self.musicData == nil {
            self.view.makeToast("Please select song")
            return
        }
        
        if self.whoCanSeeType == nil {
            self.view.makeToast("Please select who can see the story")
            return
        }
        self.createStoryAPI()
    }
    
    @IBAction func uploadImageBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else {
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
    
    @IBAction func uploadSongBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.prompt = "Choose a song"
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
}

// MARK: - Extensions

// MARK: API Services
extension CreateStoryVC {
    
    func createStoryAPI() {
        let url = self.urlTF.text ?? ""
        let who = self.whoCanSeeType ?? ""
        Async.background {
            StoryManager.instance.createStoryAPI(url: url, who: who, thumbnailData: self.imageData, musicdata: self.musicData) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message)
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
        }
    }
}

// MARK: Image Picker Controller Delegate Methods
extension CreateStoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageStory.image = image
            self.imageData = image.jpegData(compressionQuality: 0.25)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: MPMedia Picker Delegate Methods
extension CreateStoryVC: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        self.showProgressDialog(text: "Loading...")
        Async.background {
            exportSession?.exportAsynchronously {
                if exportSession!.status == AVAssetExportSession.Status.completed {
                    print("Export Successfull")
                    do {
                        let data = try Data(contentsOf: outputURL)
                        log.verbose("Data = \(data)")
                        Async.main {
                            self.dismissProgressDialog {
                                self.musicData = data
                                self.imageSong.image = UIImage(named: "ic_upload_song")
                            }
                        }
                    }catch {
                        self.view.makeToast(error.localizedDescription)
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
}

//MARK: Who can see Popup Delegate Methods
extension CreateStoryVC: WhoCanSeePopupDelegate {
    
    func selectedType(_ sender: UIButton, _ type: String) {
        self.whoCanSeeTF.text = sender.currentTitle
        self.whoCanSeeType = type
    }
    
}
