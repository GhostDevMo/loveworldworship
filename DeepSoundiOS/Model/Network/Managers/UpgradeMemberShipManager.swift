//
//  UpgradeMemberShipManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class UpgradeMemberShipManager{
    static let instance = UpgradeMemberShipManager()
    
    func upgradeMemberShip(userId:Int,AccessToken:String,completionBlock: @escaping (_ Success:UpgradeMemberShipModel.UpgradeMemberShipSuccessModel?,_ SessionError:UpgradeMemberShipModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: userId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Upgrade_MemberShip_Methods.UPGRADE_MEMBERSHIP_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Upgrade_MemberShip_Methods.UPGRADE_MEMBERSHIP_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpgradeMemberShipModel.UpgradeMemberShipSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpgradeMemberShipModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func purchase(AccessToken:String,type:String,completionBlock: @escaping (_ Success:String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.type: type,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Purchase.GO_PRO)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Purchase.GO_PRO, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                   let message = res["message"] as? String
                    completionBlock(message,nil,nil)
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
    func purchaseAlbum(AccessToken:String,type:String,AlbumID:String,completionBlock: @escaping (_ Success:String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.type: type,
            API.Params.Id: AlbumID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Purchase.GO_PRO)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Purchase.GO_PRO, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                   let message = res["message"] as? String
                    completionBlock(message,nil,nil)
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
    func purchaseTrack(AccessToken:String,type:String,TrackID:String,completionBlock: @escaping (_ Success:String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.type: type,
            API.Params.Id: TrackID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Purchase.GO_PRO)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Purchase.GO_PRO, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                   let message = res["message"] as? String
                    completionBlock(message,nil,nil)
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
