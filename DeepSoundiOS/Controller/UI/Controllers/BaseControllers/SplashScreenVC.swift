//
//  SplashScreenVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 30/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import Toast_Swift

class SplashScreenVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showStack: UIStackView!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            log.verbose("Internet connected!")
            self.showStack.isHidden = false
            self.activityIndicator.startAnimating()
            //self.fetchUserProfile()
        }
        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
            self.showStack.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        self.getOptions()
    }
    
    deinit {
        SwiftEventBus.unregister(self)
    }
    
    private func getOptions() {
        AppInstance.instance.getOptions { success, sessionError, error in
            if success != nil {
                self.fetchUserProfile()                
            } else if sessionError != nil {
                log.error("sessionError = \(sessionError ?? "")")
                self.view.makeToast(sessionError ?? "")
            } else {
                log.error("sessionError = \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func fetchUserProfile() {
        if appDelegate.isInternetConnected {
            self.activityIndicator.startAnimating()
            let status = AppInstance.instance.getUserSession()
            AppInstance.instance.isLoginUser = status
            if status {
                let userId = AppInstance.instance.userId ?? 0
                let accessToken = AppInstance.instance.accessToken ?? ""
                ProfileManger.instance.getProfile(UserId: userId, fetch: "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,store,events", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        AppInstance.instance.userProfile = success ?? nil
                        SwiftEventBus.unregister(self)
                        self.showStack.isHidden = true
                        self.activityIndicator.stopAnimating()
                        let dashboardNav =  R.storyboard.dashboard.tabBarNav()
                        self.appDelegate.window?.rootViewController = dashboardNav
                    } else if sessionError != nil {                        
                        self.activityIndicator.stopAnimating()
                        self.showStack.isHidden = true
                        log.error("sessionError = \(sessionError?.error ?? "")")
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.showStack.isHidden = true
                        log.error(error?.localizedDescription ?? "")
                    }
                })
            } else {
                SwiftEventBus.unregister(self)
                let mainNav =  R.storyboard.login.main()
                self.appDelegate.window?.rootViewController = mainNav
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}
