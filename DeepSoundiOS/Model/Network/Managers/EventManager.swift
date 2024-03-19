//
//  EventManager.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class EventManager {
    
    static let instance = EventManager()
    
    func getEvents(AccessToken:String,
                   limit:Int,
                   offset:Int,
                   completionBlock: @escaping (_ Success: EventsModel.EventsModelSuccessModel?,
                                               _ SessionError:EventsModel.sessionErrorModel?,
                                               Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Limit: limit,
            API.Params.Offset: offset,
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Events.GET_EVENTS)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Events.GET_EVENTS,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(EventsModel.EventsModelSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }else{
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(EventsModel.sessionErrorModel.self, from: data)
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
    
    func createEvent(params: JSON,
                     image: Data?,
                     completionBlock: @escaping (_ Success: [String:Any]?,
                                                 _ SessionError:String?,
                                                 Error?) ->()) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL =  \(API.Events.CREATE_EVENTS)")
        log.verbose("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = image {
                multipartFormData.append(data, withName: "image", fileName: "media.png", mimeType: "image/png")
            }
        }, to: API.Events.CREATE_EVENTS, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            log.verbose("Succesfully uploaded")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    completionBlock(res,nil,nil)
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
    
    func updateEvent(params: JSON,
                     image: Data?,
                     completionBlock: @escaping (_ Success: [String:Any]?,
                                                 _ SessionError:String?,
                                                 Error?) ->()) {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL =  \(API.Events.EDIT_EVENTS)")
        log.verbose("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = image{
                multipartFormData.append(data, withName: "image", fileName: "media.png", mimeType: "image/png")
            }
        }, to: API.Events.EDIT_EVENTS,
                  usingThreshold: UInt64.init(),
                  method: .post,
                  headers: headers).responseJSON { (response) in
            log.verbose("Updated Succesfully")
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    completionBlock(res,nil,nil)
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
    
    func joinUnjoin(AccessToken:String,
                    id:Int,
                    type:String,
                    completionBlock: @escaping (_ Success: String?,
                                                _ SessionError:String?,
                                                Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.type: type,
            API.Params.Id: id
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Events.JOIN_UNJOIN_EVENTS)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Events.JOIN_UNJOIN_EVENTS,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["type"] as? String
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
    
    func buyTicket(AccessToken:String,
                   id:Int,
                   completionBlock: @escaping (_ Success: String?,
                                               _ SessionError:String?,
                                               Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Id: id
        ] as [String: Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Events.BUY_TICKET_EVENTS)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Events.BUY_TICKET_EVENTS,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["message"] as? String
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
}
