//
//  ProfileManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class ProfileManger{
    
    static let instance = ProfileManger()
    
    func getProfile(UserId:Int,AccessToken:String, completionBlock: @escaping (_ Success:ProfileModel.ProfileSuccessModel?,_ SessionError:ProfileModel.sessionErrorModel?, Error?) ->()){
        
        let params = [
            
            API.Params.user_id: UserId,
            API.Params.AccessToken: AccessToken,
            API.Params.Fetch: "stations,followers,following,albums,playlists,blocks.favourites,recently_played,liked,activities,latest_songs,top_songs,store",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.GetProfile_Constants_Methods.GET_PROFILE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.GetProfile_Constants_Methods.GET_PROFILE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let responseValue = response.value {
                do {
                    guard let res = responseValue as? [String:Any] else {
                        return
                    }
                    
                    guard let apiStatus = res["status"] as? Int else {
                        return
                    }
                    
                    if apiStatus == API.ERROR_CODES.E_TwoH {
                        log.verbose("apiStatus Int = \(apiStatus)")
                        let data = try JSONSerialization.data(withJSONObject: responseValue, options: [])
                        let result = try JSONDecoder().decode(ProfileModel.ProfileSuccessModel.self, from: data)
                        completionBlock(result, nil, nil)
                    } else {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try JSONSerialization.data(withJSONObject: responseValue as Any, options: [])
                        let result = try JSONDecoder().decode(ProfileModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil, result, nil)
                    }
                } catch {
                    log.error("Error: \(error.localizedDescription)")
                    completionBlock(nil, nil, error)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    func editProfile(UserId:Int,AccessToken:String,Name:String,About_me:String,Facebook:String,Website:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ SessionError:UpdateProfileModel.sessionErrorModel?, Error?) ->()){
        
        let params = [
            
            API.Params.user_id: UserId,
            API.Params.AccessToken: AccessToken,
            API.Params.Name: Name,
            API.Params.AboutMe: About_me,
            API.Params.FaceBook: Facebook,
            API.Params.Website: Website,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UpdateProfile_Constants_Methods.UPDATE_PROFILE_PROFILE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.UpdateProfile_Constants_Methods.UPDATE_PROFILE_PROFILE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func updateMyAccount(UserId:Int,AccessToken:String,Username :String,Email:String,Country:String,Gender:String,Age:Int, completionBlock: @escaping (_ Success:UpdateMyAccountModel.UpdateMyAccountSuccessModel?,_ SessionError:UpdateMyAccountModel.sessionErrorModel?, Error?) ->()){
        
        let params = [
            
            API.Params.user_id: UserId,
            API.Params.AccessToken: AccessToken,
            API.Params.Username: Username,
            API.Params.Email: Email,
            API.Params.Country: Country,
            API.Params.Gender: Gender,
            API.Params.Age: Age,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UpdateProfile_Constants_Methods.UPDATE_PROFILE_PROFILE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.UpdateProfile_Constants_Methods.UPDATE_MYACCOUNT_PROFILE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateMyAccountModel.UpdateMyAccountSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateMyAccountModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func changePasswrod(UserId:Int,AccessToken:String,Current_Password :String,New_Password:String,Repeat_Password:String, completionBlock: @escaping (_ Success:ChangePasswordModel.ChangePasswordSuccessModel?,_ SessionError:ChangePasswordModel.sessionErrorModel?, Error?) ->()){
        
        let params = [
            
            API.Params.user_id: UserId,
            API.Params.AccessToken: AccessToken,
            API.Params.CurrentPassword: Current_Password,
            API.Params.NewPassword: New_Password,
            API.Params.RepeatPassword: Repeat_Password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UpdateProfile_Constants_Methods.CHNAGE_PASSWORD_PROFILE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.UpdateProfile_Constants_Methods.CHNAGE_PASSWORD_PROFILE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(ChangePasswordModel.ChangePasswordSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(ChangePasswordModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func deleteAccount(UserId:Int,AccessToken:String,Current_Password :String, completionBlock: @escaping (_ Success:DeleteAccountModel.DeleteAccountSuccessModel?,_ SessionError:DeleteAccountModel.sessionErrorModel?, Error?) ->()){
        
        let params = [
            
            API.Params.user_id: UserId,
            API.Params.AccessToken: AccessToken,
            API.Params.CurrentPassword: Current_Password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.UpdateProfile_Constants_Methods.DELETE_ACCOUNT_PROFILE_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.UpdateProfile_Constants_Methods.DELETE_ACCOUNT_PROFILE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(DeleteAccountModel.DeleteAccountSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(DeleteAccountModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    
    func uploadCover(AccesToken: String,cover_data:Data?, completionBlock: @escaping (_ Success:UploadCoverModel.UploadCoverSuccessModel?,_ sessionError:UploadCoverModel.sessionErrorModel?, Error?) ->()){
        
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
          
                if let data = cover_data{
                    multipartFormData.append(data, withName: "cover", fileName: "cover.jpg", mimeType: "image/png")
                
            }
            
        }, to: API.UpdateProfile_Constants_Methods.UPDATE_P_COVER_PROFILE_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            log.verbose("response = \(response.value)")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(UploadCoverModel.UploadCoverSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? 0)")
                    completionBlock(result,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                   
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(UploadCoverModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    
                }
               
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func uploadProfileImage(AccesToken: String,profileImage_data:Data?, completionBlock: @escaping (_ Success:UploadProfileImageModel.UploadProfileImageSuccessModel?,_ sessionError:UploadProfileImageModel.sessionErrorModel?, Error?) ->()){
        
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
            
            if let data = profileImage_data{
                multipartFormData.append(data, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
                
            }
            
        }, to: API.UpdateProfile_Constants_Methods.UPDATE_P_AVATAR_PROFILE_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            log.verbose("response = \(response.value ?? nil )")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(UploadProfileImageModel.UploadProfileImageSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? 0)")
                    completionBlock(result,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(UploadProfileImageModel.sessionErrorModel.self, from: data)
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
