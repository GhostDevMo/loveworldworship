//
//  ProfileModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation


class ProfileModel: BaseModel, Codable {

    // MARK: - Welcome
    struct ProfileSuccessModel: Codable {
        
        let status: Int?
        var data: Publisher?
        let details: ProfileDetailsData?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
            case details = "details"
        }        
    }
    
    enum ProfileDetailsData: Codable {
        
        case anythingArray([JSONAny])
        case details(Details)
        
        var details: Details? {
            switch self {
            case let .anythingArray(value):
                print(value)
                return nil
            case let .details(value):
                return value
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([JSONAny].self) {
                self = .anythingArray(x)
                return
            }
            if let x = try? container.decode(Details.self) {
                self = .details(x)
                return
            }
            throw DecodingError.typeMismatch(ProfileDetailsData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ChannelsUnion"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .anythingArray(let x):
                try container.encode(x)
            case .details(let x):
                try container.encode(x)
            }
        }
    }
    
}

class UpdateProfileModel:BaseModel {
    
    struct UpdateProfileSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class UpdateMyAccountModel: BaseModel {
    
    struct UpdateMyAccountSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}
class ChangePasswordModel: BaseModel {
    
    struct ChangePasswordSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}
class DeleteAccountModel: BaseModel {
    
    struct DeleteAccountSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class UploadCoverModel: BaseModel {
   
    struct UploadCoverSuccessModel: Codable {
        let status: Int?
        let img: String?
    }

}
class UploadProfileImageModel: BaseModel {
    
    struct UploadProfileImageSuccessModel: Codable {
        let status: Int?
        let img: String?
    }
    
}

