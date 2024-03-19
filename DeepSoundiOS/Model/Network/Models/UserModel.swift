//
//  UserModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class LoginModel:BaseModel {
    struct LoginSuccessModel: Codable {
        let status: Int?
        let accessToken: String?
        let data: Publisher?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case accessToken = "access_token"
            case data = "data"
        }
    }
}

class RegisterModel:BaseModel {    
    struct RegisterSuccessModel: Codable {
        let status, waitValidation: Int?
        let accessToken: String?
        let data: Publisher?
        
        enum CodingKeys: String, CodingKey {
            case status
            case waitValidation = "wait_validation"
            case accessToken = "access_token"
            case data = "data"
        }
    }
}

class SocialLoginModel: BaseModel {
    struct SocialLoginSuccessModel: Codable {
        let status, waitValidation: Int?
        let accessToken: String?
        let data: Publisher?
        
        enum CodingKeys: String, CodingKey {
            case status
            case waitValidation = "wait_validation"
            case accessToken = "access_token"
            case data = "data"
        }
    }
    
    struct SocialLoginErrorModel: Codable {
        let status: Int?
        let error: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case error
        }
    }
}

class LogoutModel:BaseModel {
    struct LogoutSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class ResetPasswordModel:BaseModel {
    
    struct ResetPasswordSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class TwoFactorLoginModel: BaseModel {
    struct TwoFactorLoginSuccessModel: Codable {
        let status: Int
        let data: String
        let userID: Int
        
        enum CodingKeys: String, CodingKey {
            case status, data
            case userID = "user_id"
        }
    }
}

class TrendSearchModel:BaseModel {
    struct TrendSearchSuccessModel: Codable {
        let status: Int
        let data: [TrendSearch]
        
        enum CodingKeys: String, CodingKey {
            case status
            case data
        }
    }
}

struct TrendSearch: Codable {
    var id : Int
    var keyword : String
}
