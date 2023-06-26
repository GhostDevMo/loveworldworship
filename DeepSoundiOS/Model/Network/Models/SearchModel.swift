//
//  SearchModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class SearchModel:BaseModel{
   
    // MARK: - Welcome
    struct SearchSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let songs: [Song]?
        let albums: [Album]?
        let artist: [Artist]?
        let playlist: [Playlist]?
    }
    
    // MARK: - Album
    struct Album: Codable {
        let id: Int?
        let albumID: String?
        let userID: Int?
        let title, albumDescription: String?
        let categoryID: Int?
        let thumbnail: String?
        let time: Int?
        let registered: String?
        let price : Double?
      
        let purchases: Int?
        let thumbnailOriginal: String?
        let publisher: Artist?
        let url: String?
        let categoryName: String?
        let isOwner: Bool?
        let countSongs: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case price
            case albumDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, registered, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            
            case url
            case categoryName = "category_name"
            case isOwner = "IsOwner"
            case countSongs = "count_songs"
        }
    }
    
    enum CategoryName: String, Codable {
        case other = "Other"
    }
    
    // MARK: - Artist
    struct Artist: Codable {
        let id: Int?
        let username, email, ipAddress, password: String?
        let name: String?
        let gender: String?
        let emailCode: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let src: String?
        let countryID, age: Int?
        let about: String?
        let google: String?
        let facebook: String?
        let twitter, instagram: String?
        let registered: String?
        let wallet, balance: String?
        let website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let url: String?
        let nameV: String?
        let countryName: String?
        let genderText: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case password, name, gender
            case emailCode = "email_code"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram
            case registered, wallet, balance, website, artist
            case isPro = "is_pro"
            case proTime = "pro_time"
            case lastFollowID = "last_follow_id"
            case url

            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
        }
    }
    
    enum About: String, Codable {
        case civengUic = "civeng@uic"
        case empty = ""
        case iAmAliMoIloveMusic = "I am ali mo ilove music"
        case russianSinger = "Russian singer"
    }
    
    enum CountryName: String, Codable {
        case canada = "Canada"
        case russianFederation = "Russian Federation"
        case selectCountry = "Select Country"
        case unitedStates = "United States"
    }
    
    enum Facebook: String, Codable {
        case alisom = "alisom"
        case empty = ""
        case rwar = "rwar"
    }
    
    enum Gender: String, Codable {
        case male = "male"
    }
    
    enum GenderText: String, Codable {
        case male = "Male"
    }
    
    enum Language: String, Codable {
        case english = "english"
    }
    
    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
        case the20196 = "2019/6"
    }
    
    enum TimeFormatted: String, Codable {
        case the3MonthsAgo = "3 months ago"
    }
    
    // MARK: - Playlist
    struct Playlist: Codable {
        let id: Int?
        let name: String?
        let userID, privacy: Int?
        let thumbnail, uid: String?
        let time: Int?
        let isOwner: Bool?
        let thumbnailReady: String?
        let privacyText: String?
        let url: String?
        let songs: Int?
        let publisher: Artist?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case userID = "user_id"
            case privacy, thumbnail, uid, time
            case isOwner = "IsOwner"
            case thumbnailReady = "thumbnail_ready"
            case privacyText = "privacy_text"
            case url, songs, publisher
        }
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
        let publisher: Artist?
        let orgDescription, tagsDefault: String?
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
        let timeFormatted:String?
        
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
            case duration
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
            case timeFormatted = "time_formatted"
        }
    }
    
    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: Artist?
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
