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
class PaymentManager{
    
    static let instance = PaymentManager()
    func getPaypalTopUp(AccessToken:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.price: price,
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_PAYPAL)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Payments.TOPUP_PAYPAL, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
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
    
    func getSecurionToken(AccessToken:String,type:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
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
        AF.request(API.Payments.TOPUP_SECURIONPAY, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let data = res["token"] as? String
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
    
    func paySecurionPay(AccessToken:String,type:String,chargeId:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
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
        AF.request(API.Payments.TOPUP_SECURIONPAY, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let message = res["message"] as? String
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(message,nil,nil)
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
    
    
    
    
    func getAuthorizenetToken(AccessToken:String,card_number:String,card_month:String,card_cvc:String,card_year:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.card_number : card_number,
            API.Params.card_month : card_month,
            API.Params.card_cvc : card_cvc,
            API.Params.card_year : card_year,
            API.Params.price: price
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_AUTHORIZENET)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Payments.TOPUP_AUTHORIZENET, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
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
    func getRazorPay(AccessToken:String,payment_id:String,merchant_amount:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
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
        AF.request(API.Payments.TOPUP_RAZORPAY, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
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
    func PayStripe(AccessToken:String,Token:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.token : Token
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_STRIPE)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Payments.TOPUP_STRIPE, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let data = res["message"] as? String
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(data,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func initializeCashFree(AccessToken:String,type:String,phone:String,name:String,email:String,price:String,completionBlock: @escaping (_ Success: [String:Any]?,_ SessionError:String?, Error?) ->()){
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
        AF.request(API.Payments.TOPUP_CASHFREE, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(res,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func initializePayStack(AccessToken:String,type:String,email:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.type : type,
            API.Params.Email : email,
            API.Params.price : price
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Payments.TOPUP_PAYSTACK)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Payments.TOPUP_PAYSTACK, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let URL = res["url"] as? String
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(URL,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func payPayStack(AccessToken:String,type:String,reference:String,price:String,completionBlock: @escaping (_ Success: String?,_ SessionError:String?, Error?) ->()){
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
        AF.request(API.Payments.TOPUP_PAYSTACK, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    let message = res["message"] as? String
                    log.verbose("apiStatus Int = \(apiStatus)")
                    completionBlock(message,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let error = res["error"] as? [String]
                    completionBlock(nil,error?[0],nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
