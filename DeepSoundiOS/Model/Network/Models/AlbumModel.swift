//
//  AlbumModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetAlbumSongsModel:BaseModel{
    
    struct GetAlbumSongsSuccessModel: Codable {
        let status: Int?
        let songs: [Song]?
    }
    
    // MARK: - Song
    struct Song: Codable {
        let id, userID: Int?
        let audioID, title, songDescription, tags: String?
        let thumbnail: String?
        let availability, ageRestriction, time, views: Int?
        let artistID, albumID: Int?
        let duration, demoDuration: String?
        let audioLocation: String?
        let demoTrack: String?
        let categoryID: Int?
        let registered: String?
        let size: Int?
        let darkWave, lightWave: String?
        let shares, spotlight, ffmpeg: Int?
       
        let allowDownloads, displayEmbed: Int?
        let thumbnailOriginal, audioLocationOriginal: String?
        let publisher: Publisher?
        let orgDescription, timeFormatted, tagsDefault: String?
        let tagsArray, tagsFiltered: [String]?
        let url: String?
        let categoryName: String?
        let secureURL: String?
        let songArray: SongArray?
        let countLikes:CountViews?
        let countDislikes:CountViews?
        let countShares: CountViews?
        let countViews:CountViews?
        let countComment:CountViews?
        let countFavorite: CountViews?
        let isOwner, isLiked, isFavoriated, canListen: Bool?
        let albumName: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case audioID = "audio_id"
            case title
            case songDescription = "description"
            case tags, thumbnail, availability
            case ageRestriction = "age_restriction"
            case time, views
            case artistID = "artist_id"
            case albumID = "album_id"
            case  duration
            case demoDuration = "demo_duration"
            case audioLocation = "audio_location"
            case demoTrack = "demo_track"
            case categoryID = "category_id"
            case registered, size
            case darkWave = "dark_wave"
            case lightWave = "light_wave"
            case shares, spotlight, ffmpeg
            case allowDownloads = "allow_downloads"
            case displayEmbed = "display_embed"
            case thumbnailOriginal = "thumbnail_original"
            case audioLocationOriginal = "audio_location_original"
            case publisher
            case orgDescription = "org_description"
            case timeFormatted = "time_formatted"
            case tagsDefault = "tags_default"
            case tagsArray = "tags_array"
            case tagsFiltered, url
            case categoryName = "category_name"
            case secureURL = "secure_url"
            case songArray
            case countLikes = "count_likes"
            case countDislikes = "count_dislikes"
            case countViews = "count_views"
            case countShares = "count_shares"
            case countComment = "count_comment"
            case countFavorite = "count_favorite"
            case isOwner = "IsOwner"
            case isLiked = "IsLiked"
            case isFavoriated = "is_favoriated"
            case canListen = "can_listen"
            case albumName = "album_name"
        }
    }
    
    // MARK: - Publisher
    struct Publisher: Codable {
        let id: Int?
        let username, email, ipAddress, password: String?
        let name, gender, emailCode, language: String?
        let avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let wallet, balance, website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let iosDeviceID, androidDeviceID, webDeviceID, orAvatar: String?
        let orCover: String?
        let url: String?
        let aboutDecoded, nameV, countryName, genderText: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case password, name, gender
            case emailCode = "email_code"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered, wallet, balance, website, artist
            case isPro = "is_pro"
            case proTime = "pro_time"
            case lastFollowID = "last_follow_id"
            case iosDeviceID = "ios_device_id"
            case androidDeviceID = "android_device_id"
            case webDeviceID = "web_device_id"
            case orAvatar = "or_avatar"
            case orCover = "or_cover"
            case url
            case aboutDecoded = "about_decoded"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
        }
    }
    
    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: Publisher?
        let sTime, sName, sDuration: String?
        let sThumbnail: String?
        let sID: Int?
        let sURL: String?
        let sAudioID: String?
        let sCategory: String?
        
        enum CodingKeys: String, CodingKey {
            case userData = "USER_DATA"
            case sTime = "s_time"
            case sName = "s_name"
            case sDuration = "s_duration"
            case sThumbnail = "s_thumbnail"
            case sID = "s_id"
            case sURL = "s_url"
            case sAudioID = "s_audio_id"
            case sCategory = "s_category"
        }
    }
    
    // MARK: - Encode/decode helpers
    
    class JSONNull: Codable, Hashable {
        
        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }
        
        public var hashValue: Int {
            return 0
        }
        
        public init() {}
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    enum CountViews: Codable {
        case integer(Int)
        case string(String)
        
        
        var stringValue : String? {
            guard case let .string(value) = self else { return nil }
            return value
        }
        
        var intValue : Int? {
            guard case let .integer(value) = self else { return nil }
            return value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .integer(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            throw DecodingError.typeMismatch(CountViews.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .integer(let x):
                try container.encode(x)
            case .string(let x):
                try container.encode(x)
            }
        }
    }
}
class DeleteAlbumModel:BaseModel{
    struct DeleteAlbumSuccessModel: Codable {
        let status: Int?
    }

}
class UploadAlbumModel:BaseModel{
  
