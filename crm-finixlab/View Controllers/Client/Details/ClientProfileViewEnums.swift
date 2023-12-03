//
//  ClientProfileViewEnums.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import Foundation

enum ProfileDetailType: Int {
    case basic
    case additional
    
    func title() -> String {
        switch self {
        case .basic:
            return "Basic Info"
        case .additional:
            return "Additional Info"
        }
    }
    
    static func list() -> [ProfileDetailType] {
        return [.basic, .additional]
    }
    
    static func listString() -> [String] {
        return [ProfileDetailType.basic.title(), ProfileDetailType.additional.title()]
    }
}

enum ProfileInfoRows {
    case clientID
    case creator
    case birthday
    case gender
    case email
    case phone
    case nation
    case address
    case tags
    case notes
    case ratings
    case totalExpense
    case editAttribute
    
    func title() -> String {
        switch self {
        case .clientID:
            return "Client ID"
        case .creator:
            return "Creator"
        case .birthday:
            return "Birthday"
        case .gender:
            return "Gender"
        case .email:
            return "Email"
        case .phone:
            return "Phone"
        case .nation:
            return "Nationality"
        case .address:
            return "Address"
        case .notes:
            return "Notes"
        case .ratings:
            return "Rating"
        case .totalExpense:
            return "Total Expense"
        default:
            return ""
        }
    }
    
    static func basicInfolist() -> [ProfileInfoRows] {
        return [.clientID, .creator, .birthday, .gender, .email, .phone, .nation, .address, .tags]
    }
    
    static func basicInfolistString() -> [String] {
        return [ProfileInfoRows.clientID.title(), ProfileInfoRows.creator.title(), ProfileInfoRows.birthday.title(), ProfileInfoRows.gender.title(), ProfileInfoRows.email.title(), ProfileInfoRows.phone.title(), ProfileInfoRows.nation.title(), ProfileInfoRows.address.title(), ProfileInfoRows.tags.title()]
    }
    
    static func additionalList() -> [ProfileInfoRows] {
        return [.notes, .ratings, .totalExpense, .editAttribute]
    }
}
