//
//  BankTransferVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class BankTransferVC: BaseVC {
    
    @IBOutlet weak var selectPictureBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var receiptImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var sendBtn: UIButton!
    var isMediaStatus:Bool? = false
    var mediaData:Data? = nil
    private let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = .mainColor
        self.lineView.backgroundColor = .mainColor
        
        self.cancelBtn.backgroundColor = .ButtonColor
        self.sendBtn.backgroundColor = .ButtonColor
        self.selectPictureBtn.borderColorV = .ButtonColor
        self.selectPictureBtn.setTitleColor(.ButtonColor, for: .normal)
        
        self.cancelBtn.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.receiptImage.image = nil
        self.mediaData = nil
        isMediaStatus = false
        self.cancelBtn.isHidden = false
        
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if !self.isMediaStatus!{
            self.view.makeToast("Please add receipt")
        }else{
            self.uploadReceipt()
        }
    }
    
    @IBAction func selectPictureBtn(_ sender: Any) {
        log.verbose("Tapped ")
        
        let alert = UIAlertController(title: "", message:NSLocalizedString("Select Source", comment: "Select Source") , preferredStyle: .alert)
        let camera = UIAlertAction(title:NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title:NSLocalizedString("Gallery", comment: "Gallery") , style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    private func uploadReceipt(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let media = self.mediaData ?? Data()
            
            Async.background({
                BankTransferManager.instance.sendReceipt(AccesToken: accessToken, mode: "album", mediaData: media) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
}
extension  BankTransferVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.receiptImage.image = image
        self.mediaData = image.pngData()
        self.isMediaStatus = true
        self.cancelBtn.isHidden = false
        self.dismiss(animated: true, completion: nil)
        
    }
}
