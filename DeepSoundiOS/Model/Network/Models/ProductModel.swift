//
//  ProductModel.swift
//  DeepSoundiOS
//
//  Created by iMac on 05/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation

class ProductModel: BaseModel {
    struct ProductSuccessModel: Codable {
        let status: Int?
        var data: [Product]?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
}

enum NullSongModel: Codable {
    case bool(Bool)
    case data(Song)
    
    var dataValue : Song? {
        guard case let .data(value) = self else { return nil }
        return value
    }
    
    var boolValue : Bool? {
        guard case let .bool(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(Song.self) {
            self = .data(x)
            return
        }
        throw DecodingError.typeMismatch(NullSongModel.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .data(let x):
            try container.encode(x)
        }
    }
}

enum NullPublisherModel: Codable {
    case bool(Bool)
    case data(Publisher)
    
    var dataValue : Publisher? {
        guard case let .data(value) = self else { return nil }
        return value
    }
    
    var boolValue : Bool? {
        guard case let .bool(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(Publisher.self) {
            self = .data(x)
            return
        }
        throw DecodingError.typeMismatch(NullPublisherModel.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .data(let x):
            try container.encode(x)
        }
    }
}

enum NullUserDataModel: Codable {
    case bool(Bool)
    case data(Publisher)
    
    var dataValue : Publisher? {
        guard case let .data(value) = self else { return nil }
        return value
    }
    
    var boolValue : Bool? {
        guard case let .bool(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(Publisher.self) {
            self = .data(x)
            return
        }
        throw DecodingError.typeMismatch(NullPublisherModel.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .data(let x):
            try container.encode(x)
        }
    }
}
