//
//  TopSongsModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 04/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class TrendingModel:BaseModel {
    
    struct TrendingSuccessModel: Codable {
        let status: Int?
        let topAlbums: [Album]?
        var topSongs: [Song]?
        
        enum CodingKeys: String, CodingKey {
            case status
            case topAlbums = "top_albums"
            case topSongs = "top_songs"
        }
    }       
}
