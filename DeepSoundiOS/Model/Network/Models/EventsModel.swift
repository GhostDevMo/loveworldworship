//
//  EventsModel.swift
//  DeepSoundiOS
//
//  Created by iMac on 07/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import Foundation

class EventsModel: BaseModel {
    struct EventsModelSuccessModel: Codable {
        let status: Int?
        let data: [Events]?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
}
