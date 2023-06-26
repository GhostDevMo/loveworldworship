//
//  UserInfoModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class UserInfoModel:BaseModel{
 
    // MARK: - Welcome
    struct UserInfoSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
        let details: [String: Int]?
    }
    
    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: DataClass?
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
    
    // MARK: - Latestsong
    struct Latestsong: Codable {
        let id, userID: Int?
        let audioID, title, latestsongDescription, tags: String?
        let thumbnail: String?
        let availability, ageRestriction, time, views: Int?
        let artistID, albumID: Int?
        let price: Double?
        let duration, demoDuration: String?
        let audioLocation: String?
        let demoTrack: String?
        let categoryID: Int?
        let size: Int?
        let darkWave, lightWave: String?
        let shares, spotlight, ffmpeg: Int?
        let thumbnailOriginal, audioLocationOriginal: String?
        let publisher: DataClass?
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
            case latestsongDescription = "description"
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
            case size
            case darkWave = "dark_wave"
            case lightWave = "light_wave"
            case shares, spotlight, ffmpeg
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
    
    // MARK: - Activity
    struct Activity: Codable {
        let userData: DataClass?
        let sTime, sName, sDuration: String?
        let sThumbnail: String?
        let sID: Int?
        let sURL: String?
        let sAudioID: String?
        let sPrice: Double?
        let sCategory: String?
        let aID: Int?
       
        let activityTimeFormatted, activityText, albumText: String?
        let album: Album?
        let isSongOwner: Bool?
        let trackData: Latestsong?
        
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
            case aID = "a_id"
           
            case activityTimeFormatted = "activity_time_formatted"
            case activityText = "activity_text"
            case albumText = "album_text"
            case album, isSongOwner
            case trackData = "TRACK_DATA"
        }
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let id: Int?
        let username: String?
        let email: String?
        let ipAddress: String?
        let name: String?
        let gender: String?
        let emailCode: String?
        let language: String?
        let avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google: String?
        let facebook: String?
        let twitter, instagram: String?
        let active, admin, verified, lastActive: Int?
        
        let wallet, balance: String?
        let website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let iosDeviceID, androidDeviceID, webDeviceID, orAvatar: String?
        let orCover: String?
        let url: String?
        let aboutDecoded: String?
        let nameV: String?
        let countryName: String?
        let genderText: String?
        let isFollowing, isBloked: Bool?
        let activities: [Activity]?
        let latestsongs, topSongs: [Latestsong]?
        let store: [[Latestsong]]?
        let password: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case name, gender
            case emailCode = "email_code"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case   wallet, balance, website, artist
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
            case isFollowing = "IsFollowing"
            case isBloked = "IsBloked"
            case activities, latestsongs
            case topSongs = "top_songs"
            case store, password
        }
    }
    
    // MARK: - Album
    struct Album: Codable {
    }
    
    enum CountryName: String, Codable {
        case spain = "Spain"
    }
    
    enum Email: String, Codable {
        case legittiLegittiCOM = "legitti@legitti.com"
    }
    
    enum EmailCode: String, Codable {
        case fa21F1C86B168B85A09Fdc6B40E7F76A7A16Aaa1 = "fa21f1c86b168b85a09fdc6b40e7f76a7a16aaa1"
    }
    
    enum Facebook: String, Codable {
        case legittiProductions = "LegittiProductions"
    }
    
    enum Gender: String, Codable {
        case male = "male"
    }
    
    enum GenderText: String, Codable {
        case male = "Male"
    }
    
    enum IPAddress: String, Codable {
        case the8898123207 = "88.98.123.207"
    }
    
    enum Language: String, Codable {
        case english = "english"
    }
    
    enum Name: String, Codable {
        case legitti = "Legitti"
    }
    
    enum Registered: String, Codable {
        case the20195 = "2019/5"
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



