//
//  WidthdrawModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class WidthdrawModel: BaseModel {
    
    struct WidthdrawSuccessModel: Codable {
        let status: Int?
        let data: String?
    }
    
}
