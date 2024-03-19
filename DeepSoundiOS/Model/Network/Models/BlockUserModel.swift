//
//  BlockUserModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 01/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetBlockUsersModel: BaseModel {
    struct GetBlockUsersSuccessModel: Codable {
        let status: Int?
        let data: PublisherDataClass?
    }
}

// MARK: - Publisher DataClass
struct PublisherDataClass: Codable {
    let count: Int?
    let data: [Publisher]?
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case data = "data"
    }
}

class UnblockUserModel:BaseModel {    
    struct UnblockUserSuccessModel: Codable {
        let status: Int?
    }
}

class blockUserModel:BaseModel {
    struct blockUserSuccessModel: Codable {
        let status: Int?
    }
}
