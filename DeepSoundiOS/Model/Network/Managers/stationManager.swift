//
//  stationManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 08/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.


import Foundation
import Alamofire
import DeepSoundSDK

class stationManager {
    
    static let instance = stationManager()
    
    func getStations(AccessToken: String,
                     keyword: String,
                     completionBlock: @escaping (_ Success:  [[String:Any]]?,
                                                 _ SessionError:String?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Keyword: keyword,
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Stations.GET_STATIONS)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Stations.GET_STATIONS,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["data"] as? [[String:Any]]
                    completionBlock(data,nil,nil)
                }else{
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func addStations(AccessToken:String,
                     id:String,
                     station:String,
                     url:String,
                     logo:String,
                     genre:String,
                     country:String,
                     completionBlock: @escaping (_ Success:  [String:Any]?,
                                                 _ SessionError:String?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Id: id,
            API.Params.station:station,
            API.Params.url:url,
            API.Params.logo:logo,
            API.Params.genre:genre,
            API.Params.country:country
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL =  \(API.Stations.ADD_STATION)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Stations.ADD_STATION,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    completionBlock(res,nil,nil)
                }else {
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
