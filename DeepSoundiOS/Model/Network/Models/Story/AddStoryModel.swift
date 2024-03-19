//
//  AddStoryModel.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation


class AddStoryModel: BaseModel {
    
    struct AddStorySuccessModel: Codable {
        
        public var status : Int
        public var story_id : Int
        public var audio : String
        public var data : AddStory
        public var payment_modal : String
        public var message : String
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case story_id = "story_id"
            case audio = "audio"
            case data = "data"
            case payment_modal = "payment_modal"
            case message = "message"
        }
    }
}

struct AddStory : Codable {
    public var id : Int
    public var user_id : Int
    public var image : String
    public var audio : String
    public var paid : Int
    public var url : String
    public var active : Int
    public var time : Int
    public var user_data : Publisher
    public var org_image : String
    public var org_audio : String
    public var views_count : Int
    
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
