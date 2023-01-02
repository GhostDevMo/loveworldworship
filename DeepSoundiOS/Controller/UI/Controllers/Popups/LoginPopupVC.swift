
//
//  LoginPopupVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 3/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class LoginPopupVC: BaseVC {

    @IBOutlet weak var yes: UIButton!
    @IBOutlet weak var no: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var Login: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yes.setTitle((NSLocalizedString("YES", comment: "")), for: .normal)
        self.no.setTitle((NSLocalizedString("NO", comment: "")), for: .normal)
        self.descLabel.text = (NSLocalizedString("Sorry you can not continue, you must login and enjoy access to everything you want", comment: ""))
        self.Login.text = (NSLocalizedString("Login", comment: ""))
    }
    @IBAction func yesPRessed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.appDelegate.window?.rootViewController = R.storyboard.login.main()
        }
    }
    @IBAction func noPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
