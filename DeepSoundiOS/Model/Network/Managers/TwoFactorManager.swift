//
//  TwoFactorManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Alamofire
import DeepSoundSDK
class TwoFactorManager{
static let instance = TwoFactorManager()

    func updateTwoFactor(AccessToken:String,userId:Int,twoFactor:String,completionBlock: @escaping (_ Success:TwoFactorUpdateModel.TwoFactorUpdateSuccessModel?,_ SessionError:TwoFactorUpdateModel.sessionErrorModel?, Error?) ->()){
    let params = [
        
        API.Params.AccessToken: AccessToken,
        API.Params.user_id: userId,
        API.Params.two_factor: twoFactor,
        API.Params.ServerKey: API.SERVER_KEY.Server_Key
        
        ] as [String : Any]
    
    let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
    let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.TwoFactor_Methods.UPDATE_TWOFACTOR_API)")
    log.verbose("Decoded String = \(decoded)")
    AF.request(API.TwoFactor_Methods.UPDATE_TWOFACTOR_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
        
        if (response.value != nil){
            guard let res = response.value as? [String:Any] else {return}
            
            guard let apiStatus = res["status"]  as? Int else {return}
            if apiStatus ==  API.ERROR_CODES.E_TwoH{
                log.verbose("apiStatus Int = \(apiStatus)")
                let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                let result = try! JSONDecoder().decode(TwoFactorUpdateModel.TwoFactorUpdateSuccessModel.self, from: data)
                completionBlock(result,nil,nil)
            }else{
                log.verbose("apiStatus String = \(apiStatus)")
                let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                let result = try! JSONDecoder().decode(TwoFactorUpdateModel.sessionErrorModel.self, from: data)
                log.error("AuthError = \(result.error ?? "")")
                completionBlock(nil,result,nil)
            }
        }else{
            log.error("error = \(response.error?.localizedDescription ?? "")")
            completionBlock(nil,nil,response.error)
        }
    }
}
    func verifyTwoFactor(AccessToken:String,userId:Int,code:String,completionBlock: @escaping (_ Success:TwoFactorUpdateModel.TwoFactorUpdateSuccessModel?,_ SessionError:TwoFactorUpdateModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.user_id: userId,
            API.Params.code: code,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
            log.verbose("Targeted URL = \(API.TwoFactor_Methods.VERIFY_TWOFACTOR_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.TwoFactor_Methods.VERIFY_TWOFACTOR_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(TwoFactorUpdateModel.TwoFactorUpdateSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(TwoFactorUpdateModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
