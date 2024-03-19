//
//  UserInfoManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class UserInforManager {
    
    static let instance = UserInforManager()
    
    func getUserInfo(UserId:Int,
                     AccessToken:String,
                     Fetch_String:String,
                     completionBlock: @escaping (_ Success:UserInfoModel.UserInfoSuccessModel?,
                                                 _ SessionError:UserInfoModel.sessionErrorModel?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.user_id: UserId,
            API.Params.Fetch: Fetch_String,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UserInfo_Methods.USER_INFO_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.UserInfo_Methods.USER_INFO_API,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(UserInfoModel.UserInfoSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(UserInfoModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
