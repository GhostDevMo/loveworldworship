
//
//  BaseVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift
import JGProgressHUD
import SwiftEventBus
import ContactsUI
import Async
import SDWebImage
import DeepSoundSDK
import LNPopupController
import AVKit
import UserNotifications
import MediaPlayer

class BaseVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hud : JGProgressHUD?
    
//    private var noInternetVC: NoInternetDialogVC!
    var userId:String? = nil
    var sessionId:String? = nil
    var contactNameArray = [String]()
    var contactNumberArray = [String]()
    var deviceID:String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        self.deviceID = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
        //        noInternetVC = R.storyboard.main.noInternetDialogVC()
        //
        //        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            //            self.CheckForUserCAll()
            //            log.verbose("Internet connected!")
            //            self.noInternetVC.dismiss(animated: true, completion: nil)
            
        }
        
        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            //            log.verbose("Internet dis connected!")
            //                self.present(self.noInternetVC, animated: true, completion: nil)
            
        }
        
        
        
        
    }
    //    deinit {
    //        SwiftEventBus.unregister(self)
    //    }
    override func viewWillAppear(_ animated: Bool) {
        //        if !Connectivity.isConnectedToNetwork() {
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        ////                self.present(self.noInternetVC, animated: true, completion: nil)
        //            })
        //        }
    }
    func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        
        self.userId = localUserSessionData[Local.USER_SESSION.User_id] as! String
        self.sessionId = localUserSessionData[Local.USER_SESSION.Access_token] as! String
    }
    
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = NSLocalizedString(text, comment: text)
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        hud?.dismiss()
        completionBlock()
        
    }
     func addToRecentlyWatched(trackId:Int?){
        if Connectivity.isConnectedToNetwork(){
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let track_id = trackId ?? 0
            Async.background({
                TrackManager.instance.getTrackInfo(TrackId: track_id, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    
  
    
}

extension BaseVC{
    func play(url:URL) {
        Async.background({
            let item = AVPlayerItem(url: url)
            AppInstance.instance.player = AVPlayer(playerItem:item )
            AppInstance.instance.player!.volume = 1.0
            AppInstance.instance.player!.play()
//            self.setupAudioSession()
        })
    }
    
    @available(iOS 13.0, *)
    func setupNowPlaying(title:String) {
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = AppInstance.instance.player?.currentItem!.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = AppInstance.instance.player?.currentItem!.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AppInstance.instance.player!.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            AppInstance.instance.player!.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            AppInstance.instance.player!.pause()
            return .success
        }
    }
//    func setupAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
//            print("Playback OK")
//            try AVAudioSession.sharedInstance().setActive(true)
//            print("Session is Active")
//        } catch {
//            print(error)
//        }
//    }
}
