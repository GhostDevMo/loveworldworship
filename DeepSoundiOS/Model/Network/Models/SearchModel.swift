//
//  SearchModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class SearchModel: BaseModel {
    
    // MARK: - Welcome
    struct SearchSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let songs: SearchSongs?
        let albums: [Album]?
        let artist: [Publisher]?
        let playlist: [Playlist]?
        let events: [Events]?
        let products: [Product]?
        
        var songsData: [Song] {
            return songs?.stringValue ?? []
        }
    }
}

enum SearchSongs: Codable {
    
    case dictionary([String: Song])
    case array([Song])
    
    var stringValue : [Song]? {
        switch self {
        case .dictionary(let value):
            let data = value.values.filter({$0.id != nil})
            return data
        case .array(let value):
            return value
        }
    }    
        
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String: Song].self) {
            self = .dictionary(x)
            return
        }
        if let x = try? container.decode([Song].self) {
            self = .array(x)
            return
        }
        throw DecodingError.typeMismatch(SearchSongs.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .dictionary(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        }
    }
}
