//
//  AppInstance.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Async
import UIKit
import DeepSoundSDK
import AVKit
import Contacts

class AppInstance {
    
    // MARK: - Properties
    
    static let instance = AppInstance()
    
    var userId:Int? = nil
    var accessToken:String? = nil
    var genderText:String? = "all"
    var profilePicText:String? = "all"
    var statusText:String? = "all"
    var playSongBool:Bool? = false
    var currentIndex:Int? = 0
    var popupPlayPauseSong:Bool? = false
    var offlinePlayPauseSong:Bool? = false
    var AlreadyPlayed:Bool = false
    var addCount:Int? = 0
    var player:AVPlayer? = nil
    var optionsData: OptionsData?
    //var latestSong = [Song]()
    var isLoginUser = false
    var contacts = [FetchedContact]()
    
    // MARK: -
    var userProfile:ProfileModel.ProfileSuccessModel?
    /*var likedArray = [Song]()
    var playlistArray:[Playlist]?*/
    
    func getUserSession() -> Bool {
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty {
            return false
        }else {
            self.userId = (localUserSessionData[Local.USER_SESSION.User_id] as! Int)
            self.accessToken = localUserSessionData[Local.USER_SESSION.Access_token] as? String ?? ""
            return true
        }
    }
    
    func fetchUserProfile(isNew: Bool = false, completion: @escaping (Bool) -> Void) {
        let status = AppInstance.instance.getUserSession()
        if Connectivity.isConnectedToNetwork() {
            if status {
                let userId = AppInstance.instance.userId ?? 0
                let accessToken = AppInstance.instance.accessToken ?? ""
                let fetch = !isNew ? "all" : "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,store,events"
                Async.background {
                    ProfileManger.instance.getProfile(UserId: userId, fetch: fetch, AccessToken: accessToken) { (success, sessionError, error) in
                        if let success = success {
                            Async.main {
                                AppInstance.instance.userProfile = success
                                completion(true)
                                log.debug("success")
                            }
                        }else if sessionError != nil{
                            Async.main {
                                log.error("sessionErrror = \(sessionError?.error ?? "")")
                                appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error)
                                completion(false)
                            }
                        }else {
                            Async.main {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                // appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription)
                                completion(false)
                            }
                        }
                    }
                }
            }else {
                completion(false)
            }
        }else {
            log.error(InterNetError)
        }
    }
    
    func getOptions(completionBlock: @escaping (_ Success: OptionsModel?, _ sessionError: String?, Error?) ->()){
        Async.background({
            GetOptionsManager.instance.getOptions { success, sessionError, error in
                if success != nil{
                    Async.main {
                        AppInstance.instance.optionsData = success?.data
                        completionBlock(success, nil, nil)
                    }
                } else if sessionError != nil {
                    Async.main {
                        log.error("sessionError = \(sessionError ?? "")")
                        completionBlock(nil, sessionError ?? "", nil)
                    }
                } else {
                    Async.main {
                        log.error("error = \(error?.localizedDescription ?? "")")
                        completionBlock(nil, nil, error)
                    }
                }
            }
        })
    }
    
    /*func fetchLiked(){
        if Connectivity.isConnectedToNetwork(){
//            self.likedArray.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                LikedManager.instance.getLiked(UserId: userId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("userList = \(success?.data?.data ?? [])")
//                            AppInstance.instance.likedArray = success?.data?.data ?? []
                        })
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        })
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
        }
    }
    
    func fetchMyPlaylist(){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                PlaylistManager.instance.getPlayList(UserId:userId,AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("userList = \(success?.status ?? 0)")
//                            AppInstance.instance.playlistArray = success?.playlists
                            // self.tableView.reloadData()
                        })
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        })
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
        }
    }*/
    
    func fetchContacts() {
        print("Attempting to fetch contacts")
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                print("access granted")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print(contact.givenName)
                        self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
}

