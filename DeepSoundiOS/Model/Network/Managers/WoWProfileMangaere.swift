//
//  WoWProfileMangaere.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK


class WoWProfileManager {
    static let instance = WoWProfileManager()
    
    func WoWonderUserData (userId : String, access_token : String, completionBlock : @escaping (_ Success:SocialLoginModel.SocialLoginSuccessModel?, _ AuthError : SocialLoginModel.sessionErrorModel? , Error?)->()){
        
        let params = [API.Params.ServerKey :"131c471c8b4edf662dd0ebf7adf3c3d7365838b9", API.Params.user_id : userId, API.Params.Fetch : "followers,user_data,followers,following,liked_pages,joined_groups"] as [String : Any]
        
        AF.request("\(ControlSettings.wowonder_URL)api/get-user-data?access_token=" + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatusCode = res["api_status"]  as? Any else {return}
                let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                    let base64String = self.jsonToBaseString(yourJSON: res)
                    var params = [String:String]()
                    
                    params = [
                        API.Params.Provider: "wowonder",
                        API.Params.SocialAccessToken: base64String!,
                        API.Params.SocialDeviceID:UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? "",
                        API.Params.ServerKey: API.SERVER_KEY.Server_Key
                    ]
                    
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
                    let decoded = String(data: jsonData, encoding: .utf8)!
                    log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API)")
                    log.verbose("Decoded String = \(decoded)")
                    AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
                        
                        if (response.value != nil){
                            guard let res = response.value as? [String:Any] else {return}
                            log.verbose("Response = \(res)")
                            guard let apiStatus = res["status"]  as? Int else {return}
                            if apiStatus ==  API.ERROR_CODES.E_TwoH{
                                log.verbose("apiStatus Int = \(apiStatus)")
                                let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                                let result = try! JSONDecoder().decode(SocialLoginModel.SocialLoginSuccessModel.self, from: data)
                                log.debug("Success = \(result.accessToken ?? "")")
                                let User_Session = [Local.USER_SESSION.Access_token:result.accessToken as Any,Local.USER_SESSION.User_id:result.data?.id as Any] as [String : Any]
                                UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                                completionBlock(result,nil,nil)
                            }else{
                                log.verbose("apiStatus String = \(apiStatus)")
                                let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                                let result = try! JSONDecoder().decode(SocialLoginModel.sessionErrorModel.self, from: data)
                                log.error("AuthError = \(result.error ?? "")")
                                completionBlock(nil,result,nil)
                            }
                        }else{
                            log.error("error = \(response.error?.localizedDescription ?? "")")
                            completionBlock(nil,nil,response.error)
                        }
                    }
                }
                else {
                    completionBlock(nil,nil,nil)
                }
            }
                
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
                
            }
        }
    }
    func jsonToBaseString (yourJSON: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: yourJSON, options: JSONSerialization.WritingOptions.prettyPrinted)
            return
                jsonData.base64EncodedString(options: .endLineWithCarriageReturn)
        } catch {
            return nil
        }
    }
}
