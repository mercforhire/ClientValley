//
//  Validator.swift
//  Form
//
//  Created by Adam Borzecki on 3/20/18.
//
import Foundation

public enum Validations {
    case notEmpty
    case length(Int)
    case minimumLength(Int)
    case maximumLength(Int)
    case alphanumeric
    case alphanumericWithSpace
    case containsOneAlpha
    case containsOneNumber
    case containsOneLowerCase
    case containsOneUpperCase
    case containsOneSpecial
    case numeric
    case match(() -> String, Bool) // (function that generates the string, Boolean: caseSensitive)
    case notMatch(() -> String, Bool) // (function that generates the string, Boolean: caseSensitive)
    case compareDouble((Double) -> Bool)
    case notContain(String)
    case postalCode
    case email
    case incrementOf(Int)
    case maxConsecutiveNumbers(Int)
    case isAProperName
    case notAllIdentical
    case notSequential
    case notStartWith(String)
    case notIdenticalWithInRange(Int, Int)
}

// password must be 8 to 32 characters & contain a mix of upper & lower case letters, numbers.
class PasswordValidator {
    // returns nil if no error, error string if found
    static func validate(string: String) -> String? {
        if !Validator.validate(string: string, validation: .minimumLength(8)) {
            return "Password must be 8 or more characters"
        }
        
        if !Validator.validate(string: string, validation: .maximumLength(32)) {
            return "Password must be 32 or less characters"
        }
        
//        if !Validator.validate(string: string, validation: .containsOneUpperCase) {
//            return "Password must contain one upper case letter"
//        }
//
//        if !Validator.validate(string: string, validation: .containsOneLowerCase) {
//            return "Password must contain one lower case letter"
//        }
//
//        if !Validator.validate(string: string, validation: .containsOneNumber) {
//            return "Password must contain a number"
//        }
        
        return nil
    }
}

class Validator {
    static let specialCharacters: [Character] = [
        "`",
        "~",
        "!",
        "@",
        "#",
        "$",
        "%",
        "^",
        "&",
        "(",
        ")",
        "-",
        "_",
        "=",
        "+",
        "[",
        "]",
        "{",
        "}",
        "\\",
        "|",
        ";",
        ":",
        "’",
        "“",
        "<",
        ">",
        ",",
        ".",
        "/",
        "?"
    ]
    
