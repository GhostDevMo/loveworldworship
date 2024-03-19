//
//  PlaylistModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 03/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class PublicPlaylistModel: BaseModel {
    struct PublicPlaylistSuccessModel: Codable {
        let status: Int?
        let playlists: [Playlist]?
        let count: Int?
    }
}
class PlaylistModel: BaseModel {
    struct PlaylistSuccessModel: Codable {
        let status: Int?
        let playlists: [Playlist]?
        let count: Int?
    }
}

class GetPlaylistSongsModel: BaseModel {
    struct GetPlaylistSongsSuccessModel: Codable {
        let status: Int?
        let songs: [Song]?
    }
}

struct CreatePlaylistModel: Codable {
    
    let status : Int?
    let data : Playlist?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(Playlist.self, forKey: .data)
    }
    
}

class UpdatePlaylistModel: BaseModel {
    struct UpdatePlaylistSuccessModel: Codable {
        let status: Int?
    }
}
class DeletePlaylistModel: BaseModel {
    struct DeletePlaylistSuccessModel: Codable {
        let status: Int?
    }
}
class AddToPlaylistModel: BaseModel {
    struct AddToPlaylistSuccessModel: Codable {
        let status: Int?
    }
}



