//
//  PurchaseTrackModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class PurchaseTrackModel: BaseModel {
    struct PurchaseTrackSuccessModel: Codable {
        let status: Int?
        let message: String?
    }

}
