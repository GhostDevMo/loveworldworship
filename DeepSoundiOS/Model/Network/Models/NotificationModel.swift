//
//  NotificationModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class NotificationModel:BaseModel{
    struct NotificationSuccessModel: Codable {
        let status: Int?
        let notifiations: [Notifiation]?
    }
    
    // MARK: - Notifiation
    struct Notifiation: Codable {
        let userData: UserData?
        let nID: Int?
        let nTime, nText: String?
        let nURL: String?
        let nAURL, nType: String?
        
        enum CodingKeys: String, CodingKey {
            case userData = "USER_DATA"
            case nID = "n_id"
            case nTime = "n_time"
            case nText = "n_text"
            case nURL = "n_url"
            case nAURL = "n_a_url"
            case nType = "n_type"
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
        let wallet, balance, website: String?
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
class notificationUnseenCountModel:BaseModel
{
    struct notificationUnseenCountSuccessModel: Codable {
        let status, count, msgs: Int?
    }

}
