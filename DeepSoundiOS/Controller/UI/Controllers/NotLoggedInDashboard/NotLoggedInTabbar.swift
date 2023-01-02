//
//  NotLoggedInTabbar.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 12/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import UIKit
class NotLoggedIntabbar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreNavigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
        self.tabBar.tintColor = .mainColor
    }
    
    
    
}
