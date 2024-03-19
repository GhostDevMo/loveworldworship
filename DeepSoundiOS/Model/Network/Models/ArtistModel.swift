//
//  ArtistModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 03/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class ArtistModel: BaseModel {
    
    struct ArtistSuccessModel: Codable {
        let status: Int?
        let data: PublisherDataClass?
    }
    
    struct BecomeAnArtistSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
    
}
