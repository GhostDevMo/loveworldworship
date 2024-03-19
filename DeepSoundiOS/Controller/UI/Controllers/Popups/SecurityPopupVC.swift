//
//  SecurityPopupVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
class SecurityPopupVC: BaseVC {
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    var errorText:String? = ""
    var titleText:String? = ""
    var status:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
    private func setupUI(){
        self.okButton.setTitle((NSLocalizedString("OK", comment: "")), for: .normal)
        self.titleLabel.text = titleText ?? (NSLocalizedString("Security", comment: ""))
        self.errorTextLabel.text = errorText ?? "N/A"
    }
    @IBAction func okPressed(_ sender: UIButton) {
        if status {
            let vc = R.storyboard.login.loginVC()
            self.appDelegate.window?.rootViewController = vc
        }else{
            self.dismiss(animated: true, completion: nil)
        }
       
    }
}
