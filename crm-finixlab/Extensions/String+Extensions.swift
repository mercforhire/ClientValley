//
//  String+Extensions.swift
//  Phoenix
//
//  Created by Illya Gordiyenko on 2018-06-13.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit
import Foundation

extension String {
    private static let noCharacter = ""
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public var isAlphanumeric: Bool {        
        return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
    
    public var isNumeric: Bool {
        return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    public func removeAllWhitespace() -> String {
        return self.components(separatedBy: CharacterSet.whitespaces).joined(separator: String.noCharacter)
    }
    
    public var isNotApplicable: Bool {
        let compareString = self.lowercased()
        let compareArray = ["not applicable",
                            "na",
                            "not allowed",
                            "not aplicable",
                            "not appliable",
                            "n\\a",
                            "n.a",
                            "na",
                            "n.a.",
                            "n/a"]
        return compareArray.contains(compareString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    public var double: Double? {
        return NumberFormatter().number(from: self) as? Double
    }
    
    public var float: Float? {
        return NumberFormatter().number(from: self) as? Float
    }
    
    public var float32: Float32? {
        return NumberFormatter().number(from: self) as? Float32
    }
    
    public var float64: Float64? {
        return NumberFormatter().number(from: self) as? Float64
    }
    
    public var int: Int? {
        return Int(self)
    }
    
    public var int16: Int16? {
        return Int16(self)
    }
    
    public var int32: Int32? {
        return Int32(self)
    }
    
    public var int64: Int64? {
        return Int64(self)
    }
    
    public var int8: Int8? {
        return Int8(self)
    }
    
    public var url: URL? {
        return URL(string: self)
    }
    
    public var doubleFromCurrency: Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.number(from: self) as? Double
    }
    
    /// Extract numbers from string
    public var numbers: String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = self.components(separatedBy: set)
        return numbers.joined()
    }
    
    public var removeNumbers: String {
        let set = CharacterSet.decimalDigits
        let notNumbers = self.components(separatedBy: set)
        return notNumbers.joined()
    }
    
    // Trim to a set length
    public func trimToLength(length: Int, addDotsToEnd: Bool = false) -> String {
        if self.count <= length || (addDotsToEnd && self.count <= 3) {
            return self
        }
        
        if addDotsToEnd {
            let substring = self[..<(length - 3)]
            return String(substring) + "..."
        } else {
            let substring = self[..<length]
            return String(substring)
        }
    }
    
    public func stripUppercaseLetters() -> String {
        let unsafeChars = CharacterSet.uppercaseLetters
        let cleanChars = components(separatedBy: unsafeChars).joined()
        return cleanChars
    }
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }
    
    subscript(input: Int) -> Character {
        return self[index(startIndex, offsetBy: input)]
    }
    
    subscript(value: CountableClosedRange<Int>) -> Substring {
        return self[index(at: value.lowerBound)...index(at: value.upperBound)]
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        return self[..<index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        return self[...index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        return self[index(at: value.lowerBound)...]
    }
    
    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}

extension String {
    func date(from fromFormat: DateUtil.AppDateFormat, to toFormat: DateUtil.AppDateFormat) -> String? {
        return DateUtil.convert(input: self, inputFormat: fromFormat, outputFormat: toFormat)
    }
    
    // calculate the height Of UILabel
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension String {
    func contains(string: String, caseInsensitive: Bool = true) -> Bool {
        if caseInsensitive {
            return self.lowercased().contains(string.lowercased())
        }
        
        return contains(string)
    }
}

extension String {
    func separateCharacters() -> String {
        return map { String($0) }.joined(separator: " ")
    }
    
    func removePlusSignFromAreaCode() -> String {
        let updatedText = replacingOccurrences(of: "+ ", with: "")
        return updatedText
    }
    
    func addPlusSignToAreaCode() -> String {
        let updatedText = "+ \(self)"
        return updatedText
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
