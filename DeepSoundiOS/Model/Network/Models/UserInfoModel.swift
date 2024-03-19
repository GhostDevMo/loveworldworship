//
//  UserInfoModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class UserInfoModel: BaseModel {
 
    // MARK: - Welcome
    struct UserInfoSuccessModel: Codable {
        let status: Int?
        let data: Publisher?
        let details: Details?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
            case details = "details"
        } 
    }
}
