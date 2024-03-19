//
//  ShareBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by iMac on 01/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

class ShareBottomSheetController: BaseVC, PanModalPresentable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var lblSongCount: UILabel!
    @IBOutlet weak var lblAlbumName: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    // MARK: - Properties
    
    var selectedAlbum: Album? {
        didSet {
            if let selectedAlbum = self.selectedAlbum {
                self.bind(selectedAlbum)
            }
        }
    }
    var panScrollable: UIScrollView?
    var shortFormHeight: PanModalHeight {
        return .contentHeight(200)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(200)
    }
    
    //MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        if let selectedAlbum = self.selectedAlbum {
            self.bind(selectedAlbum)
        }
    }
    
    init(album: Album) {
        super.init(nibName: ShareBottomSheetController.name, bundle: nil)
        self.selectedAlbum = album
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
        if let str = self.selectedAlbum?.url {
            self.share(shareString: str)
        }
    }
    
}

// MARK: - Extensions

// MARK: Helper Functions
extension ShareBottomSheetController {
    
    func setupUI() {
        topCorners(bgView: self.mainView, cornerRadius: 24, maskToBounds: true)        
    }
    
    func bind(_ object: Album) {
        let thumbnailURL = URL.init(string: object.thumbnail ?? "")
        self.imgSong.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        self.lblAlbumName.text = object.title ?? ""
        self.lblSongCount.text = "\(object.count_songs ?? 0) \(NSLocalizedString("Songs", comment: "Songs")) - \(object.purchases ?? 0) Purchases"
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
