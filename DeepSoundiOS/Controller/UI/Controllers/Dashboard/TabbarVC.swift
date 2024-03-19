//
//  TabbarVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 11/24/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController, UITabBarControllerDelegate {
    var selectedTabIndex = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreNavigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
        self.tabBar.tintColor = .mainColor
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if AppInstance.instance.isLoginUser {
            return true
        }else {
            if self.selectedTabIndex >= 2 {
                self.showLoginAlert()
                return false
            }else {
                return true
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.selectedTabIndex = item.tag
    }
    
    func showLoginAlert() {
        self.view.endEditing(true)
        let warningPopupVC = R.storyboard.popups.warningPopupVC()
        warningPopupVC?.delegate = self
        warningPopupVC?.titleText = "Login"
        warningPopupVC?.messageText = "Sorry you can not continue, you must log in and enjoy access to everything you want?"
        warningPopupVC?.okText = "YES"
        warningPopupVC?.cancelText = "NO"
        self.present(warningPopupVC!, animated: true, completion: nil)
        warningPopupVC?.okButton.tag = 1001
    }
}

extension TabbarVC: WarningPopupVCDelegate {
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        }
    }
}
