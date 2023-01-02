//
//  ProfileModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation


class ProfileModel:BaseModel{

    // MARK: - Welcome
    struct ProfileSuccessModel: Codable {
        let status: Int?
        var data: DataElement?
        let details: [String: Int]?
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
        let publisher: DataElement?

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

    // MARK: - AlbumElement
    struct AlbumElement: Codable {
        let id: Int?
        let albumID: String?
        let userID: Int?
        let title, albumDescription: String?
        let categoryID: Int?
        let thumbnail: String?
        let time: Int?
        let registered: String?
        let price: Double?
        let purchases: Int?
        let thumbnailOriginal: String?
        let publisher: DataElement?
        let timeFormatted: String?
        let url: String?
        let categoryName: String?
        let isPurchased: Int?
        let isOwner: Bool?
        let countSongs: Int?

        enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case userID = "user_id"
            case title
            case albumDescription = "description"
            case categoryID = "category_id"
            case thumbnail, time, registered, price, purchases
            case thumbnailOriginal = "thumbnail_original"
            case publisher
            case timeFormatted = "time_formatted"
            case url
            case categoryName = "category_name"
            case isPurchased = "is_purchased"
            case isOwner = "IsOwner"
            case countSongs = "count_songs"
        }
    }

    // MARK: - SongArray
    struct SongArray: Codable {
        let userData: DataElement?
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
        let registered: String?
        let size: Int?
        let darkWave, lightWave: String?
        let shares, spotlight, ffmpeg: Int?
        let lyrics: String?
        let allowDownloads, displayEmbed, sortOrder: Int?
        let src: String?
        let itunesToken: String?
        let itunesAffiliateURL: String?
        let thumbnailOriginal: String?
        let audioLocationOriginal: String?
        let publisher: DataElement?
        let orgDescription, timeFormatted, tagsDefault: String?
        let tagsArray, tagsFiltered: [String]?
        let url: String?
        let categoryName: String?
        let secureURL: String?
        let songArray: SongArray?
        let countLikes:CountViews?
              let countDislikes:CountViews
              let countShares: CountViews?
              let countViews:CountViews?
              let countComment:CountViews
              let countFavorite: CountViews?
        let  isOwner, isLiked, isFavoriated: Bool?
        let canListen: Bool?
        let albumName: String?
        let itunesTokenURL: String?
        let deezerURL: String?
        
       

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
            case isOwner = "IsOwner"
            case isLiked = "IsLiked"
            case isFavoriated = "is_favoriated"
            case canListen = "can_listen"
            case albumName = "album_name"
            case itunesTokenURL = "itunes_token_url"
            case deezerURL = "deezer_url"
        }
    }

    // MARK: - Activity
    struct Activity: Codable {
        let userData: DataElement?
        let sTime, sName, sDuration: String?
        let sThumbnail: String?
        let sID: Int?
        let sURL: String?
        let sAudioID: String?
        let sCategory: String?
        let aID: Int?
        let aType: String?
        let aOwner: Bool?
        let activityTime: String?
        let activityTimeFormatted, activityText, albumText: String?
        let isSongOwner: Bool?
        let trackData: Latestsong? = nil

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
            case aID = "a_id"
            case aType = "a_type"
            case aOwner = "a_owner"
            case activityTime = "activity_time"
            case activityTimeFormatted = "activity_time_formatted"
            case activityText = "activity_text"
            case albumText = "album_text"
            case  isSongOwner
            case trackData = "TRACK_DATA"
        }
    }

    // MARK: - DataElement
    struct DataElement: Codable {
        let id: Int?
        let username, email, ipAddress, name: String?
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
        let referrer, refUserID: Int?
        let orAvatar, orCover: String?
        let url: String?
        let aboutDecoded, nameV: String?
        let countryName: String?
        let genderText: String?
        let isFollowing, isBloked: Bool?
//        let followers, following: [DataElement]?
        let albums: [AlbumElement]?
        let playlists: [Playlist]?
        let recentlyPlayed, liked: [Latestsong]?
        var activities: [Activity]?
        var latestsongs, topSongs, store, stations: [Latestsong]?
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
            case isFollowing = "IsFollowing"
            case isBloked = "IsBloked"
//            case followers, following
                 case albums, playlists
            case recentlyPlayed = "recently_played"
            case liked, activities, latestsongs
            case topSongs = "top_songs"
            case store, stations, password
        }
    }

    enum PrivacyText: String, Codable {
        case privacyTextPublic = "Public"
    }

    enum SCategory: String, Codable {
        case classic = "Classic"
        case jazz = "Jazz"
        case mix = "Mix"
        case other = "Other"
        case rock = "Rock"
    }

    enum AlbumName: String, Codable {
        case empty = ""
        case kwesisDaughter = "Kwesis Daughter"
        case listOfMusic = "list of music"
        case music = "Music"
        case waelAlbum = "wael Album"
    }

    enum Src: String, Codable {
        case empty = ""
        case itunes1508023280 = "ITUNES:1508023280"
        case itunes1509022686 = "ITUNES:1509022686"
        case itunes724018934 = "ITUNES:724018934"
        case radio = "radio"
    }

    // MARK: - ActivityAlbum
    struct ActivityAlbum: Codable {
    }

    enum CountryName: String, Codable {
        case brazil = "Brazil"
        case georgia = "Georgia"
        case guyana = "Guyana"
        case indonesia = "Indonesia"
        case selectCountry = "Select Country"
        case spain = "Spain"
        case tanzaniaUnitedRepublicOf = "Tanzania, United Republic of"
        case turkey = "Turkey"
        case unitedStates = "United States"
    }

    enum Facebook: String, Codable {
        case alanwalkermusic = "alanwalkermusic"
        case deendoughouz = "deendoughouz"
        case empty = ""
        case legittiProductions = "LegittiProductions"
        case rwar = "rwar"
        case wael = "wael"
        case wayanx = "wayanx"
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
        case russian = "russian"
        case spanish = "spanish"
        case turkish = "turkish"
    }

    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the201910 = "2019/10"
        case the201912 = "2019/12"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
        case the20196 = "2019/6"
        case the20198 = "2019/8"
        case the20201 = "2020/1"
        case the20202 = "2020/2"
        case the20203 = "2020/3"
        case the20204 = "2020/4"
        case the20205 = "2020/5"
        case the20206 = "2020/6"
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




class UpdateProfileModel:BaseModel{
    
    struct UpdateProfileSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class UpdateMyAccountModel:BaseModel{
    
    struct UpdateMyAccountSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}
class ChangePasswordModel:BaseModel{
    
    struct ChangePasswordSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}
class DeleteAccountModel:BaseModel{
    
    struct DeleteAccountSuccessModel: Codable {
        let status: Int?
        let message: String?
    }
}

class UploadCoverModel:BaseModel{
   
    struct UploadCoverSuccessModel: Codable {
        let status: Int?
        let img: String?
    }

}
class UploadProfileImageModel:BaseModel{
    
    struct UploadProfileImageSuccessModel: Codable {
        let status: Int?
        let img: String?
    }
    
}

