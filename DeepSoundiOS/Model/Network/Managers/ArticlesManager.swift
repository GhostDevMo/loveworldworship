//
//  ArticlesManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK
class ArticlesManager{
    static let instance = ArticlesManager()
    
    func getArticles(AccessToken:String,limit:Int,offset:Int,completionBlock: @escaping (_ Success:GetArticlesModel.GetArticlesSuccessModel?,_ SessionError:GetArticlesModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Limit: limit,
            API.Params.Offset: offset,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Articles_Methods.GET_ARTICLES_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Articles_Methods.GET_ARTICLES_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(GetArticlesModel.GetArticlesSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(GetArticlesModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func getArticlesComments(AccessToken:String,id:Int,limit:Int,offset:Int,completionBlock: @escaping (_ Success:GetArticlesCommentsModel.GetArticlesCommentsSuccessModel?,_ SessionError:GetArticlesCommentsModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: id,
            //        API.Params.Offset: offset,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Articles_Methods.GET_ARTICLES_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Articles_Methods.GET_ARTICLES_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(GetArticlesCommentsModel.GetArticlesCommentsSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(GetArticlesCommentsModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func createArticleComment(AccessToken:String,id:Int,text:String,completionBlock: @escaping (_ Success:CreateArticleCommentModel.CreateArticleCommentSuccessModel?,_ SessionError:CreateArticleCommentModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: id,
            API.Params.text: text,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Articles_Methods.CREATE_ARTICLES_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Articles_Methods.CREATE_ARTICLES_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(CreateArticleCommentModel.CreateArticleCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(CreateArticleCommentModel.sessionErrorModel.self, from: data)
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
