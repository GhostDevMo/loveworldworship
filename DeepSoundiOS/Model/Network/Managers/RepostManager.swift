//
//  RepostManager.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation
import DeepSoundSDK
import Alamofire

class RepostManager {
    
    static let instance = RepostManager()
    
    
    func repostAPI(Id: Int,
                   completionBlock: @escaping (_ Success: String?,
                                               _ SessionError: String?,
                                               Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.Id: Id,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.REPOST_TRACK_METHODS.REPOST_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.REPOST_TRACK_METHODS.REPOST_API,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus String = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let msg = res["data"] as? String
                    completionBlock(msg,nil,nil)
                }else{
                    let msg = res["error"] as? String
                    completionBlock(nil,msg,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
