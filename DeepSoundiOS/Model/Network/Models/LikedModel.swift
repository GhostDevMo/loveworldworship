//
//  LikedModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//


import Foundation

class LikedModel: BaseModel {
    
    // MARK: - FavoriteModel
    struct LikedSuccessModel: Codable {
        let status: Int?
        let data: SongDataClass?
    }
}
