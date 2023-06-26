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

class SplashScreenVC: BaseVC {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showStack: UIStackView!
    
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
        self.fetchUserProfile()
    }
    deinit {
        SwiftEventBus.unregister(self)
        
    }
    
    private func fetchUserProfile(){
        if appDelegate.isInternetConnected{
            self.activityIndicator.startAnimating()
            let status = AppInstance.instance.getUserSession()
            if status{
                let userId = AppInstance.instance.userId ?? 0
                let accessToken = AppInstance.instance.accessToken ?? ""
               //Async.background({
                    ProfileManger.instance.getProfile(UserId: userId, AccessToken: accessToken, completionBlock: { (success1, sessionError, error) in
                        if success1 != nil{
                          //  Async.main({
                                AppInstance.instance.getOptions { success, sessionError, error in
                                    if success != nil{
                                        AppInstance.instance.userProfile = success1 ?? nil
                                        SwiftEventBus.unregister(self)
                                        self.showStack.isHidden = true
                                        self.activityIndicator.stopAnimating()
                                        let dashboardNav =  R.storyboard.dashboard.dashBoardTabbar()
                                        dashboardNav?.modalPresentationStyle = .fullScreen
                                        self.present(dashboardNav!, animated: true, completion: nil)
                                    }else if sessionError != nil{
                                        log.error("sessionError = \(sessionError)")
                                        self.view.makeToast(sessionError ?? "")
                                        
                                    }else{
                                        log.error("sessionError = \(error?.localizedDescription ?? "")")
                                        self.view.makeToast(error?.localizedDescription ?? "")
                                        
                                    }
                                }
                          //  })
                        }else if sessionError != nil{
                           // Async.main({
                                self.activityIndicator.stopAnimating()
                                self.showStack.isHidden = true
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error)
                           // })
                            
                        }else {
                           // Async.main({
                                self.activityIndicator.stopAnimating()
                                self.showStack.isHidden = true
//                                log.error("error = \(error?.localizedDescription ?? "")")
//                                self.view.makeToast(error?.localizedDescription)
                            let userId = UserDefaults.standard.getUserID(Key: "userID")
                            if userId != 0 {
                                let dashboardNav =  R.storyboard.dashboard.dashBoardTabbar()
                                dashboardNav?.modalPresentationStyle = .fullScreen
                                self.present(dashboardNav!, animated: true, completion: nil)
                            }
                            else{
                                let mainNav =  R.storyboard.login.main()
                                self.appDelegate.window?.rootViewController = mainNav
                            }
                            
                               
                           // })
                        }

                   // })
                })
                
            }else{
                SwiftEventBus.unregister(self)
                let mainNav =  R.storyboard.login.main()
                self.appDelegate.window?.rootViewController = mainNav
            }
        }else {
            self.view.makeToast(InterNetError)
        }
    }
}
