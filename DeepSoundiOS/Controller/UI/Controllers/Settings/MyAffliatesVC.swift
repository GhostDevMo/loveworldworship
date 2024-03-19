//
//  MyAffliatesVC.swift
//  DeepSoundiOS
//

//  Copyright © 2020 ScriptSun. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SDWebImage

class MyAffliatesVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    // MARK: - Properties
    
    private var referenceUrl = ""
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onClickUrlLabel(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        openUrl(urlString: self.referenceUrl)
    }
    
    // Share Button Action
    @IBAction func shareButtonAction(_ sender: UIButton) {
        self.shareAcitvity()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setUserData()
        self.setUpUrlLabel()
    }
    
    func setUpUrlLabel() {
        self.referenceUrl = "https://demo.deepsoundscript.com?ref=\(AppInstance.instance.userProfile?.data?.username ?? "")"
        self.urlLabel.text = self.referenceUrl
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickUrlLabel(_:)))
        self.urlLabel.isUserInteractionEnabled = true
        self.urlLabel.addGestureRecognizer(tap)
    }
    
    func setUserData() {
        let url = URL.init(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
        self.nameLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.userNameLabel.text = "@" + (AppInstance.instance.userProfile?.data?.username ?? "")
    }
    
    func openUrl(urlString: String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func shareAcitvity() {
        self.view.endEditing(true)
        let myWebsite = URL(string: self.referenceUrl)!
        let shareAll = [myWebsite]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
