//
//  RecentlyPlayedModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class RecentlyPlayedModel:BaseModel {
    
    // MARK: - FavoriteModel
    struct RecentlyPlayedSuccessModel: Codable {
        let status: Int?
        let data: SongDataClass?
    }
}

// MARK: - DataClass
struct SongDataClass: Codable {
    let count: Int?
    var data: [Song]?
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case data = "data"
    }
}
