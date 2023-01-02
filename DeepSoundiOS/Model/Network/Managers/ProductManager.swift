//
//  ProductManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK
class ProductManager{
    static let instance = ProductManager()
    
    func getProducts(AccessToken:String,priceTo:Int,priceFrom:Int,category:String,completionBlock: @escaping (_ Success: [[String:Any]]?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.price_from: priceFrom,
            API.Params.price_to: priceTo,
            API.Params.category: category,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Products.GET_PRODUCTS)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Products.GET_PRODUCTS, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let data = res["data"] as? [[String:Any]]
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(data,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func AddToCart(AccessToken:String,productID:Int,completionBlock: @escaping (_ Success: [String:Any]?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.product_id: productID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Products.ADD_CART)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Products.ADD_CART, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(res,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func RemoveFromCart(AccessToken:String,productID:Int,completionBlock: @escaping (_ Success: [String:Any]?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.product_id: productID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Products.REMOVE_CART)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Products.REMOVE_CART, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(res,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func getCart(AccessToken:String,completionBlock: @escaping (_ Success: [[String:Any]]?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Products.GET_CART)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Products.GET_CART, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let array = res["array"] as? [[String:Any]]
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(array,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func createProduct(AccesToken: String,title:String,desc:String,tags:String,price:String,unit:String,related:Int,category:Int,mediaData:[Data]?, completionBlock: @escaping (_ Success:[String:Any]?,_ sessionError:[String:Any]?, Error?) ->()){
        
        let params = [
            API.Params.AccessToken : AccesToken,
            API.Params.Title : title,
            API.Params.desc: desc,
            API.Params.Tag:tags,
            API.Params.price :price,
            API.Params.unit :unit,
            API.Params.related :related,
            API.Params.category:category,
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
            for i in mediaData ?? []{
                multipartFormData.append(i, withName: "image[]", fileName: "media.png", mimeType: "image/png")
            }
        }, to: API.Products.CREATE_PRODUCT, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            log.verbose("response = \(response.value)")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
//                    log.verbose("apiStatus Int = \(apiStatus)")
//                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
//                    let result = try! JSONDecoder().decode(BankTransferModel.BankTransferSuccessModel.self, from: data)
//                    log.debug("Success = \(result.status ?? 0)")
                    completionBlock(res,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(BankTransferModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,res,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateProduct(id:Int,AccesToken: String,title:String,desc:String,tags:String,price:String,unit:String,related:Int,category:Int, completionBlock: @escaping (_ Success:[String:Any]?,_ sessionError:[String:Any]?, Error?) ->()){
        
        let params = [
            API.Params.AccessToken : AccesToken,
            API.Params.Id:id,
            API.Params.Title : title,
            API.Params.desc: desc,
            API.Params.Tag:tags,
            API.Params.price :price,
            API.Params.unit :unit,
            API.Params.related :related,
            API.Params.category:category,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Products.EDIT_PRODUCT)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Products.EDIT_PRODUCT, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    completionBlock(res,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? String
                    completionBlock(nil,res,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