    static func validate(string: String, validation: Validations) -> Bool {
        switch validation {
        case .notEmpty:
            return !string.trimmingCharacters(in: .whitespaces).isEmpty
            
        case .length(let length):
            return string.count == length
            
        case .minimumLength(let minLength):
            return string.count >= minLength
            
        case .maximumLength(let minLength):
            return string.count <= minLength
            
        case .alphanumeric:
            return string.isAlphanumeric
            
        case .alphanumericWithSpace:
            var allowedCharacters = CharacterSet.alphanumerics
            allowedCharacters.insert(charactersIn: " -") // "white space & hyphen"
            
            let unwantedStr = string.trimmingCharacters(in: allowedCharacters)
            return unwantedStr.isEmpty
            
        case .containsOneAlpha:
            let regex = try? NSRegularExpression(pattern: "([a-z])", options: .caseInsensitive)
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
        case .containsOneNumber:
            let regex = try? NSRegularExpression(pattern: "([0-9])", options: .caseInsensitive)
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
            
        case .containsOneLowerCase:
            let regex = try? NSRegularExpression(pattern: "([a-z])")
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
        case .containsOneUpperCase:
            let regex = try? NSRegularExpression(pattern: "([A-Z])")
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
            
            
        case .containsOneSpecial:
            let specialCharsInInput: Set<Character> = Set(Validator.specialCharacters).intersection(string)
            return !specialCharsInInput.isEmpty
            
        case .numeric:
            return string.isNumeric
            
        case .match(let matchStringFunc, let caseSensitive):
            if caseSensitive {
                return string == matchStringFunc()
            } else {
                return string.lowercased() == matchStringFunc().lowercased()
            }
            
        case .notMatch(let matchStringFunc, let caseSensitive):
            if caseSensitive {
                return string != matchStringFunc()
            } else {
                return string.lowercased() != matchStringFunc().lowercased()
            }
            
        case .compareDouble(let compareFunc):
            guard let inputASDouble = Double(string) else {
                return true
            }
            
            return compareFunc(inputASDouble)
            
        case .notContain(let matchString):
            return string.range(of: matchString, options: .caseInsensitive) == nil
            
            
        case .postalCode:
            let regex = try? NSRegularExpression(pattern: "^[a-z][0-9][a-z]\\s?[0-9][a-z][0-9]$", options: .caseInsensitive)
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
            
        case .email:
            let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+$")
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return !actualResults.isEmpty
            
        case .incrementOf(let incrementAmount):
            if let number: Int = string.numbers.int, number % incrementAmount == 0 {
                return true
            }
            
            return false
            
        case .maxConsecutiveNumbers(let count):
            let regex = try? NSRegularExpression(pattern: "(?<!\\d)(\\d{\(count)})")
            
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else {
                return false
            }
            
            return actualResults.isEmpty
            
        case .notAllIdentical:
            let regex = try? NSRegularExpression(pattern: "(\\w)\\1{\(string.count - 1),}")
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else { return false }
            
            return actualResults.isEmpty
            
        case .notIdenticalWithInRange(let start, let end):
            guard start >= 0, end < string.count else {
                return false
            }
            
            let startIndex = string.index(string.startIndex, offsetBy: start)
            let endIndex = string.index(string.startIndex, offsetBy: end)
            let range = startIndex...endIndex
            let substring: Substring = string[range]
            let croppedString: String = String(substring)
            let regex = try? NSRegularExpression(pattern: "(\\w)\\1{\(croppedString.count - 1),}")
            let results = regex?.matches(in: croppedString, options: [], range: NSRange(location: 0, length: croppedString.count))
            
            guard let actualResults = results else { return false }
            
            return actualResults.isEmpty
            
        case .notSequential:
            guard string.isNumeric else { return false }
            
            var numbers: [Int] = []
            for char in string {
                let number = String(char).int ?? 0
                numbers.append(number)
            }
            
            var forwardlySequential: Bool = true
            // check if input is forwardly sequential
            for currentIndex in 0...numbers.count - 2 { // loop from 0 to the second last character
                let nextIndex: Int = currentIndex + 1
                
                if numbers[currentIndex] == 9 {
                    // next number has to be 0 to be sequential
                    if numbers[nextIndex] != 0 {
                        forwardlySequential = false
                        break
                    }
                } else {
                    // next number has to 1 higher than current to be sequential
                    if numbers[nextIndex] != numbers[currentIndex] + 1 {
                        forwardlySequential = false
                        break
                    }
                }
            }
            
            var backwardlySequential: Bool = true
            // check if input is backwardly sequential
            for currentIndex in (1...numbers.count - 1).reversed() { // loop from last character to second character
                let previousIndex: Int = currentIndex - 1
                
                if numbers[currentIndex] == 9 {
                    // previous number has to be 0 to be sequential
                    if numbers[previousIndex] != 0 {
                        backwardlySequential = false
                        break
                    }
                } else {
                    // previous number has to 1 higher than current to be sequential
                    if numbers[previousIndex] != numbers[currentIndex] + 1 {
                        backwardlySequential = false
                        break
                    }
                }
            }
            
            return !(forwardlySequential || backwardlySequential)
            
        case .notStartWith(let startWith):
            let regex = try? NSRegularExpression(pattern: "^\(startWith)")
            let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let actualResults = results else { return false }
            
            return actualResults.isEmpty
            
        case .isAProperName:
            // Maximum of 30 characters
            // Can not have one letter only
            if string.count < 2 || string.count > 30 {
                return false
            }
            
            // Name cannot begin with space or special character (-,', .); only dash, apostrophe, and french characters apply, others are invalid as part of name
            // Special characters: [` ~ ! @ # $ % ^ & ( ) - _ = + [ ] { } \ | ; : ’ “ < > , . / ?]
            let firstLetter: Character = string[0]
            if specialCharacters.contains(firstLetter) {
                return false
            }
            
            // If a space is used to separate a name,
            // must include 2 letters PRIOR to space and 2 letters AFTER space (cannot be letter-space-letter or any other combination with one letter only)
            let words = string.components(separatedBy: " ")
            if words.count > 1 {
                let invalidWords = words.filter({ word -> Bool in
                    return word.count < 2
                })
                if !invalidWords.isEmpty {
                    return false
                }
            }
            
            // If a dash is used to separate a name,
            // no consecutive dashes, no dashes between single letters, no dash to begin a field, must be 2 letters PRIOR to dash and 2 letters AFTER dash
            let words2 = string.components(separatedBy: "-")
            if words2.count > 1 {
                let invalidWords = words2.filter({ word -> Bool in
                    return word.count < 2
                })
                if !invalidWords.isEmpty {
                    return false
                }
            }
            
            //    If an apostrophe is used to separate a name, the following rules apply:
            //    - no consecutive apostrophes, no apostrophe to begin a field, no letter-apostrophe-letter; CAN have (one or multiple) letters then apostrophe then multiple letters OR multiple betters then apostrophe then (one or multiple) letters (i.e. St John's or O'Hare)
            let words3 = string.components(separatedBy: "'")
            if words3.count > 1 {
                let invalidWords = words3.filter({ word -> Bool in
                    return word.count < 1
                })
                if !invalidWords.isEmpty {
                    return false
                }
            }
            
            return true
        }
    }
}
