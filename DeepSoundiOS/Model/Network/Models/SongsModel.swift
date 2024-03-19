//
//  SongsModel.swift
//  DeepSoundiOS
//
//  Created by iMac on 28/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation

class SongsModel: BaseModel {
    
    struct SongsSuccessModel: Codable {
        let status: Int?
        var data: [Song]?
    }
    
    struct SongsSuccessWithCountModel: Codable {
        let status: Int?
        var data: SongDataClass?
    }
}
