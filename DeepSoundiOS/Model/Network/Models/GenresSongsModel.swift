//
//  GenresSongsModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GenresSongsModel: BaseModel {
    
    // MARK: - GenresSongsModel
    struct GenresSongsSuccessModel: Codable {
        let status: Int?
        let tracks: SongDataClass?
    }
}
