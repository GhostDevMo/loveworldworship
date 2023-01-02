//
//  CommentModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetCommentModel:BaseModel{
 
    struct GetCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let count: Int?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let id, trackID, userID: Int?
        let value: String?
        let   time, orgPosted: Int?
        let posted, secondsFormated: String?
        let owner, isLikedComment: Bool?
        let countLiked: Int?
        let userData: UserData?
        
        enum CodingKeys: String, CodingKey {
            case id
            case trackID = "track_id"
            case userID = "user_id"
            case value, time
            case orgPosted = "org_posted"
            case posted, secondsFormated, owner
            case isLikedComment = "IsLikedComment"
            case countLiked, userData
        }
    }
    
    // MARK: - UserData
    struct UserData: Codable {
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
        let wallet, balance: String?
        let website: String?
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

    }
class PostCommentModel:BaseModel{
    struct PostCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let id, commentSeconds, commentPercentage: Int?
        let userData: UserData?
        let commentText, commentPostedTime: String?
        let commentSecondsFormatted, commentSongID: String?
        let commentSongTrackID: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case commentSeconds = "comment_seconds"
            case commentPercentage = "comment_percentage"
            case userData = "USER_DATA"
            case commentText = "comment_text"
            case commentPostedTime = "comment_posted_time"
            case commentSecondsFormatted = "comment_seconds_formatted"
            case commentSongID = "comment_song_id"
            case commentSongTrackID = "comment_song_track_id"
        }
    }
    
    // MARK: - UserData
    struct UserData: Codable {
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
        let wallet, balance: String?
        let website: String?
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
            case registered,  wallet, balance, website, artist
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
}
class likeDisLikeCommentModel:BaseModel{
    struct likeDisLikeCommentSuccessModel: Codable {
        let status: Int?
    }
}
