//
//  PurchaseModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetPurchaseModel: BaseModel {
    struct GetPurchaseSuccessModel: Codable {
        let status: Int?
        let data: [Purchase]?
    }
}
