//
//  PurchaseModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetPurchaseModel:BaseModel{
    struct GetPurchaseSuccessModel: Codable {
        let status: Int?
        let data: [DataClass]?
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        let count: Int?
        let data: [Datum]?
    }

    // MARK: - Datum
    struct Datum: Codable {
        let id, userID: Int?
        let audioID, title, datumDescription, tags: String?
        let thumbnail: String?
        let availability, ageRestriction, time, views: Int?
        let artistID, albumID: Int?
        let price: Double?
        let duration, demoDuration: String?
        let audioLocation: String?
        let demoTrack: String?
        let categoryID: Int?
        let registered: String?
        let size: Int?
        let darkWave, lightWave: String?
        let shares, spotlight, ffmpeg: Int?
        let lyrics: String?
        let allowDownloads, displayEmbed, sortOrder: Int?
        let src, itunesToken, itunesAffiliateURL, thumbnailOriginal: String?
        let audioLocationOriginal: String?
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
        let isDisLiked, isOwner, isLiked, isFavoriated: Bool?
        let canListen: Bool?
        let albumName, itunesTokenURL, deezerURL: String?
        let isPurchased: Bool?

        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case audioID = "audio_id"
            case title
            case datumDescription = "description"
            case tags, thumbnail, availability
            case ageRestriction = "age_restriction"
            case time, views
            case artistID = "artist_id"
            case albumID = "album_id"
            case price, duration
            case demoDuration = "demo_duration"
            case audioLocation = "audio_location"
            case demoTrack = "demo_track"
            case categoryID = "category_id"
            case registered, size
            case darkWave = "dark_wave"
            case lightWave = "light_wave"
            case shares, spotlight, ffmpeg, lyrics
            case allowDownloads = "allow_downloads"
            case displayEmbed = "display_embed"
            case sortOrder = "sort_order"
            case src
            case itunesToken = "itunes_token"
            case itunesAffiliateURL = "itunes_affiliate_url"
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
            case isDisLiked
            case isOwner = "IsOwner"
            case isLiked = "IsLiked"
            case isFavoriated = "is_favoriated"
            case canListen = "can_listen"
            case albumName = "album_name"
            case itunesTokenURL = "itunes_token_url"
            case deezerURL = "deezer_url"
            case isPurchased = "is_purchased"
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

    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: Publisher?
        let sTime, sName, sDuration: String?
        let sThumbnail: String?
        let sID: Int?
        let sURL: String?
        let sAudioID: String?
        let sPrice: Double?
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
            case sPrice = "s_price"
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
             
             throw DecodingError.typeMismatch(CountViews.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ID"))
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
