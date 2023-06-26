//
//  BankTransferModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class BankTransferModel:BaseModel{
    struct BankTransferSuccessModel: Codable {
        var status: Int?
        var data: String?
    }

}
