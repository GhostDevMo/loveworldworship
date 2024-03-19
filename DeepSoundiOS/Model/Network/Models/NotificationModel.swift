//
//  NotificationModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

struct NotificationModel: Codable {
    
    let status : Int?
    let notifiations : [Notifiations]?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case notifiations = "notifiations"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        notifiations = try values.decodeIfPresent([Notifiations].self, forKey: .notifiations)
    }
    
}

class notificationUnseenCountModel: BaseModel {
    struct notificationUnseenCountSuccessModel: Codable {
        let status, count, msgs: Int?
    }
}

struct Notifiations : Codable {
    let uSER_DATA : Publisher?
    let n_id : Int?
    let n_time : String?
    let n_text : String?
    let n_url : String?
    let n_a_url : String?
    let n_type : String?

    enum CodingKeys: String, CodingKey {
        case uSER_DATA = "USER_DATA"
        case n_id = "n_id"
        case n_time = "n_time"
        case n_text = "n_text"
        case n_url = "n_url"
        case n_a_url = "n_a_url"
        case n_type = "n_type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uSER_DATA = try values.decodeIfPresent(Publisher.self, forKey: .uSER_DATA)
        n_id = try values.decodeIfPresent(Int.self, forKey: .n_id)
        n_time = try values.decodeIfPresent(String.self, forKey: .n_time)
        n_text = try values.decodeIfPresent(String.self, forKey: .n_text)
        n_url = try values.decodeIfPresent(String.self, forKey: .n_url)
        n_a_url = try values.decodeIfPresent(String.self, forKey: .n_a_url)
        n_type = try values.decodeIfPresent(String.self, forKey: .n_type)
    }

}
