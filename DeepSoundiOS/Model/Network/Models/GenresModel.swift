//
//  GenresModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GenresModel:BaseModel{
    
    struct GenresSuccessModel: Codable {
        let status: Int?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let id: Int?
        let cateogryName: String?
        let tracks: Int?
        let color: String?
        let backgroundThumb: String?
        let time: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case cateogryName = "cateogry_name"
            case tracks, color
            case backgroundThumb = "background_thumb"
            case time
        }
    }

}
class UpdateInterestModel:BaseModel{
    
    struct UpdateInterestSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
    
}

