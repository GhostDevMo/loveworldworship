//
//  UserManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class UserManager {
    
    static let instance = UserManager()
    
    func authenticateUser(UserName: String,
                          Password: String,
                          DeviceId:String,
                          completionBlock: @escaping (_ Success:LoginModel.LoginSuccessModel?,
                                                      _ TwoFactorSuccss:TwoFactorLoginModel.TwoFactorLoginSuccessModel?,
                                                      _ SessionError:LoginModel.sessionErrorModel?,
                                                      Error?) ->()) {
        let params = [
            API.Params.Username: UserName,
            API.Params.Password: Password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.DeviceId : DeviceId
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.LOGIN_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    guard let data = res["data"] else {return }
                    if data is String {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                            let result = try JSONDecoder().decode(TwoFactorLoginModel.TwoFactorLoginSuccessModel.self, from: data)
                            completionBlock(nil,result,nil,nil)
                        }catch(let err){
                            log.error("error = \(err.localizedDescription)")
                            completionBlock(nil,nil,nil,err)
                        }
                        
                    }else{
                        do {
                            let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                            let result = try JSONDecoder().decode(LoginModel.LoginSuccessModel.self, from: data)
                            log.debug("Success = \(result.accessToken ?? "")")
                            let User_Session = [Local.USER_SESSION.Access_token:result.accessToken ?? "",Local.USER_SESSION.User_id:result.data?.id ?? 0] as [String : Any]
                            UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                            completionBlock(result,nil,nil,nil)
                        }catch(let err){
                            log.error("error = \(err.localizedDescription)")
                            completionBlock(nil,nil,nil,err)
                        }
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(LoginModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,nil,err)
                    }
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,nil,response.error)
            }
        }
    }
    
    func registerUser(Name:String,
                      Email:String,
                      UserName: String,
                      Password: String,
                      ConfirmPassword:String,
                      DeviceId:String,
                      completionBlock: @escaping (_ Success:RegisterModel.RegisterSuccessModel?,
                                                  _ SessionError:RegisterModel.sessionErrorModel?,
                                                  Error?) ->()) {
        let params = [
            API.Params.Name: Name,
            API.Params.Email: Email,
            API.Params.Username: UserName,
            API.Params.Password: Password,
            API.Params.ConfirmPassword : ConfirmPassword,
            API.Params.DeviceId : DeviceId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.REGISTER_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.REGISTER_API,
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
                        let result = try JSONDecoder().decode(RegisterModel.RegisterSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(RegisterModel.sessionErrorModel.self, from: data)
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
    
    func socialLogin(Provider:String,
                     AccessToken:String,
                     DeviceId:String,
                     completionBlock: @escaping (_ Success:SocialLoginModel.SocialLoginSuccessModel?,
                                                 _ SessionError:SocialLoginModel.sessionErrorModel?,
                                                 Error?) ->()) {
        var params = [
            API.Params.Provider: Provider,
            API.Params.SocialAccessToken: AccessToken,
            API.Params.SocialDeviceID: DeviceId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API,
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
                        let result = try JSONDecoder().decode(SocialLoginModel.SocialLoginSuccessModel.self, from: data)
                        log.debug("Success = \(result.accessToken ?? "")")
                        let User_Session = [Local.USER_SESSION.Access_token:result.accessToken as Any,Local.USER_SESSION.User_id:result.data?.id as Any] as [String : Any]
                        UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(SocialLoginModel.sessionErrorModel.self, from: data)
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
    
    func applelogin(Provider: String, AccessToken: String, DeviceID: String, completionBlock: @escaping (_ Success: SocialLoginModel.SocialLoginSuccessModel?, _ SessionError:SocialLoginModel.sessionErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Provider: Provider,
            API.Params.SocialAccessToken: AccessToken,
            API.Params.SocialDeviceID: DeviceID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(SocialLoginModel.SocialLoginSuccessModel.self, from: data)
                    log.debug("Success = \(result.accessToken ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.accessToken as Any,Local.USER_SESSION.User_id:result.data?.id as Any] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(SocialLoginModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func LogoutUser(AccessToken:String,
                    completionBlock: @escaping (_ Success:LogoutModel.LogoutSuccessModel?,
                                                _ SessionError:LogoutModel.sessionErrorModel?,
                                                Error?) ->()) {
        let params = [
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.LOGOUT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.LOGOUT_API,
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
                        let result = try JSONDecoder().decode(LogoutModel.LogoutSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(LogoutModel.sessionErrorModel.self, from: data)
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
    
    func ForgetPassword(Email:String,
                        completionBlock: @escaping (_ Success: ResetPasswordModel.ResetPasswordSuccessModel?,
                                                    _ SessionError: ResetPasswordModel.sessionErrorModel?,
                                                    Error?) ->()) {
        let params = [
            API.Params.Email: Email,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.LOGOUT_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.FORGETPASSWORD_API,
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
                        let result = try JSONDecoder().decode(ResetPasswordModel.ResetPasswordSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(ResetPasswordModel.sessionErrorModel.self, from: data)
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
    
    func loginWithWoWonder(userName: String, password: String, completionBlock : @escaping (_ Success:LoginWithWoWonderModel.LoginWithWoWonderSuccessModel?, _ AuthError : LoginWithWoWonderModel.LoginWithWoWonderErrorModel?, Error?) -> () ) {
        let params  = [
            API.Params.ServerKey : ControlSettings.wowonder_ServerKey,
            API.Params.Username : userName,
            API.Params.Password : password
        ]
        AF.request(API.AUTH_WOWONDER_METHODS.AUTH_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatusCode = res["api_status"] else { return }
                if apiStatusCode is Int {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(LoginWithWoWonderModel.LoginWithWoWonderSuccessModel.self, from: data)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(LoginWithWoWonderModel.LoginWithWoWonderErrorModel.self, from: data)
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error(response.error?.localizedDescription ?? "")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func verifyTwoFactor(userID: Int,
                         code: String,
                         completionBlock: @escaping (_ Success:LoginModel.LoginSuccessModel?,
                                                     _ SessionError:LoginModel.sessionErrorModel?,
                                                     Error?) ->()) {
        let params = [
            API.Params.user_id: userID,
            API.Params.confirm_code: code,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.VERIFY_TWO_FACTOR_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.AUTH_Constants_Methods.VERIFY_TWO_FACTOR_API,
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
                        let result = try JSONDecoder().decode(LoginModel.LoginSuccessModel.self, from: data)
                        log.debug("Success = \(result.accessToken ?? "")")
                        let User_Session = [Local.USER_SESSION.Access_token:result.accessToken ?? "",Local.USER_SESSION.User_id:result.data?.id ?? 0] as [String : Any]
                        UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(LoginModel.sessionErrorModel.self, from: data)
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
    
    func trendSearchAPI(completionBlock: @escaping (_ Success: TrendSearchModel.TrendSearchSuccessModel?,
                                                    _ SessionError: TrendSearchModel.sessionErrorModel?,
                                                    Error?) ->()) {
        let params = [
            API.Params.AccessToken: AppInstance.instance.accessToken ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UserInfo_Methods.TREND_SEARCH_API)")
        log.verbose("Decoded String = \(decoded)")
        
        AF.request(API.UserInfo_Methods.TREND_SEARCH_API,
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
                        let result = try JSONDecoder().decode(TrendSearchModel.TrendSearchSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(TrendSearchModel.sessionErrorModel.self, from: data)
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
