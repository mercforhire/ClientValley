//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

typealias FormatPatterResponse = (unformatted: String?, formatted: String?)

public struct FormatPattern {
    var pattern: String = ""
    
    typealias FormatBlock = ((String?) -> String?)?
    var formatBlock: FormatBlock?
    
    var onlyFormatsOnEditEnd = false
    
    var limitsCharactersToPatternLength: Bool = false
    
    init(pattern: String = "", limitsCharactersToPatternLength: Bool = false) {
        self.pattern = pattern
        self.limitsCharactersToPatternLength = limitsCharactersToPatternLength
    }
    
    var isEmpty: Bool {
        return pattern.isEmpty
    }
    
    func update(input: String?, range: NSRange, replacementString string: String) -> FormatPatterResponse {        
        guard let input = input else {
            return (unformatted: nil, formatted: nil)
        }
        
        var fullString = input
        var shouldApply = false
        guard let unformatted = remove(from: fullString) else {
            return (unformatted: nil, formatted: nil)
        }
        
        let canModify = range.length > 0 ? true : canAdd(input: unformatted)
        
        if canModify {
            let diff = patternSymbolsUpTo(index: range.location)
            
            shouldApply = true
            let adjustedRange = NSRange(location: range.location - diff, length: range.length)
            if let textRange = Range(adjustedRange, in: unformatted) {
                fullString = unformatted.replacingCharacters(in: textRange, with: string)
            }
        }
        
        let formatted = apply(to: fullString)
        
        return (shouldApply ? fullString : unformatted, shouldApply ? formatted : fullString)
    }
    
    func update(input: String) -> FormatPatterResponse {
        let unformatted = remove(from: input)
        let formatted = apply(to: unformatted)
        
        return (unformatted, formatted)
    }
    
    func apply(to string: String?) -> String? {
        guard !pattern.isEmpty else {
            return string
        }
        
        guard let string = string else {
            return nil
        }
        
        guard !string.isEmpty else {
            return nil
        }
        
        guard !matches(to: string) else {
            return string
        }
        
        let charLimit = pattern.filter { $0 == "*" }.count
        
        var output = ""
        
        var inputCount = 0
        
        for char in pattern {
            if char == "*" {
                output += [string[inputCount]]
                inputCount += 1
            } else {
                output += [char]
            }
            
            if inputCount == string.count {
                break
            }
        }
        
        if limitsCharactersToPatternLength {
            if output.count < pattern.count && inputCount == charLimit {
                output += pattern[output.count...]
            }
        } else {
            if string.count > charLimit {
                output += string[charLimit...]
            }
        }

        return output
    }
    
    func matches(to string: String?) -> Bool {
        guard !pattern.isEmpty else {
            return true
        }
        
        guard let string = string else {
            return false
        }
        
        guard !string.isEmpty else {
            return false
        }
        
        let charLimit = pattern.filter { $0 == "*" }.count
        
        guard charLimit <= string.count else {
            return false
        }
        
        var inputCount = 0
        for char in pattern {
            if char != "*" {
                if string[inputCount] != char {
                    return false
                }
            }
            inputCount += 1
        }
        
        return true
    }
    
    func remove(from string: String?) -> String? {
        guard !pattern.isEmpty else {
            return string
        }
        
        guard let string = string else {
            return nil
        }
        
        let patternChar = pattern.map { return $0 != "*" }
        
        let filtered = string.enumerated().filter {
            if patternChar.contains(index: $0.offset) {
                return !patternChar[$0.offset]
            } else {
                return true
            }
        }
        
        let separator = ""
        return filtered.map { String($0.element) }.joined(separator: separator)
    }
    
    func patternSymbolsUpTo(index: Int ) -> Int {
        guard !pattern.isEmpty else {
            return 0
        }
        
        var indexToUse = index
        
        if index > pattern.count {
            indexToUse = pattern.count
        }
        
        let patternChar = pattern.map { return $0 != "*" }
        
        let slice = patternChar[..<indexToUse]
    
        return slice.reduce(0, { result, element in
            return result + (element ? 1 : 0)
        })
    }
    
    func canAdd(input: String?) -> Bool {
        guard let input = input else {
            return true
        }
        
        let charLimit = pattern.filter { $0 == "*" }.count
        
        if input.count < charLimit {
            return true
        } else {
            return !limitsCharactersToPatternLength
        }
    }
}

public enum FormatPatterns {
    case phone
    case postalCode
    case internationalPostalCode
    case internationalState
    case shortZipCode
    case zipCode
    case accountNumber
    case creditCardExpiry
    case creditCardCVC
    case dateOfBirth
    case verifyEFT
    
    func format() -> FormatPattern {
        switch self {
            
        case .phone:
            return FormatPattern(pattern: "(***) ***-****", limitsCharactersToPatternLength: true)
        case .postalCode:
            return FormatPattern(pattern: "*** ***", limitsCharactersToPatternLength: true)
        case .internationalPostalCode:
            return FormatPattern(pattern: "******", limitsCharactersToPatternLength: true)
        case .internationalState:
            return FormatPattern(pattern: "**", limitsCharactersToPatternLength: true)
        case .shortZipCode:
            return FormatPattern(pattern: "*****", limitsCharactersToPatternLength: true)
        case .zipCode:
            return FormatPattern(pattern: "*****-****", limitsCharactersToPatternLength: true)
        case .accountNumber:
            return FormatPattern(pattern: "**** **** **** ****", limitsCharactersToPatternLength: true)
        case .creditCardExpiry:
            return FormatPattern(pattern: "**/**", limitsCharactersToPatternLength: true)
        case .creditCardCVC:
            return FormatPattern(pattern: "***", limitsCharactersToPatternLength: true)
        case .dateOfBirth:
            return FormatPattern(pattern: "**/**/****", limitsCharactersToPatternLength: true)
        case .verifyEFT:
            return FormatPattern(pattern: "$*.**", limitsCharactersToPatternLength: true)
        }
    }
}
