//
//  StoryModel.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation


class StoryModel: BaseModel {
    
    struct StorySuccessModel: Codable {
        let status : Int
        let data : [Story]
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
    
    struct StartStorySuccessModel: Codable {
        let status : Int
        let data : Story?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
}

struct Story : Codable {
    let id : Int
    let user_id : Int
    let image : String
    let audio : String
    let paid : Int
    let url : JSONAny
    let active : Int
    let time : Int
    let user_data : Publisher
    let org_image : String
    let org_audio : String
    let views_count : Int
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case user_id = "user_id"
        case image = "image"
        case audio = "audio"
        case paid = "paid"
        case url = "url"
        case active = "active"
        case time = "time"
        case user_data = "user_data"
        case org_image = "org_image"
        case org_audio = "org_audio"
        case views_count = "views_count"
    }
}
