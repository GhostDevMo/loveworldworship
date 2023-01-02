//
//  AppDelegate.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 13/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DropDown
import Reachability
import SwiftEventBus
import IQKeyboardManagerSwift
import SwiftyBeaver
import Async
import OneSignal
import FBSDKLoginKit
import GoogleSignIn
import CoreData
import DeepSoundSDK
import GoogleMobileAds
import Braintree


let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,OSSubscriptionObserver {
    
    var window: UIWindow?
    var isInternetConnected = Connectivity.isConnectedToNetwork()
    var reachability :Reachability? = Reachability()
    let hostNames = ["google.com", "google.com", "google.com"]
    var hostIndex = 0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        startHost(at: 0)
        initFrameworks(application: application, launchOptions: launchOptions)
        DropDown.startListeningToKeyboard()
        FBSDKCoreKit.ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        stopNotifier()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func initFrameworks(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        ApplicationDelegate.initialize()
        
        /* Decryption of Cert Key */
        ServerCredentials.setServerDataWithKey(key: AppConstant.key)
        
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage.starts(with: "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }

        let status = UserDefaults.standard.getDarkMode(Key: "darkMode")
               if #available(iOS 13.0, *) {
                   if status{
                       window?.overrideUserInterfaceStyle = .dark
                       
                   }else{
                       window?.overrideUserInterfaceStyle = .light

                   }
               }
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.mainColor]

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
//        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"",PayPalEnvironmentSandbox:"AYQj_efvWzS7BgDU42nwInlwmetwd3ZT5WloT2ePnfinLw59GcR_EzEhnG8AtRBp9frGuvs09HsKagKJ"])
        
        
        BTAppContextSwitcher.setReturnURLScheme(ControlSettings.BrainTreeURLScheme)
 

      
        /*
         Uncomment all these to set seperately and comment setServerDataWithKey before uncommenting it
         */
        
//        ServerCredentials.setBaseUrl(url: <#T##String#>)  to set Your webURL seperateLy
//         ServerCredentials.setServerKey(url: <#T##String#>) to set your App server key seperatelu
//         ServerCredentials.setPurchaseCode(url: <#T##String#>) to set your Purchase code
        
        /* Init Swifty Beaver */
        let console = ConsoleDestination()
        let file = FileDestination()
        log.addDestination(console)
        log.addDestination(file)
        
        /* Stripe of Setup */
     //   Stripe.setDefaultPublishableKey("pk_test_PT6I0ZbUz3Kie6yMvWLPrO5f00scXxDHaQ")
        
        /* IQ Keyboard */
        
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()
        GIDSignIn.sharedInstance().clientID = ControlSettings.googleClientKey
        
        //         OneSignal initialization
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,kOSSettingsKeyInAppLaunchURL: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ControlSettings.oneSignalAppId,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            log.verbose("User accepted notifications: \(accepted)")
        })
         OneSignal.add(self as OSSubscriptionObserver)
        
         let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
               log.verbose("Current playerId \(userId)")
        
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
            if !stateChanges.from.subscribed && stateChanges.to.subscribed {
               print("Subscribed for OneSignal push notifications!")
            }
            print("SubscriptionStateChange: \n\(stateChanges)")

            //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
            if let playerId = stateChanges.to.userId {
               print("Current playerId \(playerId)")
                UserDefaults.standard.setDeviceId(value: playerId ?? "", ForKey: Local.DEVICE_ID.DeviceId)
            }
         }
    
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index], useClosures: false)
        startNotifier()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.startHost(at: (index + 1) % 3)
        }
    }
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = Reachability(hostname: hostName)
            
        } else {
            reachability = Reachability()
        }
        self.reachability = reachability ?? Reachability.init()
        if useClosures {
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    @objc func reachabilityChanged(_ note: Notification) {
        Async.main({
            let reachability = note.object as! Reachability
            switch reachability.connection {
            case .wifi:
                log.debug("Reachable via WiFi")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
                
            case .cellular:
                log.debug("Reachable via Cellular")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
                
            case .none:
                log.debug("Network not reachable")
                self.isInternetConnected = false
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED)
                
            }
        })
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DeepSoundiOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

