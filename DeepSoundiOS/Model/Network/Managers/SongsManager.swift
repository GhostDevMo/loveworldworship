//
//  TopSongsManager.swift
//  DeepSoundiOS
//
//  Created by iMac on 28/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class SongsManager {
    
    static let instance = SongsManager()
    
    func getTopSongsAPI(limit:Int,
                        offSet: String,
                        completionBlock: @escaping(_ Success: SongsModel.SongsSuccessModel?,
                                                   _ SessionError: SongsModel.sessionErrorModel?,
                                                   Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Limit: limit,
            API.Params.Offset: offSet
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let url = API.COMMON_METHODS.GET_TOP_SONGS_API
        log.verbose("Targeted URL = \(url)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(url, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(SongsModel.SongsSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(SongsModel.sessionErrorModel.self, from: data)
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
    
    func getLatestSongsAPI(limit:Int,
                           offSet: String,
                           completionBlock: @escaping(_ Success: SongsModel.SongsSuccessModel?,
                                                      _ SessionError: SongsModel.sessionErrorModel?,
                                                      Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Limit: limit,
            API.Params.Offset: offSet
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let url = API.COMMON_METHODS.GET_LATEST_SONGS_API
        log.verbose("Targeted URL = \(url)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(url,
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
                        let result = try JSONDecoder().decode(SongsModel.SongsSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(SongsModel.sessionErrorModel.self, from: data)
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
    
    func getUserTopSongsAPI(userID: Int,
                            limit:Int,
                            ids: Int,
                            last_view: Int,
                            completionBlock: @escaping(_ Success: SongsModel.SongsSuccessModel?,
                                                   _ SessionError: SongsModel.sessionErrorModel?,
                                                   Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.user_id: userID,
            API.Params.Limit: limit,
            "ids": ids,
            "last_view": last_view
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let url = API.USER_CONSTANTS_METHODS.GET_TOP_SONG_API
        log.verbose("Targeted URL = \(url)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(url, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(SongsModel.SongsSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(SongsModel.sessionErrorModel.self, from: data)
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
    
    
    func getUserLatestSongsAPI(userID: Int,
                            limit:Int,
                            offSet: Int,
                            completionBlock: @escaping(_ Success: SongsModel.SongsSuccessModel?,
                                                   _ SessionError: SongsModel.sessionErrorModel?,
                                                   Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.user_id: userID,
            API.Params.Limit: limit,
            API.Params.Offset: offSet
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let url = API.USER_CONSTANTS_METHODS.GET_LATEST_SONG_API
        log.verbose("Targeted URL = \(url)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(url, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(SongsModel.SongsSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(SongsModel.sessionErrorModel.self, from: data)
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
