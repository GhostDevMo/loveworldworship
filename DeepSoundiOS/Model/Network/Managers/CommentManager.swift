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

class CommentManager{
    static let instance = CommentManager()
    
    func getComments(TrackId:Int,AccessToken:String,Limit:Int,Offset:Int,completionBlock: @escaping (_ Success:GetCommentModel.GetCommentSuccessModel?,_ SessionError:GetCommentModel.sessionErrorModel?, Error?) ->()){
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
        AF.request(API.Comment_Methods.GET_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(GetCommentModel.GetCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(GetCommentModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func postComment(TrackId:String,AccessToken:String,TimePercentage:Int,Value:String,completionBlock: @escaping (_ Success:PostCommentModel.PostCommentSuccessModel?,_ SessionError:PostCommentModel.sessionErrorModel?, Error?) ->()){
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
        AF.request(API.Comment_Methods.POST_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(PostCommentModel.PostCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(PostCommentModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func likeComment(CommentId:Int,AccessToken:String,completionBlock: @escaping (_ Success:likeDisLikeCommentModel.likeDisLikeCommentSuccessModel?,_ SessionError:likeDisLikeCommentModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: CommentId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.LIKE_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Comment_Methods.LIKE_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(likeDisLikeCommentModel.likeDisLikeCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(likeDisLikeCommentModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func disLikeComment(CommentId:Int,AccessToken:String,completionBlock: @escaping (_ Success:likeDisLikeCommentModel.likeDisLikeCommentSuccessModel?,_ SessionError:likeDisLikeCommentModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: CommentId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Comment_Methods.DISLIKE_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Comment_Methods.DISLIKE_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(likeDisLikeCommentModel.likeDisLikeCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(likeDisLikeCommentModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
