//
//  TwoFactorModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class TwoFactorUpdateModel:BaseModel{
    struct TwoFactorUpdateSuccessModel: Codable {
         var status: Int?
         var data: String?
     }
}
