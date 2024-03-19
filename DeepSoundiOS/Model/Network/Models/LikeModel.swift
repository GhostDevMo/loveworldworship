//
//  LikeModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class LikeModel: BaseModel {    
    struct LikeSuccessModel: Codable {
        let status: Int?
        let mode: String?
    }
}
