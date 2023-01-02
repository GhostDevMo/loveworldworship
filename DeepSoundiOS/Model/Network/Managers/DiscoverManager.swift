//
//  DiscoverManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 03/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class DiscoverManager{
    static let instance = DiscoverManager()
    
    func getDiscover(AccessToken:String,completionBlock: @escaping (_ Success:DiscoverModel.DiscoverSuccessModel?,_ notDisCover:NotDiscoverModel.DiscoverSuccessModel?,_ SessionError:DiscoverModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Discover_Constants_Methods.DISCOVER_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Discover_Constants_Methods.DISCOVER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            log.verbose("response.result.value = \(response.value)")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                                      let result = try! JSONDecoder().decode(DiscoverModel.DiscoverSuccessModel.self, from: data)
                                      completionBlock(result,nil,nil,nil)
//                    guard let recentlyPlayed = res["recently_played"] as? Any else{return}
////                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
////                    let result = try! JSONDecoder().decode(DiscoverModel.DiscoverSuccessModel.self, from: data)
////                    completionBlock(result,nil,nil,nil)
//                    if recentlyPlayed is [Any]{
//                        log.verbose("There is nothing")
//                        let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
//                        let result = try! JSONDecoder().decode(NotDiscoverModel.DiscoverSuccessModel.self, from: data)
//                        completionBlock(nil,result,nil,nil)
//
//                    }else{
//                        let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
//                        let result = try! JSONDecoder().decode(DiscoverModel.DiscoverSuccessModel.self, from: data)
//                        completionBlock(result,nil,nil,nil)
//                    }
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(DiscoverModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,nil,response.error)
            }
        }
    }
    
}
