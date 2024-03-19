//
//  AddressManager.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation
import DeepSoundSDK
import Alamofire

class AddressManger {
    
    static let instance = AddressManger()
    
    func getAddress(access_token: String,
                    completionBlock: @escaping (_ Success: AddressModel.AddressSuccessModel?,
                                                _ SessionError: AddressModel.sessionErrorModel?,
                                                Error?) -> ()) {
        let params = [
            API.Params.AccessToken: access_token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        let urlString = API.Address_Constants_Methods.GET_ADDRESS_API
        log.verbose("params >>>>> \(params)")
        log.verbose("urlString >>>>> \(urlString)")
        
        AF.request(urlString,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(AddressModel.AddressSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(AddressModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func deleteAddress(access_token: String, id: Int, completionBlock: @escaping (_ Success: AddressModel.DeleteAddressSuccessModel?, _ SessionError: AddressModel.sessionErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.AccessToken: access_token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Id: id
        ] as [String : Any]
        let urlString = API.Address_Constants_Methods.DELETE_ADDRESS_API
        log.verbose("params >>>>> \(params)")
        log.verbose("urlString >>>>> \(urlString)")
        
        AF.request(urlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(AddressModel.DeleteAddressSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(AddressModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addAddress(params: JSON, completionBlock: @escaping (_ Success: AddressModel.ManageAddressSuccessModel?, _ SessionError: AddressModel.sessionErrorModel?, Error?) -> () ) {
        
        let urlString = API.Address_Constants_Methods.ADD_ADDRESS_API
        log.verbose("params >>>>> \(params)")
        log.verbose("urlString >>>>> \(urlString)")
        
        AF.request(urlString,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(AddressModel.ManageAddressSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(AddressModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func editAddress(params: JSON, completionBlock: @escaping (_ Success: AddressModel.ManageAddressSuccessModel?, _ SessionError: AddressModel.sessionErrorModel?, Error?) -> () ) {
        
        let urlString = API.Address_Constants_Methods.EDIT_ADDRESS_API
        log.verbose("params >>>>> \(params)")
        log.verbose("urlString >>>>> \(urlString)")
        
        AF.request(urlString,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(AddressModel.ManageAddressSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(AddressModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getByIdAddress(access_token: String,
                        id: Int,
                        completionBlock: @escaping (_ Success: AddressModel.GetByIdAddressSuccessModel?,
                                                    _ SessionError: AddressModel.sessionErrorModel?,
                                                    Error?) -> ()) {
        let params = [
            API.Params.AccessToken: access_token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Id: id
        ] as [String : Any]
        let urlString = API.Address_Constants_Methods.GET_BY_ID_ADDRESS_API
        log.verbose("params >>>>> \(params)")
        log.verbose("urlString >>>>> \(urlString)")
        
        AF.request(urlString,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["status"] as? Int else {return}
                log.verbose("apiStatus Int = \(apiStatus)")
                if apiStatus == API.ERROR_CODES.E_TwoH {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value!, options: [])
                        let result = try JSONDecoder().decode(AddressModel.GetByIdAddressSuccessModel.self, from: data)
                        completionBlock(result,nil,nil)
                    }catch(let err){
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                } else {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                        let result = try JSONDecoder().decode(AddressModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                    }catch(let err) {
                        log.error("error = \(err.localizedDescription)")
                        completionBlock(nil,nil,err)
                    }
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
}
