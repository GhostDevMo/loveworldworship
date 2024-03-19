//
//  FavoriteModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class FavoriteModel: BaseModel {    
    // MARK: - FavoriteModel
    struct FavoriteSuccessModel: Codable {
        let status: Int?
        let data: SongDataClass?
    }
}

class PostFavoriteModel: BaseModel {
    struct PostFavoriteSuccessModel: Codable {
        let status: Int?
        let mode: String?
    }
}
