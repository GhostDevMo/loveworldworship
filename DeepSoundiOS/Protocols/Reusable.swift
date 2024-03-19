//
//  Reusable.swift
//  ScanQR
//
//  Created by Mohammed Hamad on 02/04/2021.
//  Copyright © 2021 Dev. Mohmd. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        get {
            return String(describing: self)
        }
    }
}
