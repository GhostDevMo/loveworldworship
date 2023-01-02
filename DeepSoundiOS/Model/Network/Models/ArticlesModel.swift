//
//  ArticlesModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetArticlesModel:BaseModel{
    // MARK: - Welcome
    struct GetArticlesSuccessModel: Codable {
        var status: Int?
        var data: [Datum]?
    }

    // MARK: - Datum
    struct Datum: Codable {
        var id, title, content, datumDescription: String?
        var posted, category: String?
        var thumbnail: String?
        var view, shared, tags, createdAt: String?

        enum CodingKeys: String, CodingKey {
            case id, title, content
            case datumDescription = "description"
            case posted, category, thumbnail, view, shared, tags
            case createdAt = "created_at"
        }
    }

}
class GetArticlesCommentsModel:BaseModel{

    struct GetArticlesCommentsSuccessModel: Codable {
        let status: Int?
        let data: [Datum]?
    }

    // MARK: - Datum
    struct Datum: Codable {
        let id, articleID, userID: Int?
        let value: String?
        let time, orgPosted: Int?
        let posted, secondsFormated: String?
        let owner: Bool?
        let replies: [JSONAny]?
        let trackID: Int?
        let isLikedComment: Bool?
        let countLiked: Int?
        let userData: UserData?

        enum CodingKeys: String, CodingKey {
            case id
            case articleID = "article_id"
            case userID = "user_id"
            case value, time
            case orgPosted = "org_posted"
            case posted, secondsFormated, owner, replies
            case trackID = "track_id"
            case isLikedComment = "IsLikedComment"
            case countLiked
            case userData = "user_data"
        }
    }

    // MARK: - UserData
    struct UserData: Codable {
        let id: Int?
        let username, email, ipAddress, name: String?
        let gender, emailCode, language: String?
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
        let emailOnFollowUser, emailOnLikedTrack, emailOnLikedComment, emailOnArtistStatusChanged: Int?
        let emailOnReceiptStatusChanged, emailOnNewTrack, emailOnReviewedTrack, twoFactor: Int?
        let newEmail: String?
        let twoFactorVerified: Int?
        let newPhone, phoneNumber: String?
        let lastLoginData: String?
        let referrer, refUserID, uploadImport: Int?
        let paypalEmail: String?
        let infoFile: JSONNull?
        let emailOnCommentReplayMention, emailOnCommentMention, time: Int?
        let orAvatar, orCover: String?
        let url: String?
        let aboutDecoded, nameV, countryName, genderText: String?

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case name, gender
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
            case uploadImport = "upload_import"
            case paypalEmail = "paypal_email"
            case infoFile = "info_file"
            case emailOnCommentReplayMention = "email_on_comment_replay_mention"
            case emailOnCommentMention = "email_on_comment_mention"
            case time
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
class CreateArticleCommentModel:BaseModel{
  

    // MARK: - Welcome
    struct CreateArticleCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    // MARK: - DataClass
    struct DataClass: Codable {
        let id, articleID, userID: Int?
        let value: String?
        let time: Int?
        let posted: String?
        let owner, isLikedComment: Bool?
        let countLiked: Int?
        let userData: UserData?

        enum CodingKeys: String, CodingKey {
            case id
            case articleID = "article_id"
            case userID = "user_id"
            case value, time, posted, owner
            case isLikedComment = "IsLikedComment"
            case countLiked
            case userData = "user_data"
        }
    }

    // MARK: - UserData
    struct UserData: Codable {
        let id: Int?
        let username, email, ipAddress, name: String?
        let gender, emailCode, language: String?
        let avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let uploads: Int?
        let wallet, balance: String?
        let website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let iosDeviceID, androidDeviceID, webDeviceID: String?
        let emailOnFollowUser, emailOnLikedTrack, emailOnLikedComment, emailOnArtistStatusChanged: Int?
        let emailOnReceiptStatusChanged, emailOnNewTrack, emailOnReviewedTrack, twoFactor: Int?
        let newEmail: String?
        let twoFactorVerified: Int?
        let newPhone, phoneNumber: String?
        let lastLoginData: JSONNull?
        let referrer, refUserID, uploadImport: Int?
        let paypalEmail: String?
//        let infoFile: JSONNull?
        let emailOnCommentReplayMention, emailOnCommentMention, time: Int?
        let orAvatar, orCover: String?
        let url: String?
        let aboutDecoded, nameV, countryName, genderText: String?

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case name, gender
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
            case uploadImport = "upload_import"
            case paypalEmail = "paypal_email"
//            case infoFile = "info_file"
            case emailOnCommentReplayMention = "email_on_comment_replay_mention"
            case emailOnCommentMention = "email_on_comment_mention"
            case time
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

}
