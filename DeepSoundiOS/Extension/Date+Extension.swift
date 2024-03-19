//
//  Date+Extension.swift
//  Libraries And Extensions
//
//  Created by Nazmi Yavuz on 15.11.2021.
//  Copyright © 2021 Nazmi Yavuz. All rights reserved.
//

import Foundation

extension Date {
        
    func getFormattedDate(format: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    func getHourFormat() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm"
        return dateFormat.string(from: self)
        
    }
    
    func getDayMonthYearFormat() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy"
        return dateFormat.string(from: self)
        
    }
    
    func getMonthYearFormat() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM.yyyy"
        guard let date = self.turnUTCDate() else {
            return dateFormat.string(from: self)
        }
        return dateFormat.string(from: date)
    }
    
    /// increment to date to get expire date which will be used handling the expiration of pro subscriptions.
    /// - Parameters:
    ///   - component: Calendar.Component that you want to add
    ///   - value: is increment to get the expire date
    ///   - calendar: .current
    /// - Returns: expire date
    func adding(_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: component, value: value, to: self)
        ?? self.addingTimeInterval(component.timeInterval*Double(value))
    }
        
    func getUTCDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        return formatter.string(from: self)
    }
    
    func turnUTCDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString)
    }
    
}

extension Optional where Wrapped == Date {
    
    func adding(_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date {
        guard let addingDate = self else { return Date().addingTimeInterval(component.timeInterval*Double(value)) }
        return calendar.date(byAdding: component, value: value, to: addingDate)!
    }
    
    func getUTCDateString() -> String {
        guard let value = self else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        return formatter.string(from: value)
    }
    
}

extension Calendar.Component {
    ///  TimeInterval is used for add time for certain date
    /// - Returns: second, minute, hour, day, month and year component otherwise return 0.0
    var timeInterval: TimeInterval {
        switch self {
        case .era: return 0.0
        case .year: return 60*60*24*365
        case .month: return 60*60*24*30
        case .day: return 60*60*24
        case .hour: return 60*60
        case .minute: return 60
        case .second: return 1
        case .weekday: return 0.0
        case .weekdayOrdinal: return 0.0
        case .quarter: return 0.0
        case .weekOfMonth: return 0.0
        case .weekOfYear: return 0.0
        case .yearForWeekOfYear: return 0.0
        case .nanosecond: return 0.0
        case .calendar: return 0.0
        case .timeZone: return 0.0
        @unknown default: return 0.0
        }
    }
}
