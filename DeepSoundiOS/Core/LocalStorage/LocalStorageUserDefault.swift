//
//  LocalStorageUserDefault.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 01/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import DeepSoundSDK

extension UserDefaults{
   
    func setDeviceId(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getDeviceId(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func clearUserDefaults(){
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    func removeValuefromUserdefault(Key:String){
        removeObject(forKey: Key)
    }
    
    
    func setUserName(value: String, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func setPassword(value: String, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    func setUserID(value: Int, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    func getPassword(Key:String) ->  String{
        return object(forKey: Key)  as?  String ?? ""
    }
    
    func getUserName(Key:String) ->  String{
        return object(forKey: Key)  as?  String ?? ""
    }
    func getUserID(Key:String) ->  Int{
        return object(forKey: Key)  as?  Int ?? 0
    }
    func setSharedSongs(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getSharedSongs(Key:String) ->  [Data]{
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    func setDownloadSongs(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getDownloadSongs(Key:String) ->  [Data]{
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    func setDarkMode(value: Bool, ForKey:String){
             set(value, forKey: ForKey)
             synchronize()
             
         }
         func getDarkMode(Key:String) ->  Bool{
             
             return ((object(forKey: Key) as? Bool) ?? false)!
             
         }
}











