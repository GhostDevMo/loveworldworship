//
//  SessionModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class SessionModel:BaseModel {
    struct SessionSuccessModel: Codable {
        var status: Int?
        var data: [Datum]?
    }

    // MARK: - Datum
    struct Datum: Codable {
        var id, userID: Int?
        var sessionID: String?
        var platform: String?
        var platformDetails, time: String?
        var browser: String?
        var ipAddress: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case sessionID = "session_id"
            case platform
            case platformDetails = "platform_details"
            case time, browser
            case ipAddress = "ip_address"
        }
    }

    enum Browser: String, Codable {
        case appleSafari = "Apple Safari"
        case googleChrome = "Google Chrome"
        case unknown = "Unknown"
    }

    enum Platform: String, Codable {
        case androidWeb = "Android Web"
        case mac = "Mac"
        case unknown = "Unknown"
    }

}
class DeleteSessionModel: BaseModel {
    struct DeleteSessionSuccessModel: Codable {
        var status: Int?
        var data: String?
    }

}
