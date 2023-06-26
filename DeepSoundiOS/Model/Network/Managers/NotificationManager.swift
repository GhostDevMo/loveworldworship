//
//  NotificationManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class NotificationManager{
    static let instance = NotificationManager()
    
    func getNotification(AccessToken:String,completionBlock: @escaping (_ Success:NotificationModel.NotificationSuccessModel?,_ SessionError:NotificationModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Notification_Methods.GET_NOTIFICATION_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Notification_Methods.GET_NOTIFICATION_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(NotificationModel.NotificationSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(NotificationModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func notificationUnseenCount(AccessToken:String,completionBlock: @escaping (_ Success:notificationUnseenCountModel.notificationUnseenCountSuccessModel?,_ SessionError:notificationUnseenCountModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Notification_Methods.NOTIFICATION_COUNT_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Notification_Methods.NOTIFICATION_COUNT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(notificationUnseenCountModel.notificationUnseenCountSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(notificationUnseenCountModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateNotificationSetting(AccessToken:String,userID:Int,key:String,Value:Int,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.user_id:userID,
            key:Value
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Notification_Settings.NOTIFICATION_SETTINGS)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Notification_Settings.NOTIFICATION_SETTINGS, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
           if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let data = res["message"] as? String
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(data,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
