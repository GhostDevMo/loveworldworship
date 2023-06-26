//
//  GetOptionsManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK
class GetOptionsManager{
    static let instance = GetOptionsManager()
    
    func getOptions(completionBlock: @escaping (_ Success: [String:Any]?,_ SessionError:String?, Error?) ->()){
        let params = [
           
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Get_Options.GET_OPTIONS)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Get_Options.GET_OPTIONS, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(res,nil,nil)
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