    struct UploadAlbumSuccessModel: Codable {
        let status: Int?
        let albumID: String?
        let albumData: AlbumData?
        let url: String?

        enum CodingKeys: String, CodingKey {
            case status
            case albumID = "album_id"
            case albumData = "album_data"
            case url
        }
    }

    // MARK: - AlbumData
    struct AlbumData: Codable {
        let id: Int?
        let albumID: String?
        let userID: Int?
        let title, albumDataDescription: String?
        let categoryID: Int?
        let thumbnail: String?
        let time: Int?
        let registered: String?
        let price: Double?
        let purchases: Int?
        let thumbnailOriginal: String?
        let publisher: Publisher?
        let timeFormatted: String?
        let url: String?
        let categoryName: String?
        let isPurchased: Int?
        let isOwner: Bool?
        let songs: [JSONAny]?
        let countSongs: Int?

        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case albumDataDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, registered, price, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            case timeFormatted = "time_formatted"
            case url
            case categoryName = "category_name"
            case isPurchased = "is_purchased"
            case isOwner = "IsOwner"
            case songs
            case countSongs = "count_songs"
        }
    }

    // MARK: - Publisher
    struct Publisher: Codable {
        let id: Int?
        let username, email, ipAddress, password: String?
        let name, gender, emailCode, language: String?
        let avatar: String?
        let cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let uploads: Double?
        let wallet, balance: String?
        let website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let iosDeviceID, androidDeviceID, webDeviceID: String?
        let emailOnLikedTrack, emailOnLikedComment, emailOnArtistStatusChanged: String?
        let emailOnFollowUser:String?
        let emailOnReceiptStatusChanged, emailOnNewTrack, emailOnReviewedTrack: String?
        let newEmail: String?
        let twoFactorVerified, twoFactor : Int?
        let newPhone, phoneNumber: String?
        let lastLoginData: JSONNull?
        let referrer, refUserID: Int?
        let orAvatar, orCover: String?
        let url: String?
        let aboutDecoded, nameV, countryName, genderText: String?

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case password, name, gender
            case emailCode = "email_code"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered, uploads, wallet, balance, website, artist
            case isPro = "is_pro"
            case proTime = "pro_time"
            case lastFollowID = "last_follow_id"
            case iosDeviceID = "ios_device_id"
            case androidDeviceID = "android_device_id"
            case webDeviceID = "web_device_id"
            case emailOnFollowUser = "email_on_follow_user"
            case emailOnLikedTrack = "email_on_liked_track"
            case emailOnLikedComment = "email_on_liked_comment"
            case emailOnArtistStatusChanged = "email_on_artist_status_changed"
            case emailOnReceiptStatusChanged = "email_on_receipt_status_changed"
            case emailOnNewTrack = "email_on_new_track"
            case emailOnReviewedTrack = "email_on_reviewed_track"
            case twoFactor = "two_factor"
            case newEmail = "new_email"
            case twoFactorVerified = "two_factor_verified"
            case newPhone = "new_phone"
            case phoneNumber = "phone_number"
            case lastLoginData = "last_login_data"
            case referrer
            case refUserID = "ref_user_id"
            case orAvatar = "or_avatar"
            case orCover = "or_cover"
            case url
            case aboutDecoded = "about_decoded"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
        }
    }

    // MARK: - Encode/decode helpers

    class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

    class JSONCodingKey: CodingKey {
        let key: String

        required init?(intValue: Int) {
            return nil
        }

        required init?(stringValue: String) {
            key = stringValue
        }

        var intValue: Int? {
            return nil
        }

        var stringValue: String {
            return key
        }
    }

    class JSONAny: Codable {

        let value: Any

        static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
            return DecodingError.typeMismatch(JSONAny.self, context)
        }

        static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
            return EncodingError.invalidValue(value, context)
        }

        static func decode(from container: SingleValueDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                return value
            }
            if let value = try? container.decode(Int64.self) {
                return value
            }
            if let value = try? container.decode(Double.self) {
                return value
            }
            if let value = try? container.decode(String.self) {
                return value
            }
            if container.decodeNil() {
                return JSONNull()
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                return value
            }
            if let value = try? container.decode(Int64.self) {
                return value
            }
            if let value = try? container.decode(Double.self) {
                return value
            }
            if let value = try? container.decode(String.self) {
                return value
            }
            if let value = try? container.decodeNil() {
                if value {
                    return JSONNull()
                }
            }
            if var container = try? container.nestedUnkeyedContainer() {
                return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
            if let value = try? container.decode(Bool.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Int64.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(String.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeNil(forKey: key) {
                if value {
                    return JSONNull()
                }
            }
            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
            var arr: [Any] = []
            while !container.isAtEnd {
                let value = try decode(from: &container)
                arr.append(value)
            }
            return arr
        }

        static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
            var dict = [String: Any]()
            for key in container.allKeys {
                let value = try decode(from: &container, forKey: key)
                dict[key.stringValue] = value
            }
            return dict
        }

        static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
            for value in array {
                if let value = value as? Bool {
                    try container.encode(value)
                } else if let value = value as? Int64 {
                    try container.encode(value)
                } else if let value = value as? Double {
                    try container.encode(value)
                } else if let value = value as? String {
                    try container.encode(value)
                } else if value is JSONNull {
                    try container.encodeNil()
                } else if let value = value as? [Any] {
                    var container = container.nestedUnkeyedContainer()
                    try encode(to: &container, array: value)
                } else if let value = value as? [String: Any] {
                    var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                    try encode(to: &container, dictionary: value)
                } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
                }
            }
        }

        static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
            for (key, value) in dictionary {
                let key = JSONCodingKey(stringValue: key)!
                if let value = value as? Bool {
                    try container.encode(value, forKey: key)
                } else if let value = value as? Int64 {
                    try container.encode(value, forKey: key)
                } else if let value = value as? Double {
                    try container.encode(value, forKey: key)
                } else if let value = value as? String {
                    try container.encode(value, forKey: key)
                } else if value is JSONNull {
                    try container.encodeNil(forKey: key)
                } else if let value = value as? [Any] {
                    var container = container.nestedUnkeyedContainer(forKey: key)
                    try encode(to: &container, array: value)
                } else if let value = value as? [String: Any] {
                    var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                    try encode(to: &container, dictionary: value)
                } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
                }
            }
        }

        static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }

        public required init(from decoder: Decoder) throws {
            if var arrayContainer = try? decoder.unkeyedContainer() {
                self.value = try JSONAny.decodeArray(from: &arrayContainer)
            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                self.value = try JSONAny.decodeDictionary(from: &container)
            } else {
                let container = try decoder.singleValueContainer()
                self.value = try JSONAny.decode(from: container)
            }
        }

        public func encode(to encoder: Encoder) throws {
            if let arr = self.value as? [Any] {
                var container = encoder.unkeyedContainer()
                try JSONAny.encode(to: &container, array: arr)
            } else if let dict = self.value as? [String: Any] {
                var container = encoder.container(keyedBy: JSONCodingKey.self)
                try JSONAny.encode(to: &container, dictionary: dict)
            } else {
                var container = encoder.singleValueContainer()
                try JSONAny.encode(to: &container, value: self.value)
            }
        }
    }

}
class PurchaseAlbumModel:BaseModel{
    struct PurchaseAlbumSuccessModel: Codable {
        var status: Int?
        var message: String?
    }

}
