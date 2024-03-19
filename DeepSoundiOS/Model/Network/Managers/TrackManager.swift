//
//  TrackManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 31/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import DeepSoundSDK
import Alamofire

class TrackManager {
    
    static let instance = TrackManager()
    
    func uploadTrack(AccesToken: String, audoFile_data: Data?, completionBlock: @escaping (_ Success: UploadTrackModel?, _ sessionError: BaseModel.sessionErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.AccessToken : AccesToken,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = audoFile_data {
                multipartFormData.append(data, withName: "audio", fileName: "audio.mp3", mimeType: "audio/mp3")
            }
        }, to: API.Upload_Track_Methods.UPLOAD_TRACK_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            log.verbose("Succesfully uploaded")
            if let res = response.value as? [String: Any] {
                guard let apiStatus = res["status"] as? Int else { return }
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(UploadTrackModel.self, from: data)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res as Any, options: [])
                    let result = try! JSONDecoder().decode(BaseModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func uploadTrackThumbnail(AccesToken: String,
                              thumbnailData:Data?,
                              completionBlock: @escaping (_ Success: UploadTrackThumbnailModel.UploadTrackThumbnailSuccessModel?,
                                                          _ sessionError: UploadTrackThumbnailModel.sessionErrorModel?,
                                                          Error?) ->()) {
        let params = [
            API.Params.AccessToken : AccesToken,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = thumbnailData {
                multipartFormData.append(data, withName: "thumbnail", fileName: "audiothumbnail.png", mimeType: "image/png")
            }
        }, to: API.Upload_Track_Methods.UPLOAD_TRACK_THUMBNAIL_API,
                  usingThreshold: UInt64.init(),
                  method: .post,
                  headers: headers).responseJSON { (response) in
            log.verbose("Succesfully uploaded")
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(UploadTrackThumbnailModel.UploadTrackThumbnailSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(UploadTrackThumbnailModel.sessionErrorModel.self, from: data)
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
    func submitTrack(params: JSON, completionBlock: @escaping (_ Success: GetCommentModel.GetCommentSuccessModel?, _ SessionError: GetCommentModel.sessionErrorModel?, Error?) -> () ) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Upload_Track_Methods.SUBMIT_TRACK_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Upload_Track_Methods.SUBMIT_TRACK_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatus = res["status"] as? Int else { return }
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(GetCommentModel.GetCommentSuccessModel.self, from: data)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(GetCommentModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getTrackInfo(TrackId:String,
                      AccessToken:String,
                      completionBlock: @escaping (_ Success: GetTrackInfoModel.GetTrackInfoSuccessModel?,
                                                  _ SessionError: GetTrackInfoModel.sessionErrorModel?,
                                                  Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: TrackId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Upload_Track_Methods.GET_TRACK_INFO)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Upload_Track_Methods.GET_TRACK_INFO,
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
                        let result = try JSONDecoder().decode(GetTrackInfoModel.GetTrackInfoSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(GetTrackInfoModel.sessionErrorModel.self, from: data)
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
    
    func deletTrack(TrackId:Int,
                    AccessToken:String,
                    completionBlock: @escaping (_ Success:DeleteTrackModel.DeleteTrackSuccessModel?,
                                                _ SessionError:DeleteTrackModel.sessionErrorModel?,
                                                Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: TrackId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Delete_Track_Methods.DELETE_TRACK_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Delete_Track_Methods.DELETE_TRACK_API,
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
                        let result = try JSONDecoder().decode(DeleteTrackModel.DeleteTrackSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(DeleteTrackModel.sessionErrorModel.self, from: data)
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
    
    func updateTrack(params: JSON,
                     completionBlock: @escaping (_ Success:GetCommentModel.GetCommentSuccessModel?,
                                                 _ SessionError:GetCommentModel.sessionErrorModel?,
                                                 Error?) ->()) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Upload_Track_Methods.EDIT_TRACK_INFO)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Upload_Track_Methods.EDIT_TRACK_INFO,
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
                        let result = try JSONDecoder().decode(GetCommentModel.GetCommentSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(GetCommentModel.sessionErrorModel.self, from: data)
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
    
    func importTrack(TrackURL:String,
                     AccessToken:String,
                     completionBlock: @escaping (_ Success:GetTrackInfoModel.GetTrackInfoSuccessModel?,
                                                 _ SessionError:GetTrackInfoModel.sessionErrorModel?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.track_link: TrackURL,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Import_Track.IMPORT_TRACK)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Import_Track.IMPORT_TRACK,
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
                        let result = try JSONDecoder().decode(GetTrackInfoModel.GetTrackInfoSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(GetTrackInfoModel.sessionErrorModel.self, from: data)
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

typealias JSON = [String: Any]

extension JSON {
    func getBoolType(with key: String) -> Bool {
        return (self[key] as? String ?? "off") == "off" ? false : true
    }
}
