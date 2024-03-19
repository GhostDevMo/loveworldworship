//
//  LoginWithWoWonderModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class LoginWithWoWonderModel {
    
    struct LoginWithWoWonderSuccessModel : Codable {
        
        let api_status : Int?
        let timezone : String?
        let access_token : String?
        let user_id : String?
        let membership : Bool?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case timezone = "timezone"
            case access_token = "access_token"
            case user_id = "user_id"
            case membership = "membership"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(Int.self, forKey: .api_status)
            timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
            access_token = try values.decodeIfPresent(String.self, forKey: .access_token)
            user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
            membership = try values.decodeIfPresent(Bool.self, forKey: .membership)
        }
    }
    
    struct LoginWithWoWonderErrorModel : Codable {
        
        let api_status : String?
        let errors : Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case errors = "errors"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }
        
    }
    
    struct Errors : Codable {
        
        let error_id : String?
        let error_text : String?
        
        enum CodingKeys: String, CodingKey {
            case error_id = "error_id"
            case error_text = "error_text"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            error_id = try values.decodeIfPresent(String.self, forKey: .error_id)
            error_text = try values.decodeIfPresent(String.self, forKey: .error_text)
        }
        
    }
    
}
