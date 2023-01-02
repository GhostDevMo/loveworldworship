//
//  ArtistModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 03/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class ArtistModel:BaseModel{
    
    struct ArtistSuccessModel: Codable {
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
        let registered: String?
        let wallet, balance: String?
        let website: String?
        let artist, isPro, proTime, lastFollowID: Int?
        let iosDeviceID, androidDeviceID, webDeviceID, orAvatar: String?
        let orCover: String?
        let url: String?
        let aboutDecoded, nameV, countryName: String?
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
    
    enum Facebook: String, Codable {
        case empty = ""
        case legittiProductions = "LegittiProductions"
    }
    
    enum Gender: String, Codable {
        case male = "male"
    }
    
    enum GenderText: String, Codable {
        case male = "Male"
    }
    
    enum Language: String, Codable {
        case arabic = "arabic"
        case english = "english"
        case russian = "russian"
    }
    
    enum Registered: String, Codable {
        case the000000 = "0000/00"
        case the20194 = "2019/4"
        case the20195 = "2019/5"
    }
}
