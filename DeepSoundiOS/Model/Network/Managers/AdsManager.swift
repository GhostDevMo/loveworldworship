//
//  AdsManager.swift
//  DeepSoundiOS
//
//  Created by iMac on 19/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation
import DeepSoundSDK
import Alamofire

class AdsManager {
    
    static let instance = AdsManager()
    
    func addAdsAPI(params: JSON, Thumbnail_data: Data?, completionBlock: @escaping (_ Success: String?, _ SessionError: String?, Error?) -> ()) {
       
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        log.verbose("URL String = \(API.ADS_METHODS.ADD_ADS_API)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = Thumbnail_data {
                multipartFormData.append(data, withName: "media", fileName: "thumbnail.jpg", mimeType: "image/png")
            }
        }, to: API.ADS_METHODS.ADD_ADS_API,
                  usingThreshold: UInt64.init(),
                  method: .post,
                  headers: headers).responseJSON { (response) in
            log.verbose("Succesfully uploaded")
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    let data = res["message"] as? String
                    completionBlock(data, nil, nil)
                } else {
                    let data = res["error"] as? String
                    completionBlock(nil, data, nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
