//
//  TrackModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 31/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

struct UploadTrackModel : Codable {
    
    let status : Int?
    let file_path : String?
    let file_name : String?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case file_path = "file_path"
        case file_name = "file_name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        file_path = try values.decodeIfPresent(String.self, forKey: .file_path)
        file_name = try values.decodeIfPresent(String.self, forKey: .file_name)
    }

}

class UploadTrackThumbnailModel: BaseModel {
   
    struct UploadTrackThumbnailSuccessModel: Codable {
        let status: Int?
        let thumbnail: String?
        let fullThumbnail: String?
        enum CodingKeys: String, CodingKey {
            case status, thumbnail
            case fullThumbnail = "full_thumbnail"
        }
    }
}

class GetTrackInfoModel: BaseModel {
    struct GetTrackInfoSuccessModel: Codable {
        let status: Int?
        let data: Song?
    }

}
class DeleteTrackModel: BaseModel {
    struct DeleteTrackSuccessModel: Codable {
        let status: Int?
    }

}
