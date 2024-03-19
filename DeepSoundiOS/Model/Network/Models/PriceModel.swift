//
//  PriceModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class PriceModel: BaseModel {
    // MARK: - Welcome
    struct PriceSuccessModel: Codable {
        let status: Int?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let id: Int?
        let price: String?
    }
}
