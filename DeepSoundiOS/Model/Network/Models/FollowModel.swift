//
//  FollowModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 02/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class FollowingModel: BaseModel {
    struct FollowingSuccessModel: Codable {
        let status: Int?
        let data: PublisherDataClass?
    }
}

class FollowerModel: BaseModel {
    struct FollowerSuccessModel: Codable {
        let status: Int?
        let data: PublisherDataClass?
    }
}

class FollowUserModel: BaseModel {
    struct FollowUserSuccessModel: Codable {
        let status: Int?
    }
}

class UnFollowUserModel: BaseModel {
    struct UnFollowUserSuccessModel: Codable {
        let status: Int?
    }
}

