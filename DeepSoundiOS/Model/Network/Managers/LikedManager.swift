//
//  LikedManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class LikedManager{
    static let instance = LikedManager()
    
    func getLiked(UserId:Int,AccessToken:String,Limit:Int,Offset:Int,completionBlock: @escaping (_ Success:LikedModel.LikedSuccessModel?,_ SessionError:LikedModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: UserId,
            API.Params.Limit: Limit,
            API.Params.Offset: Offset,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Libarary_Constants_Methods.GET_LIKED_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Libarary_Constants_Methods.GET_LIKED_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(LikedModel.LikedSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(LikedModel.sessionErrorModel.self, from: data)
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
