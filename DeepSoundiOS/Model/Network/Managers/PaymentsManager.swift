//
//  PaymentsManager.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 05/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class PaymentManager {
    
    static let instance = PaymentManager()
    
    //MARK: - Paypal -
    func getPaypalTopUp(AccessToken:String,
                        price:String,
                        completionBlock: @escaping (_ Success: String?,
                                                    _ SessionError:String?,
                                                    Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.price: price,
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_PAYPAL)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_PAYPAL,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let data = res["message"] as? String
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
    //MARK: - Securion Token -
    func getSecurionToken(AccessToken:String,
                          type:String,
                          price:String,
                          completionBlock: @escaping (_ Success: String?,
                                                      _ SessionError:String?,
                                                      Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.price: price,
            API.Params.type : type
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_SECURIONPAY)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_SECURIONPAY,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["token"] as? String
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
    //MARK: - Securion Pay -
    func paySecurionPay(AccessToken:String,
                        type:String,
                        chargeId:String,
                        completionBlock: @escaping (_ Success: String?,
                                                    _ SessionError:String?,
                                                    Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.chargeid: chargeId,
            API.Params.type : type
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_SECURIONPAY)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_SECURIONPAY,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else { return }
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let message = res["message"] as? String
                    completionBlock(message,nil,nil)
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
    //MARK: - Authorize Net -
    func getAuthorizenetToken(params: JSON,
                              completionBlock: @escaping (_ Success: String?,
                                                          _ SessionError:String?,
                                                          Error?) ->()) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_AUTHORIZENET)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Payments.TOPUP_AUTHORIZENET,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default ,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["message"] as? String
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
    //MARK: - Razor Pay -
    func getRazorPay(AccessToken:String,
                     payment_id:String,
                     merchant_amount:String,
                     price:String,
                     completionBlock: @escaping (_ Success: String?,
                                                 _ SessionError: String?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.payment_id : payment_id,
            API.Params.merchant_amount : merchant_amount,
            API.Params.price : price
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_RAZORPAY)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_RAZORPAY,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default ,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["message"] as? String
                    completionBlock(data,nil,nil)
                }else{
                    let error = (res["error"] as? NSArray)?.firstObject as? String
                    completionBlock(nil,error,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    //MARK: - Stripe -
    func PayStripe(AccessToken:String,
                   Token:String,
                   completionBlock: @escaping (_ Success: String?,
                                               _ SessionError:String?,
                                               Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.token : Token
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_STRIPE)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_STRIPE,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let data = res["message"] as? String
                    completionBlock(data,nil,nil)
                }else{
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    //MARK: - Cashfree -
    func initializeCashFree(AccessToken:String,
                            type:String,
                            phone:String,
                            name:String,
                            email:String,
                            price:String,
                            completionBlock: @escaping (_ Success: [String:Any]?,
                                                        _ SessionError: String?,
                                                        Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Name : name,
            API.Params.type : type,
            API.Params.Email : email,
            API.Params.phone : phone,
            API.Params.price : price
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_CASHFREE)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_CASHFREE,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    completionBlock(res,nil,nil)
                }else{
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    //MARK: - PayStack -
    func initializePayStack(params:JSON,
                            completionBlock: @escaping (_ Success: String?,
                                                        _ SessionError:String?,
                                                        Error?) ->()) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_PAYSTACK)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_PAYSTACK,
                   method: .post,
                   parameters: params,
                   encoding:URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"]  as? Int else {return}
                let URL = res["url"] as? String
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    if (params["type"] as? String) != "pay" {
                        log.verbose("apiStatus Int = \(apiStatus)")
                        completionBlock(URL,nil,nil)
                    }else {
                        let URL = res["message"] as? String
                        log.verbose("apiStatus Int = \(apiStatus)")
                        completionBlock(URL,nil,nil)
                    }
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?.first,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    //MARK: - PayStack Success -
    func payPayStack(AccessToken:String,
                     type:String,
                     reference:String,
                     price:String,
                     completionBlock: @escaping (_ Success: String?,
                                                 _ SessionError:String?,
                                                 Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.type : type,
            API.Params.reference : reference,
            API.Params.price : price
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_PAYSTACK)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.Payments.TOPUP_PAYSTACK,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let message = res["message"] as? String
                    completionBlock(message,nil,nil)
                }else{
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?.first,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    //MARK: - Paysera -
    func payseraWalletAPI(session_token: String,
                          amount: Int,
                          completionBlock: @escaping (_ Success: String?,
                                                      _ SessionError: String?,
                                                      Error?) -> () ) {
        let params = [
            API.Params.AccessToken : session_token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.type : "initialize",
            API.Params.price: amount
        ] as [String : Any]
        print(params)
        let URL = API.Payments.TOPUP_PAYSERA
        print("URL :=> ",URL)
        
        AF.request(URL,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatus = res["status"] as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH {
                    let url = res["url"] as? String
                    completionBlock(url, nil, nil)
                } else {
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?.first,nil)
                }
            } else {
                if response.response?.statusCode == 500 {
                    completionBlock(nil, nil, response.error)
                }else {
                    completionBlock(nil, nil, response.error)
                }
            }
        }
    }
}
