//
//  Enums.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-15.
//

import Foundation
import UIKit

enum TeamRoles: String {
    case leader
    case manager
    case member
    
    func title() -> String {
        switch self {
        case .leader:
            return "Team leader"
        case .manager:
            return "Team manager"
        case .member:
            return "Team member"
        }
    }
    
    static func menulistString() -> [String] {
        return [TeamRoles.manager.title(),
                TeamRoles.member.title()]
    }
}

enum ContactMethodType {
    case email
    case phone
    case message
    case address
    
    func name() -> String {
        switch self {
        case .email:
            return "Email"
        case .phone:
            return "Phone"
        case .message:
            return "Message"
        case .address:
            return "Address"
        }
    }
    
    func icon() -> UIImage {
        switch self {
        case .email:
            return UIImage(systemName: "envelope.fill")!
        case .phone:
            return UIImage(systemName: "phone.fill")!
        case .message:
            return UIImage(systemName: "text.bubble.fill")!
        case .address:
            return UIImage(systemName: "mappin.and.ellipse")!
        }
    }
}

enum FollowUpType {
    case email
    case phone
    case message
    case address
    case list
    
    func name() -> String {
        switch self {
        case .email:
            return "Email"
        case .phone:
            return "Phone"
        case .message:
            return "Message"
        case .address:
            return "Address"
        case .list:
            return "List"
        }
    }
    
    func icon() -> UIImage {
        switch self {
        case .email:
            return UIImage(named: "Follow UP_Email")!
        case .phone:
            return UIImage(named: "Follow Up_Phone")!
        case .message:
            return UIImage(named: "Follow Up_Message")!
        case .address:
            return UIImage(named: "Follow Up_Address")!
        case .list:
            return UIImage(named: "Follow Up_List")!
        }
    }
    
    func showCheckmarks() -> Bool {
        switch self {
        case .email:
            return true
        case .phone:
            return false
        case .message:
            return true
        case .address:
            return true
        case .list:
            return false
        }
    }
}

enum CivilityStatus: String {
    case Mr = "Mr."
    case Mrs = "Mrs."
    case Ms = "Ms"
    case Miss = "Miss"
    
    func title() -> String {
        switch self {
        case .Mr:
            return "Mr."
        case .Mrs:
            return "Mrs."
        case .Ms:
            return "Ms"
        case .Miss:
            return "Miss"
        }
    }
    
    func gender() -> String {
        switch self {
        case .Mrs, .Ms, .Miss:
            return "Female"
        case .Mr:
            return "Male"
        }
    }
    
    static func list() -> [CivilityStatus] {
        return [.Mr, .Mrs, .Ms, .Miss]
    }
    
    static func listString() -> [String] {
        return [CivilityStatus.Mr.title(),
                CivilityStatus.Mrs.title(),
                CivilityStatus.Ms.title(),
                CivilityStatus.Miss.title()]
    }
}

enum OptionalAttributes: String {
    case totalExpense
    case notes
    
    func title() -> String {
        switch self {
        case .totalExpense:
            return "Total Expense"
        case .notes:
            return "Notes"
        }
    }
    
    static func list() -> [OptionalAttributes] {
        return [.totalExpense, .notes]
    }
}

enum TemplateType {
    case email
    case message
    
    func title() -> String {
        switch self {
        case .email:
            return "Email Templates List"
        case .message:
            return "Message Templates List"
        }
    }
}

enum AppoType: String {
    case online = "Online"
    case atLocation = "At location"
    case voice = "Voice call"
    case other = "Other"
    
    static func random() -> AppoType {
        switch Int.random(in: 0...3) {
        case 0:
            return .online
        case 1:
            return .atLocation
        case 2:
            return .voice
        case 3:
            return .other
        default:
            return .other
        }
    }
    
    static func list() -> [AppoType] {
        return [.online, .atLocation, .voice, .other]
    }
    
    static func listString() -> [String] {
        return [AppoType.online.rawValue, AppoType.atLocation.rawValue, AppoType.voice.rawValue, AppoType.other.rawValue]
    }
}

enum ReminderChoices: String {
    case off = "Off"
    case exact = "Start time"
    case at15min = "15 mins"
    case at30min = "30 mins"
    case at1hour = "1 hour"
    
    func title() -> String {
        switch self {
        case .off:
            return "Off"
        case .exact:
            return "At start time"
        case .at15min:
            return "15 mins before start time"
        case .at30min:
            return "30 mins before start time"
        case .at1hour:
            return "1 hour before start time"
        }
    }
    
    func timeRemaining() -> String {
        switch self {
        case .exact:
            return "Now"
        case .at15min:
            return "15 minutes"
        case .at30min:
            return "30 minutes"
        case .at1hour:
            return "1 hour"
        default:
            return ""
        }
    }
    
    static func random() -> ReminderChoices {
        switch Int.random(in: 0...4) {
        case 0:
            return .off
        case 1:
            return .exact
        case 2:
            return .at15min
        case 3:
            return .at30min
        case 4:
            return .at1hour
        default:
            return .off
        }
    }
    
    static func list() -> [ReminderChoices] {
        return [.off, .exact, .at15min, .at30min, .at1hour]
    }
    
    static func listString() -> [String] {
        return [ReminderChoices.off.rawValue, ReminderChoices.exact.rawValue, ReminderChoices.at15min.rawValue, ReminderChoices.at30min.rawValue, ReminderChoices.at1hour.rawValue]
    }
}
