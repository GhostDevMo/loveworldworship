//
//  IntroVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK

class IntroVC: UIViewController {
    
    @IBOutlet weak var discoverLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerButton.backgroundColor = .ButtonColor
        self.discoverLabel.text = NSLocalizedString("Listen to the best audio & music with deepsound now!", comment: "")
        self.skipButton.setTitle(NSLocalizedString("SKIP", comment: ""), for: .normal)
        self.registerButton.setTitle(NSLocalizedString("REGISTER", comment: ""), for: .normal)
        self.loginButton.setTitle(NSLocalizedString("LOGIN", comment: ""), for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    

    @IBAction func skipPressed(_ sender: Any) {
        let vc = R.storyboard.login.getStartedVC()
        vc?.status = false
        
       self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func registerPressed(_ sender: Any) {
        let vc = R.storyboard.login.registerVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let vc = R.storyboard.login.loginVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
