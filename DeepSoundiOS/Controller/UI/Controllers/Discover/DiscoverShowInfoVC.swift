//
//  DiscoverShowInfoVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 09/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
class DiscoverShowInfoVC: UIViewController {
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var details = [String:Int]()
    var artistObject:ArtistModel.Datum?
    var userProfileModel:ProfileModel.DataElement?
    var followersObject:FollowerModel.Datum?
    var followingObject:FollowingModel.Datum?
    var artistSearchObject:SearchModel.Artist?
    
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
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.shadowView.dropShadow()
    }
    
    private func setupUI(){
        if artistObject != nil{
            self.aboutLabel.text = artistObject?.about ?? ""
            let profileImage = artistObject?.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = artistObject?.name ?? ""
            self.genderLabel.text = artistObject?.gender ?? ""
        }else if followersObject != nil{
           self.aboutLabel.text = followersObject?.about ?? ""
            let profileImage = followersObject?.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = followersObject?.name ?? ""
            self.genderLabel.text = followersObject?.gender ?? ""
        }else if followingObject != nil {
            self.aboutLabel.text = followingObject?.about ?? ""
            let profileImage = followingObject?.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = followingObject?.name ?? ""
            self.genderLabel.text = followingObject?.gender ?? ""
        }else if userProfileModel != nil{
            self.aboutLabel.text = userProfileModel?.about ?? ""
            let profileImage = userProfileModel?.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = userProfileModel?.name ?? ""
            self.genderLabel.text = userProfileModel?.gender ?? ""
        }else if artistSearchObject != nil{
            self.aboutLabel.text = artistSearchObject?.about ?? ""
            let profileImage = artistSearchObject?.avatar ?? ""
            let profileImageURL = URL.init(string:profileImage)
            self.profileImage.sd_setImage(with: profileImageURL , placeholderImage:R.image.imagePlacholder())
            self.nameLabel.text = artistSearchObject?.name ?? ""
            self.genderLabel.text = artistSearchObject?.gender ?? ""
        }
       
        self.followersCountLabel.text = "\(details["followers"]  ?? 0)"
        self.followingsCountLabel.text = "\(details["following"] ?? 0)"
        self.trackCountLabel.text = "\(details["latest_songs"] ?? 0)"
      
    }
}
