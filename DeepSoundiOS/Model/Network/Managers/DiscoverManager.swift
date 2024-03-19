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

class DiscoverManager {
    
    static let instance = DiscoverManager()
    
    func getDiscover(AccessToken: String, completionBlock: @escaping (_ Success: DiscoverModel.DiscoverSuccessModel?, _ notDisCover: NotDiscoverModel.DiscoverSuccessModel?, _ SessionError: DiscoverModel.sessionErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        print("params >>>>> ", params)
        let urlString = API.Discover_Constants_Methods.DISCOVER_API
        print("urlString >>>>> ", urlString)
        AF.request(urlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatus = res["status"] as? Int else { return }
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    if AppInstance.instance.isLoginUser {
                        let result = try! JSONDecoder().decode(DiscoverModel.DiscoverSuccessModel.self, from: data)
                        completionBlock(result, nil, nil, nil)
                    } else {
                        let result2 = try! JSONDecoder().decode(NotDiscoverModel.DiscoverSuccessModel.self, from: data)
                        completionBlock(nil, result2, nil, nil)
                    }
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(DiscoverModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil, nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, nil, response.error)
            }
        }
    }
    
}
