//
//  MyInfoVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus

class MyInfoVC: BaseVC {
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var genderStackView: UIStackView!
    @IBOutlet weak var websiteStackView: UIView!
    @IBOutlet weak var facebookStackView: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var userData: Publisher?
    var publisher: Publisher?
    var detailsDic: Details?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if publisher == nil {
            self.setupUI()
        }else {
            self.setupPublisher()
        }
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
    
    @IBAction func websiteBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let data = URL(string: self.websiteLabel.text ?? "")!
        goFacebook(url: data)
    }
    
    @IBAction func facebookBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let data = URL(string: "https://www.facebook.com/\(self.facebookLabel.text ?? "")")!
        goFacebook(url: data)
    }
    
    func goFacebook(url: URL) {
        let facebookURL = url
        if UIApplication.shared.canOpenURL(facebookURL) {
            UIApplication.shared.openURL(facebookURL)
        }
    }
    
    
    private func setupUI() {
        if userData == nil {
            userData = AppInstance.instance.userProfile?.data
            detailsDic = AppInstance.instance.userProfile?.details?.details
        }
        if let userData = userData {
            self.shadowView.addShadow()
            let profileImage = userData.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = userData.name ?? ""
            self.followingsCountLabel.text = "\(self.detailsDic?.following ?? 0)"
            self.followersCountLabel.text = "\(self.detailsDic?.followers ?? 0)"
            self.trackCountLabel.text = "\(self.detailsDic?.top_songs ?? 0)"
            if userData.country_name != "" {
                self.addressLabel.text = userData.country_name
            }else {
                self.addressLabel.text = "Unknown"
            }
            
            if userData.email != "" {
                self.emailLabel.text = userData.email ?? ""
            }else {
                self.emailStackView.isHidden = true
            }
            
            if userData.gender != "" {
                self.genderLabel.text = userData.gender ?? ""
            }else {
                self.genderStackView.isHidden = true
            }
            
            if userData.website != "" {
                self.websiteLabel.text = userData.website ?? ""
            }else {
                self.websiteStackView.isHidden = true
            }
            
            if userData.facebook != "" {
                self.facebookLabel.text = userData.facebook ?? ""
            }else {
                self.facebookStackView.isHidden = true
            }
        }
    }
    
    private func setupPublisher() {
        self.shadowView.addShadow()
        if let publisher = publisher {
            let profileImage = publisher.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = publisher.name ?? ""
            self.followingsCountLabel.text = "\(self.detailsDic?.following ?? 0)"
            self.followersCountLabel.text = "\(self.detailsDic?.followers ?? 0)"
            self.trackCountLabel.text = "\(self.detailsDic?.top_songs ?? 0)"
            if publisher.country_name != "" {
                self.addressLabel.text = publisher.country_name
            }else {
                self.addressLabel.text = "Unknown"
            }
            
            if publisher.email != "" {
                self.emailLabel.text = publisher.email ?? ""
            }else {
                self.emailStackView.isHidden = true
            }
            
            if publisher.gender != "" {
                self.genderLabel.text = publisher.gender ?? ""
            }else {
                self.genderStackView.isHidden = true
            }
            
            if publisher.website != "" {
                self.websiteLabel.text = publisher.website ?? ""
            }else {
                self.websiteStackView.isHidden = true
            }
            
            if publisher.facebook != "" {
                self.facebookLabel.text = publisher.facebook ?? ""
            }else {
                self.facebookStackView.isHidden = true
            }
        }
    }
}
