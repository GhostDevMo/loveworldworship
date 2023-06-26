//
//  LikeManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class likeManager{
    static let instance = likeManager()
    func likeDisLikeSong(audiotId:String,AccessToken:String,completionBlock: @escaping (_ Success:LikeModel.LikeSuccessModel?,_ SessionError:LikeModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: audiotId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Like_Methods.LIKE_DISLIKE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Like_Methods.LIKE_DISLIKE_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(LikeModel.LikeSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else if apiStatus ==  300{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(LikeModel.LikeSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                } else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(LikeModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func likeDisLikeTrack(audiotId:String,AccessToken:String,completionBlock: @escaping (_ Success:LikeModel.LikeSuccessModel?,_ SessionError:LikeModel.sessionErrorModel?, Error?) ->()){
           let params = [
               
               API.Params.AccessToken: AccessToken,
               API.Params.Id: audiotId,
               API.Params.ServerKey: API.SERVER_KEY.Server_Key
               
               ] as [String : Any]
           
           let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
           let decoded = String(data: jsonData, encoding: .utf8)!
           log.verbose("Targeted URL = \(API.DisLike_Track.DISLIKE_TRACK)")
           log.verbose("Decoded String = \(decoded)")
        AF.request(API.DisLike_Track.DISLIKE_TRACK, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
               
               if (response.value != nil){
                   guard let res = response.value as? [String:Any] else {return}
                   
                   guard let apiStatus = res["status"]  as? Int else {return}
                   if apiStatus ==  API.ERROR_CODES.E_TwoH{
                       log.verbose("apiStatus Int = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                       let result = try! JSONDecoder().decode(LikeModel.LikeSuccessModel.self, from: data)
                       completionBlock(result,nil,nil)
                   }else if apiStatus ==  300{
                       log.verbose("apiStatus Int = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                       let result = try! JSONDecoder().decode(LikeModel.LikeSuccessModel.self, from: data)
                       completionBlock(result,nil,nil)
                   } else{
                       log.verbose("apiStatus String = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                       let result = try! JSONDecoder().decode(LikeModel.sessionErrorModel.self, from: data)
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
