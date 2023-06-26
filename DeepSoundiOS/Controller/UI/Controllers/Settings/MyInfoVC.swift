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
class MyInfoVC: UIViewController {
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var pingStatus:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tabBarController?.tabBar.isHidden = false
         navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
      
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.shadowView.dropShadow()
    }
    
    private func setupUI(){
        self.infoLabel.text = (NSLocalizedString("Information about your profile ", comment: ""))
        self.trackLabel.text = (NSLocalizedString("Tracks", comment: ""))
        self.followersLabel.text = (NSLocalizedString("Followers", comment: ""))
        self.followingLabel.text = (NSLocalizedString("Followings", comment: ""))
        self.aboutLabel.text = AppInstance.instance.userProfile?.data?.about ?? ""
        let profileImage = AppInstance.instance.userProfile?.data?.avatar ?? ""
        let profileImageURL = URL.init(string:profileImage)
        self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
        self.nameLabel.text = AppInstance.instance.userProfile?.data?.name ?? ""
        self.followingsCountLabel.text = "\(AppInstance.instance.userProfile?.details!["following"] ?? 0)"
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.details!["followers"] ?? 0)"
          self.emailLabel.text = AppInstance.instance.userProfile?.data?.email ?? ""
          self.genderLabel.text = AppInstance.instance.userProfile?.data?.gender ?? ""
          self.websiteLabel.text = AppInstance.instance.userProfile?.data?.website ?? ""
          self.facebookLabel.text = AppInstance.instance.userProfile?.data?.facebook ?? ""
        self.trackCountLabel.text = "\(AppInstance.instance.userProfile?.data?.topSongs?.count ?? 0)"
        
        
    }
}
