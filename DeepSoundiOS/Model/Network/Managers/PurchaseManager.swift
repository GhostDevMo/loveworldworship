//
//  PurchaseManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class PurchaseManager {
    
    static let instance = PurchaseManager()
    
    func getPurchases(AccessToken:String,
                      userId:Int,
                      limit:Int,
                      offset:Int,
                      completionBlock: @escaping (_ Success:GetPurchaseModel.GetPurchaseSuccessModel?,
                                                  _ SessionError:GetPurchaseModel.sessionErrorModel?,
                                                  Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: userId,
            API.Params.Limit: limit,
            API.Params.Offset: offset,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Get_Purchase_Methods.GET_PURCHASES_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Get_Purchase_Methods.GET_PURCHASES_API,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(GetPurchaseModel.GetPurchaseSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(GetPurchaseModel.sessionErrorModel.self, from: data)
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
