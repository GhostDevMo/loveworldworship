//
//  CommentManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class CommentManager {
    static let instance = CommentManager()
    
    func getComments(TrackId:Int,
                     AccessToken:String,
                     Limit:Int,
                     Offset:Int,
                     completionBlock: @escaping (_ Success:GetCommentModel.GetCommentSuccessModel?,
                                                 _ SessionError:GetCommentModel.sessionErrorModel?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: TrackId,
            API.Params.Limit: Limit,
            API.Params.Offset: Offset,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.GET_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.GET_COMMENT_API,
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
                        let result = try JSONDecoder().decode(GetCommentModel.GetCommentSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }else{
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
    
    func postComment(TrackId:String,
                     AccessToken:String,
                     TimePercentage:Int,
                     Value:String,
                     completionBlock: @escaping (_ Success:PostCommentModel.PostCommentSuccessModel?,
                                                 _ SessionError:PostCommentModel.sessionErrorModel?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: TrackId,
            API.Params.TimePercentage: TimePercentage,
            API.Params.Value: Value,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.POST_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.POST_COMMENT_API,
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
                        let result = try JSONDecoder().decode(PostCommentModel.PostCommentSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }else{
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(PostCommentModel.sessionErrorModel.self, from: data)
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
    
    func likeComment(CommentId:Int,
                     AccessToken:String,
                     completionBlock: @escaping (_ Success:Bool?,
                                                 _ SessionError:Bool?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: CommentId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.LIKE_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.LIKE_COMMENT_API,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                        completionBlock(true,nil,nil)
                }else{
                    completionBlock(nil,true,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func disLikeComment(CommentId:Int,
                        AccessToken:String,
                        completionBlock: @escaping (_ Success:likeDisLikeCommentModel.likeDisLikeCommentSuccessModel?,
                                                    _ SessionError:likeDisLikeCommentModel.sessionErrorModel?,
                                                    Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.Id: CommentId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.DISLIKE_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.DISLIKE_COMMENT_API,
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
                        let result = try JSONDecoder().decode(likeDisLikeCommentModel.likeDisLikeCommentSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }else{
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(likeDisLikeCommentModel.sessionErrorModel.self, from: data)
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
    
    func reportCommentAPI(id: Int,
                          text: String,
                          completionBlock: @escaping (_ Success: String?,
                                                      _ SessionError: String?,
                                                      Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.Id: id,
            "comment_description": text,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.REPORT_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.REPORT_COMMENT_API,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock("Thanks for your submission, we will review your request shortly.",nil,nil)
                    //The comment report was successfully deleted.
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = res["error"] as? String
                    completionBlock(nil,data,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func unreportCommentAPI(id: Int,
                            completionBlock: @escaping (_ Success: String?,
                                                        _ SessionError: String?,
                                                        Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.Id: id,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Articles_Methods.CREATE_ARTICLES_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Comment_Methods.UNREPORT_COMMENT_API,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock("The comment report was successfully deleted.",nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = res["error"] as? String
                    completionBlock(nil,data,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
