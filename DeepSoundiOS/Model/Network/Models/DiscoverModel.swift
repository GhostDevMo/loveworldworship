//
//  DiscoverModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 03/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.


import Foundation
class DiscoverModel:BaseModel{
    
    struct DiscoverSuccessModel: Codable {
        let status: Int?
        let mostPopularWeek :  PopularWeekUnion?
        let newReleases : NewReleases?
        let recentlyPlayed  : RecentlyplayedUnion?
        let randoms : Randoms?
        
        enum CodingKeys: String, CodingKey {
            case status
            case mostPopularWeek = "most_popular_week"
            case newReleases = "new_releases"
            case recentlyPlayed = "recently_played"
            case randoms
        }
    }
    
    // MARK: - MostPopularWeek
    struct MostPopularWeek: Codable {
        var data: [Song?]?
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
            case duration
            case demoDuration = "demo_duration"
            case audioLocation = "audio_location"
            case demoTrack = "demo_track"
            case categoryID = "category_id"
            case registered, size
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
    
    enum AlbumName: String, Codable {
        case empty = ""
        case windowsSeven = "Windows Seven"
    }
    
    enum CategoryName: String, Codable {
        case jazz = "Jazz"
        case mix = "Mix"
        case other = "Other"
        case rock = "Rock"
    }
    
    // MARK: - Publisher
    struct Publisher: Codable {
        let id: Int?
        let username, email: String?
        let ipAddress: String?
        let password, name: String?
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
        let registered: String?
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
    
    enum CountryName: String, Codable {
        case albania = "Albania"
        case canada = "Canada"
        case mexico = "Mexico"
        case nigeria = "Nigeria"
        case selectCountry = "Select Country"
        case turkey = "Turkey"
    }
    
    enum Facebook: String, Codable {
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
    
    enum IPAddress: String, Codable {
        case empty = ""
        case the100166397 = "100.16.63.97"
        case the1295611017 = "129.56.110.17"
        case the18382116115 = "183.82.116.115"
        case the223182197189 = "223.182.197.189"
        case the4120372221 = "41.203.72.221"
        case the78166130235 = "78.166.130.235"
        case the8823885236 = "88.238.85.236"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case spanish = "spanish"
    }
    
    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
        case the20196 = "2019/6"
        case the20197 = "2019/7"
    }
    
    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: Publisher?=nil
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
    
    // MARK: - NewReleases
    struct NewReleases: Codable {
        let count: Int?
        var data: [Song]?
    }
    struct NewReleasesRecentlyPlayed: Codable {
        let count: Int?
        var data: [Song]?
    }
    
    // MARK: - Randoms
    struct Randoms: Codable {
        let playlist: [Playlist]?
        let song: Song?
        let album: [Album]?
        var recommended: [Song]?
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
        let  purchases: Int?
        let thumbnailOriginal: String?
        let publisher: Publisher?=nil
        let timeFormatted: String?
        let url: String?
        let categoryName: String?
        let isOwner: Bool?
        let countSongs: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case albumDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, registered, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            case timeFormatted = "time_formatted"
            case url
            case categoryName = "category_name"
            case isOwner = "IsOwner"
            case countSongs = "count_songs"
        }
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
        
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case userID = "user_id"
            case privacy, thumbnail, uid, time
            case isOwner = "IsOwner"
            case thumbnailReady = "thumbnail_ready"
            case privacyText = "privacy_text"
            case url, songs
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
    enum RecentlyplayedUnion: Codable {
        case anythingArray([JSONAny])
        case newReleases(NewReleasesRecentlyPlayed)

        var emptyArray : [JSONAny]? {
            guard case let .anythingArray(value) = self else { return nil }
            return value
        }
        
        var newRelease : NewReleasesRecentlyPlayed? {
            guard case let .newReleases(value) = self else { return nil }
            return value
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([JSONAny].self) {
                self = .anythingArray(x)
                return
            }
            if let x = try? container.decode(NewReleasesRecentlyPlayed.self) {
                self = .newReleases(x)
                return
            }
            throw DecodingError.typeMismatch(RecentlyplayedUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RecentlyplayedUnion"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .anythingArray(let x):
                try container.encode(x)
            case .newReleases(let x):
                try container.encode(x)
            }
        }
    }
    enum PopularWeekUnion: Codable {
        case anythingArray([JSONAny])
        case popularWeek(MostPopularWeek)

