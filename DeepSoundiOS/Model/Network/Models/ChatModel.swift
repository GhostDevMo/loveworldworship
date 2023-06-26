//
//  ChatModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/12/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetChatsModel:BaseModel{
    // MARK: - Welcome
    struct GetChatsSuccessModel: Codable {
        let status: Int
        let data: [Datum]
    }

    // MARK: - Datum
    struct Datum: Codable {
        let user: User
        let getCountSeen: Int
        let getLastMessage: GetLastMessage
        let chatTime: Int

        enum CodingKeys: String, CodingKey {
            case user
            case getCountSeen = "get_count_seen"
            case getLastMessage = "get_last_message"
            case chatTime = "chat_time"
        }
    }

    // MARK: - GetLastMessage
    struct GetLastMessage: Codable {
        let id, fromID, toID: Int
        let text: String
        let seen, time, fromDeleted, toDeleted: Int
        let sentPush: Int
        let notificationID, typeTwo, image, fullImage: String
        let apiPosition, apiType: String

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case sentPush = "sent_push"
            case notificationID = "notification_id"
            case typeTwo = "type_two"
            case image
            case fullImage = "full_image"
            case apiPosition = "API_position"
            case apiType = "API_type"
        }
    }

    // MARK: - User
    struct User: Codable {
        let id: Int
        let username, email, ipAddress, name: String
        let gender, emailCode, language: String
        let avatar: String
        let cover: String
        let src: String
        let countryID, age: Int
        let about, google, facebook, twitter: String
        let instagram: String
        let active, admin, verified, lastActive: Int
        let registered: String

        let wallet, balance, website: String
        let artist, isPro, proTime, lastFollowID: Int
        let iosDeviceID, androidDeviceID, webDeviceID: String
        let emailOnFollowUser, emailOnLikedTrack, emailOnLikedComment, emailOnArtistStatusChanged: Int
        let emailOnReceiptStatusChanged, emailOnNewTrack, emailOnReviewedTrack, twoFactor: Int
        let newEmail: String
        let twoFactorVerified: Int
        let newPhone, phoneNumber: String
        let referrer, refUserID: Int
        let orAvatar, orCover: String
        let url: String
        let aboutDecoded, nameV, countryName, genderText: String

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case name, gender
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
}
class GetChatMessagesModel:BaseModel{
    struct GetChatMessagesSuccessModel: Codable {
        let status: Int?
        let data: [Datum]?
    }

    // MARK: - Datum
    struct Datum: Codable {
        let id, fromID, toID: Int?
        let text: String?
        let seen, time, fromDeleted, toDeleted: Int?
        let sentPush: Int?
        let notificationID, typeTwo, image: String?
        let fullImage: String?
        let apiPosition, apiType: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case sentPush = "sent_push"
            case notificationID = "notification_id"
            case typeTwo = "type_two"
            case image
            case fullImage = "full_image"
            case apiPosition = "API_position"
            case apiType = "API_type"
        }
    }

}

class SendMessageModel:BaseModel{
    struct SendMessageSuccessModel: Codable {
        var status, messageID: Int?
        var data: DataClass?

        enum CodingKeys: String, CodingKey {
            case status
            case messageID = "message_id"
            case data
        }
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        var id, fromID, toID: Int?
        var text: String?
        var seen, time, fromDeleted, toDeleted: Int?
        var sentPush: Int?
        var notificationID, typeTwo, image, fullImage: String?
        var apiPosition, apiType, hash: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case sentPush = "sent_push"
            case notificationID = "notification_id"
            case typeTwo = "type_two"
            case image
            case fullImage = "full_image"
            case apiPosition = "API_position"
            case apiType = "API_type"
            case hash
        }
    }

}
class DeleteChatModel:BaseModel{
    struct DeleteChatSuccessModel: Codable {
        var status: Int?
        var data: String?
    }
}
