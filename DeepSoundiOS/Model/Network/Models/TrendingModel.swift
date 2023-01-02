//
//  TopSongsModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 04/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class TrendingModel:BaseModel{
    
    struct TrendingSuccessModel: Codable {
        let status: Int?
        let topAlbums: [TopAlbum]?
        var topSongs: [TopSong]?
        
        enum CodingKeys: String, CodingKey {
            case status
            case topAlbums = "top_albums"
            case topSongs = "top_songs"
        }
    }
    
    // MARK: - TopAlbum
    struct TopAlbum: Codable {
        let id: Int?
        let albumID: String?
        let userID: Int?
        let title, topAlbumDescription: String?
        let categoryID: Int?
        let thumbnail: String?
        let time: Int?
        let price: Double?
        let purchases: Int?
        let thumbnailOriginal: String?
        let publisher: Publisher?
        
        let url: String?
        let categoryName: String?
        let isOwner: Bool?
        let countSongs: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case topAlbumDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, price, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            case url
            case categoryName = "category_name"
            case isOwner = "IsOwner"
            
            case countSongs = "count_songs"
        }
    }
    
    enum CategoryName: String, Codable {
        case classic = "Classic"
        case jazz = "Jazz"
        case mix = "Mix"
        case other = "Other"
        case rock = "Rock"
    }
    
    // MARK: - Publisher
    struct Publisher: Codable {
        let id: Int?
        let username, email, ipAddress, password: String?
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
        let aboutDecoded, nameV: String?
        let countryName: String?
        let genderText: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case password, name, gender
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
        }
    }
    
    enum CountryName: String, Codable {
        case albania = "Albania"
        case brazil = "Brazil"
        case canada = "Canada"
        case colombia = "Colombia"
        case georgia = "Georgia"
        case jamaica = "Jamaica"
        case russianFederation = "Russian Federation"
        case selectCountry = "Select Country"
        case turkey = "Turkey"
        case unitedStates = "United States"
    }
    
    enum Facebook: String, Codable {
        case alisom = "alisom"
        case deendoughouz = "deendoughouz"
        case empty = ""
        case rwar = "rwar"
        case wael = "wael"
    }
    
    enum Gender: String, Codable {
        case female = "female"
        case male = "male"
    }
    
    enum GenderText: String, Codable {
        case female = "Female"
        case male = "Male"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case french = "french"
        case russian = "russian"
        case spanish = "spanish"
    }
    
    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
        case the20196 = "2019/6"
        case the20197 = "2019/7"
    }
    
    // MARK: - Song
    struct Song: Codable {
        let id, userID: Int?
        let audioID, title, songDescription, tags: String?
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
        let publisher: Publisher?
        let orgDescription: String?
        
        let tagsDefault: String?
        let tagsArray, tagsFiltered: [String]?
        let url: String?
        let categoryName: CategoryName?
        let secureURL: String?
        let songArray: SongArray?
        let countLikes:CountViews?
        let countDislikes:CountViews?
        let countViews:CountViews?
        let countShares: CountViews?
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
            case price, duration
            case demoDuration = "demo_duration"
            case audioLocation = "audio_location"
            case demoTrack = "demo_track"
            case categoryID = "category_id"
            case  size
            case darkWave = "dark_wave"
            case lightWave = "light_wave"
            case shares, spotlight, ffmpeg
            case thumbnailOriginal = "thumbnail_original"
            case audioLocationOriginal = "audio_location_original"
            case publisher
            case orgDescription = "org_description"
            
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
    
    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: Publisher?
        let sTime: String?
        let sName, sDuration: String?
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
    
    enum TimeFormatted: String, Codable {
        case aboutAMonthAgo = "about a month ago"
        case the13DaysAgo = "13 days ago"
        case the24DaysAgo = "24 days ago"
        case the28DaysAgo = "28 days ago"
        case the29DaysAgo = "29 days ago"
        case the2MonthsAgo = "2 months ago"
        case the30DaysAgo = "30 days ago"
        case the3MonthsAgo = "3 months ago"
        case the4DaysAgo = "4 days ago"
        case the9DaysAgo = "9 days ago"
    }
    
    // MARK: - TopSong
    struct TopSong: Codable {
        let id, userID: Int?
        let audioID, title, topSongDescription, tags: String?
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
        let publisher: Publisher?
        let orgDescription: String?
        let tagsDefault: String?
        let tagsArray, tagsFiltered: [String]?
        let url: String?
        let categoryName: String?
        let secureURL: String?
        let songArray: SongArray?
        let countLikes:CountViews?
        let countDislikes: CountViews?
        let countViews: CountViews?
        let countShares:CountViews?
        let countComment:CountViews?
        let countFavorite: CountViews?
        let isOwner, isLiked, isFavoriated, canListen: Bool?
        let albumName: String?
        let timeFormatted:String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case audioID = "audio_id"
            case title
            case topSongDescription = "description"
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
            case  size
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