        var emptyArray : [JSONAny]? {
            guard case let .anythingArray(value) = self else { return nil }
            return value
        }
        
        var newRelease : MostPopularWeek? {
            guard case let .popularWeek(value) = self else { return nil }
            return value
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([JSONAny].self) {
                self = .anythingArray(x)
                return
            }
            if let x = try? container.decode(MostPopularWeek.self) {
                self = .popularWeek(x)
                return
            }
            throw DecodingError.typeMismatch(PopularWeekUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RecentlyplayedUnion"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .anythingArray(let x):
                try container.encode(x)
            case .popularWeek(let x):
                try container.encode(x)
            }
        }
    }
    
}
class NotDiscoverModel:BaseModel{
    
    struct DiscoverSuccessModel: Codable {
        let status: Int? = nil
        let mostPopularWeek =  MostPopularWeek()
        let newReleases : NewReleases?
        let recentlyPlayed : NewReleases? = nil
        let randoms: Randoms?
        
        enum CodingKeys: String, CodingKey {
            case status
            case mostPopularWeek = "most_popular_week"
            case newReleases = "new_releases"
            case recentlyPlayed = "recently_played"
            case randoms
        }
    }
    
    // MARK: - MostPopularWeek
    struct MostPopularWeek: Codable {
        var data: [Song?]?
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
            case duration
            case demoDuration = "demo_duration"
            case audioLocation = "audio_location"
            case demoTrack = "demo_track"
            case categoryID = "category_id"
            case registered, size
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
    
    enum AlbumName: String, Codable {
        case empty = ""
        case windowsSeven = "Windows Seven"
    }
    
    enum CategoryName: String, Codable {
        case jazz = "Jazz"
        case mix = "Mix"
        case other = "Other"
        case rock = "Rock"
    }
    
    // MARK: - Publisher
    struct Publisher: Codable {
        let id: Int?
        let username, email: String?
        let ipAddress: String?
        let password, name: String?
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
        let registered: String?
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
    
    enum CountryName: String, Codable {
        case albania = "Albania"
        case canada = "Canada"
        case mexico = "Mexico"
        case nigeria = "Nigeria"
        case selectCountry = "Select Country"
        case turkey = "Turkey"
    }
    
    enum Facebook: String, Codable {
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
    
    enum IPAddress: String, Codable {
        case empty = ""
        case the100166397 = "100.16.63.97"
        case the1295611017 = "129.56.110.17"
        case the18382116115 = "183.82.116.115"
        case the223182197189 = "223.182.197.189"
        case the4120372221 = "41.203.72.221"
        case the78166130235 = "78.166.130.235"
        case the8823885236 = "88.238.85.236"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case spanish = "spanish"
    }
    
    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
        case the20196 = "2019/6"
        case the20197 = "2019/7"
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
    
    // MARK: - NewReleases
    struct NewReleases: Codable {
        let count: Int?
        var data: [Song]?
    }
    
    // MARK: - Randoms
    struct Randoms: Codable {
        let playlist: [Playlist]?
        let song: Song?
        let album: [Album]?
        var recommended: [Song]?
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
        let  purchases: Int?
        let thumbnailOriginal: String?
        let publisher: Publisher?
        let timeFormatted: String?
        let url: String?
        let categoryName: String?
        let isOwner: Bool?
        let countSongs: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case albumDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, registered, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            case timeFormatted = "time_formatted"
            case url
            case categoryName = "category_name"
            case isOwner = "IsOwner"
            case countSongs = "count_songs"
        }
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
        
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case userID = "user_id"
            case privacy, thumbnail, uid, time
            case isOwner = "IsOwner"
            case thumbnailReady = "thumbnail_ready"
            case privacyText = "privacy_text"
            case url, songs
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
    enum RecentlyplayedUnion: Codable {
        case anythingArray([JSONAny])
        case newReleases(NewReleases)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([JSONAny].self) {
                self = .anythingArray(x)
                return
            }
            if let x = try? container.decode(NewReleases.self) {
                self = .newReleases(x)
                return
            }
            throw DecodingError.typeMismatch(RecentlyplayedUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RecentlyplayedUnion"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .anythingArray(let x):
                try container.encode(x)
            case .newReleases(let x):
                try container.encode(x)
            }
        }
    }
    
}
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
