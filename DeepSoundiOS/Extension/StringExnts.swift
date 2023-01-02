//
//  StringExnts.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import Photos
import UIKit

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var toDate: Date? {
        var date: Date? = nil
        var dateString = self
        
        if dateString.contains("0000-01-01T") {
            dateString = dateString.replacingOccurrences(of: "0000-01-01T", with: Date().stringValue(format: "yyyy-MM-dd", timeZone: .current) + "T")
        }
        
        let formates = ["yyyy-MM-dd'T'HH:mm:ss.SSSS", "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss", "dd MMM yyyy", "MM-dd-yyyy"]
        for f in formates {
            if let d = dateString.dateValue(format: f) {
                date = d
                break
            }
        }
        
        return date
    }
    
    func dateValue(format: String, timeZone: TimeZone? = TimeZone(abbreviation: "GMT")) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.height
    }
    
    func width(withHeight height: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.width
    }
}

extension String {
    
    func decodeEmoji() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        return String(data: data, encoding: .nonLossyASCII) ?? self
    }
    
    func encodeEmoji() -> String {
        guard let data = self.data(using: .nonLossyASCII, allowLossyConversion: true) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}


extension Date {
    func stringValue(format: String, timeZone: TimeZone? = TimeZone(abbreviation: "GMT")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    func dateByAdding(hours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)
    }
    func dateByAdding(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    func dateByAdding(months: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: months, to: self)
    }
    func dateByAdding(years: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: years, to: self)
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    var timeText: String {
        if self.stringValue(format: "yyyy-MM-dd", timeZone: .current) == Date().stringValue(format: "yyyy-MM-dd", timeZone: .current) {
            return self.stringValue(format: "hh:mm a", timeZone: .current)
        } else if self.stringValue(format: "yyyy", timeZone: .current) == Date().stringValue(format: "yyyy", timeZone: .current) {
            return self.stringValue(format: "MMM dd, hh:mm a", timeZone: .current)
        }
        return self.stringValue(format: "MMM dd yyyy, hh:mm a", timeZone: .current)
    }
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    func toUTC(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        return self.stringValue(format: format)
    }
}

extension NSObject {
    static var name: String {
        return String(describing: self)
    }
}

extension Array {
    func object(at index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

extension PHAsset {
    func getThumbnail(completion: @escaping (_ image: UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        manager.requestImage(for: self, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option) { result, info in
            completion(result)
        }
    }
}

extension Int {
    mutating func increment(by: Int = 1) {
        self += 1
    }
    mutating func decrement(by: Int = 1) {
        self -= 1
    }
}
extension String {
    func deleteHTMLTag(tag:String) -> String {
       
        return self .replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
    }

    func deleteHTMLTags(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag: tag)
        }
        return mutableString
    }
}

extension String
{
    var stringToAttributed: NSAttributedString?
    {
        guard let data = data(using: .utf8) else { return nil }
        do
        {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let content = try NSMutableAttributedString(data: data, options: [.documentType:     NSAttributedString.DocumentType.html, .characterEncoding:     String.Encoding.utf8.rawValue], documentAttributes: nil)

            content.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                   NSAttributedString.Key.font: R.font.urbanistSemiBold(size: 20)!,
                                   NSAttributedString.Key.foregroundColor: UIColor.black],
                                  range: NSMakeRange(0, content.length))

            return content
        }
        catch
        {
            return nil
        }
    }
}
