//
//  Validations.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation

class RegularExpressions {
    static let email = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,3})$"
}


enum Validation {
    case email, required, min(length: Int), max(length: Int)
    
    
    func validate(text: String) -> Bool {
        
        switch self {
        case .email:
            let regex = try! NSRegularExpression(pattern: RegularExpressions.email, options: .caseInsensitive)
            let valid = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) != nil
            return valid
        case .required:
            return text.count > 0
        case .min(length: let length):
            return text.count >= length
        case .max(length: let length):
            return text.count <= length
        }
    }
    var error: String {
        switch self {
        case .email:
            return "Must be a valid email address"
        case .required:
            return "This field is required"
        case .min(length: let length):
           return "Must be at least \(length) characters long"
        case .max(length: let length):
            return "Should be at most \(length) characters long"
        }
    }
}
