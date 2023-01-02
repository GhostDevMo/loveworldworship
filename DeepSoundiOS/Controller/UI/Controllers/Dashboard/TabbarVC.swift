//
//  TabbarVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 11/24/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreNavigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
        self.tabBar.tintColor = .mainColor
    }
    
    
    
}
