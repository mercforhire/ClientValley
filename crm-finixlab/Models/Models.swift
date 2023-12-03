//
//  Models.swift
//  Task Tracker
//
//  Created by MongoDB on 2020-05-07.
//  Copyright © 2020 MongoDB, Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SKCountryPicker
import Contacts
import HanziPinyin

// _partition: "user={user_id}"
class TeamInvitation: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var leader: String = ""
    @Persisted var teamId: String = ""
    @Persisted var userId: String = ""
    @Persisted var role: String = ""
    
    convenience init(document: Document) {
        self.init()
        self._id = document["_id"]!!.objectIdValue!
        self._partition = document["_partition"]!!.stringValue!
        self.leader = document["leader"]!!.stringValue!
        self.teamId = document["teamId"]!!.stringValue!
        self.userId = document["userId"]!!.stringValue!
        self.role = document["role"]!!.stringValue!
    }
}

// _partition: "team={team_id}"
class Team: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var name: String = ""
    @Persisted var leader: String = ""
    @Persisted var managers: List<String> = List()
    @Persisted var members: List<String> = List()
    @Persisted var roles: List<TeamRole> = List()
    
    func canRemoveManager(userId: String) -> Bool {
        return leader == userId
    }
    
    func canRemoveMember(userId: String) -> Bool {
        return leader == userId || managers.contains(userId)
    }
    
    convenience init(document: Document) {
        self.init()
        self._id = document["_id"]!!.objectIdValue!
        self._partition = document["_partition"]!!.stringValue!
        self.name = document["name"]!!.stringValue!
        self.leader = document["leader"]!!.stringValue!
        
        let managers: List<String> = List()
        for manager in document["managers"]!!.arrayValue! {
            managers.append(manager!.stringValue!)
        }
        self.managers = managers
        
        let members: List<String> = List()
        for member in document["members"]!!.arrayValue! {
            members.append(member!.stringValue!)
        }
        self.members = members
        
        let roles: List<TeamRole> = List()
        for roleBSON in document["roles"]!!.arrayValue! {
            let role = TeamRole(document: roleBSON!.documentValue!)
            roles.append(role)
        }
        self.roles = roles
    }
}

class TeamRole: EmbeddedObject {
    @Persisted var userId: String = ""
    @Persisted var role: String = ""
    
    var roleEnum: TeamRoles? {
        get {
            return TeamRoles(rawValue: role)
        }
        set {
            role = newValue?.rawValue ?? ""
        }
    }
    
    convenience init(document: Document) {
        self.init()
        self.userId = document["userId"]!!.stringValue!
        self.role = document["role"]!!.stringValue!
    }
}

// _partition: "PUBLIC"
class TeamMember: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var userId: String = ""
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var email: String?
    @Persisted var avatar: Data?
    @Persisted var phone: Phone?
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    var initials: String {
        if let firstLetter = firstName.first, let secondLetter = lastName.first {
            return "\(firstLetter) \(secondLetter)".uppercased()
        } else if let firstLetter = firstName.first {
            return "\(firstLetter)".capitalized
        } else {
            return ""
        }
    }
    
    var fullName: String {
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var avatarImage: UIImage? {
        if let avatar = avatar {
            return UIImage(data: avatar)
        }
        return nil
    }
}

// _partition: "user={user_id}"
class User: Object {
    @Persisted(primaryKey: true) var _id: String = ""
    @Persisted var _partition: String = ""
    @Persisted var name: String = ""
}

// _partition: "user={user_id}"
class UserData: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var avatar: Data?
    @Persisted var phone: Phone?
    @Persisted var currentTeam: ObjectId?
    @Persisted var joinedTeams = List<ObjectId>()
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    var initials: String {
        if let firstLetter = firstName.first, let secondLetter = lastName.first {
            return "\(firstLetter) \(secondLetter)".uppercased()
        } else if let firstLetter = firstName.first {
            return "\(firstLetter)".capitalized
        } else {
            return ""
        }
    }
    
    var fullName: String {
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var avatarImage: UIImage? {
        if let avatar = avatar {
            return UIImage(data: avatar)
        }
        return nil
    }
}

// _partition: "user={user_id}"
class Feedback: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var type: String = ""
    @Persisted var message: String = ""
    @Persisted var creatorEmail: String = ""
    @Persisted var creator: String = ""
    
    convenience init(partition: String, type: String, message: String, creatorEmail: String, creator: String) {
        self.init()
        self._partition = partition
        self.type = type
        self.message = message
        self.creatorEmail = creatorEmail
        self.creator = creator
    }
}

// _partition: "user={user_id}"
class SavedSearch: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var lastName: String?
    @Persisted var firstName: String?
    @Persisted var phone: Phone?
    @Persisted var email: String?
    @Persisted var clientID: String?

    convenience init(partition: String) {
        self.init()
        self._partition = partition
        self.phone = Phone()
    }
    
    func clear() {
        lastName = nil
        firstName = nil
        phone = Phone()
        email = nil
        clientID = nil
    }
}

// _partition: "user={user_id}"
class TempClient: Object {
    @Persisted(primaryKey: true)  var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var avatar: Data?
    @Persisted var civility: String?
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var address: Address?
    @Persisted var email: String?
    @Persisted var phone: Phone?
    @Persisted var birthday: Date?
    @Persisted var metadata: Metadata?
    @Persisted var contactMethod: ContactMethod?

    var statusEnum: CivilityStatus? {
        get {
            if let civility = civility {
                return CivilityStatus(rawValue: civility)
            }
            return nil
        }
        set {
            civility = newValue?.rawValue
        }
    }
    
    var initials: String {
        if let firstLetter = firstName?.first, let secondLetter = lastName?.first {
            return "\(firstLetter) \(secondLetter)".uppercased()
        } else if let firstLetter = firstName?.first {
            return "\(firstLetter)".capitalized
        } else {
            return ""
        }
    }

    convenience init(partition: String) {
        self.init()
        self._partition = partition
        self.address = Address()
        self.phone = Phone()
        self.metadata = Metadata()
        self.contactMethod = ContactMethod()
    }
    
    func readFromContact(contact: CNContact) {
        for email in contact.emailAddresses {
            let emailAddress = email.value as String
            if !emailAddress.isEmpty {
                self.email = emailAddress
                break
            }
        }
       
        self.firstName = contact.givenName
        self.lastName = contact.familyName
        
        if let imageData = contact.imageData, let image = UIImage(data: imageData)?.resizeImage(100, opaque: true), let finalImageData = image.pngData() {
            self.avatar = finalImageData
        }
        
        for contactPhone in contact.phoneNumbers {
            let phoneNumber = contactPhone.value.stringValue
            if !phoneNumber.isEmpty {
                self.phone?.phone = phoneNumber.numbers
                break
            }
        }
        
        if self.address == nil {
            self.address = Address()
        }
        
        if let address = contact.postalAddresses.count > 0 ? "\(contact.postalAddresses[0].value.street)" : nil {
            self.address?.address = address
        }
        
        if let city = contact.postalAddresses.count > 0 ? "\(contact.postalAddresses[0].value.city)" : nil {
            self.address?.city = city
        }
        
        if let state = contact.postalAddresses.count > 0 ? "\(contact.postalAddresses[0].value.state)" : nil {
            self.address?.province = state
        }
        
        if let zipCode = contact.postalAddresses.count > 0 ? "\(contact.postalAddresses[0].value.postalCode)" : nil {
            self.address?.zipCode = zipCode
        }
        
        if let countryName = contact.postalAddresses.count > 0 ? "\(contact.postalAddresses[0].value.country)" : nil,
           let country = CountryManager.shared.country(withName: countryName) {
            self.address?.country = country.englishName
            self.address?.countryCode = country.countryCode
        }
        
        if let birthday = contact.birthday?.date {
            let seconds = TimeZone.current.secondsFromGMT() * -1
            self.birthday = birthday.addingTimeInterval(TimeInterval(seconds))
        }
    }
    
    func randomize() {
        self.avatar = Bool.random() ? UIImage(named: "avataaars (\(Int.random(in: 0...40)))")!.resizeImage(100, opaque: true).pngData() : nil
        self.civility = CivilityStatus.list().randomElement()!.title()
        self.firstName = Lorem.firstName
        self.lastName = Lorem.lastName
        self.address = Address.random()
        self.email = "\(self.firstName!.lowercased())\(self.lastName!.lowercased())@\(Lorem.word.lowercased()).com"
        self.phone = Phone.random()
        self.birthday = Date().getPastOrFutureDate(years: -1 * Int.random(in: 18...50))
        self.metadata = Metadata.random()
        self.contactMethod = ContactMethod.random()
    }
}

// _partition: "user={user_id}"
class DraftEmail: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var subject: String = ""
    @Persisted var body: String = ""
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    func randomize() {
        self.subject = Lorem.sentence
        self.body = Lorem.paragraphs(1...3)
    }
}

// _partition: "user={user_id}"
class DraftMessage: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var body: String = ""
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    func randomize() {
        self.body = Lorem.paragraphs(1...2)
    }
}

// _partition: "user={user_id}"
class DraftMail: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var title: String = ""
    @Persisted var dueDate: Date?
    @Persisted var body: String = ""
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    func randomize() {
        self.dueDate = Date().getPastOrFutureDate(day: Int.random(in: -100...100))
        self.title = Lorem.sentence
        self.body = Lorem.paragraphs(1...3)
    }
}

// _partition: "user={user_id}"
// OR
// _partition: "team={team_id}&user={user_id}"
class Appo: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var clientId: ObjectId
    @Persisted var startTime: Date
    @Persisted var endTime: Date
    @Persisted var type: String
    @Persisted var reminder: String
    @Persisted var estimateAmount: Double?
    @Persisted var notes: String?
    @Persisted var creator: String?
    
    var title: String {
        switch AppoType(rawValue: type) {
        case .online:
            return "Online appointment"
        case .atLocation:
            return "In-person appointment"
        case .voice:
            return "Phone appointment"
        case .other:
            return "Other appointment"
        default:
            return "Appointment"
        }
    }
    
    var reminderFireTime: Date? {
        guard let reminderChoice = ReminderChoices(rawValue: reminder) else {
            return nil
        }
        
        switch reminderChoice {
        case .exact:
            return startTime
        case .at15min:
            return startTime.getPastOrFutureDate(minute: -15)
        case .at30min:
            return startTime.getPastOrFutureDate(minute: -30)
        case .at1hour:
            return startTime.getPastOrFutureDate(hour: -1)
        default:
            return nil
        }
    }
    
    var needReminder: Bool {
        switch ReminderChoices(rawValue: reminder) {
        case .exact, .at15min, .at30min, .at1hour:
            return true
        default:
            return false
        }
    }
    
    convenience init(partition: String, client: Client, startTime: Date = Date(), endTime: Date = Date(), type: AppoType, reminder: ReminderChoices, estimateAmount: Double?, notes: String?, creator: String) {
        self.init()
        self._partition = partition
        self.clientId = client._id
        self.startTime = startTime
        self.endTime = endTime
        self.type = type.rawValue
        self.reminder = reminder.rawValue
        self.estimateAmount = estimateAmount
        self.notes = notes
        self.creator = creator
    }
}

// _partition: "user={user_id}"
// OR
// _partition: "team={team_id}&user={user_id}"
class TemplateEmail: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var name: String = ""
    @Persisted var subject: String = ""
    @Persisted var body: String = ""
    @Persisted var lastModified: Date = Date()
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
}

// _partition: "user={user_id}"
// OR
// _partition: "team={team_id}&user={user_id}"
class TemplateMessage: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var name: String = ""
    @Persisted var message: String = ""
    @Persisted var lastModified: Date = Date()
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
}

// _partition: "user={user_id}"
// OR
// _partition: "team={team_id}&user={user_id}"
class Mail: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var title: String = ""
    @Persisted var dueDate: Date?
    @Persisted var recipients: List<ObjectId> = List()
    @Persisted var body: String = ""
    @Persisted var creator: String?
    
    convenience init(partition: String, draftMail: DraftMail, creator: String) {
        self.init()
        self._partition = partition
        self.title = draftMail.title
        self.dueDate = draftMail.dueDate
        self.body = draftMail.body
        self.creator = creator
    }
}

// _partition: "user={user_id}"
class UserSettings: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var historyHashtags: List<String> = List()
    @Persisted var starredClients: MutableSet<ObjectId> = MutableSet()
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
    }
    
    func isClientStarred(client: Client) -> Bool {
        return starredClients.contains(client._id)
    }
}

// _partition: "team={team_id}"
class FollowUp: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String
    @Persisted var teamMemberId: String
    @Persisted var type: String
    @Persisted var associatedObjectId: ObjectId
    @Persisted var followUpDate: Date
    
    convenience init(partition: String, teamMemberId: String, type: FollowUpTypes, associatedObjectId: ObjectId) {
        self.init()
        self._partition = partition
        self.teamMemberId = teamMemberId
        self.type = type.rawValue
        self.associatedObjectId = associatedObjectId
        self.followUpDate = Date()
    }
}

// _partition: "team={team_id}"
class AppoSchedule: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var teamMemberId: String
    @Persisted var appoId: ObjectId
    @Persisted var startTime: Date
    
    convenience init(partition: String, teamMemberId: String, appoId: ObjectId, startTime: Date) {
        self.init()
        self._partition = partition
        self.teamMemberId = teamMemberId
        self.appoId = appoId
        self.startTime = startTime
    }
}

// _partition: "user={user_id}"
// OR
// _partition: "team={team_id}"
class Client: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var _partition: String = ""
    @Persisted var avatar: Data?
    @Persisted var civility: String?
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var address: Address?
    @Persisted var email: String?
    @Persisted var clientID: String = ""
    @Persisted var phone: Phone?
    @Persisted var birthday: Date?
    @Persisted var metadata: Metadata?
    @Persisted var contactMethod: ContactMethod?
    @Persisted var creator: String?
    // v3
    @Persisted var addedDate: Date?
    
    var statusEnum: CivilityStatus? {
        get {
            if let civility = civility {
                return CivilityStatus(rawValue: civility)
            }
            return nil
        }
        set {
            civility = newValue?.rawValue
        }
    }
    
    var initials: String {
        if let firstLetter = firstName.first, let secondLetter = lastName.first {
            return "\(firstLetter) \(secondLetter)".uppercased()
        } else if let firstLetter = firstName.first {
            return "\(firstLetter)".capitalized
        } else {
            return ""
        }
    }
    
    var fullName: String {
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var fullNameWithCivility: String {
        if let civility = statusEnum {
            return "\(civility.title()) \(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
        }
        
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var avatarImage: UIImage? {
        if let avatar = avatar {
            return UIImage(data: avatar)
        }
        return nil
    }
    
    var birthdayString: String? {
        if let birthday = birthday {
            return DateUtil.convert(input: birthday, outputFormat: .format5)
        }
        return nil
    }
    
    var prefix: Character {
        if firstName.hasChineseCharacter {
            let character = String(firstName.toPinyinAcronym().prefix(1).capitalized).first!
            return character
        } else {
            let character = String(firstName.prefix(1).capitalized).first!
            return character
        }
    }
    
    static func sections(clients: [Client]) -> [Character] {
        var sections: [Character] = clients.map { $0.prefix }
        sections = sections.removeDuplicates()
        sections = sections.sorted(by: <)
        return sections
    }
    
    static func sections(clients: Results<Client>) -> [Character] {
        var sections: [Character] = clients.map { $0.prefix }
        sections = sections.removeDuplicates()
        sections = sections.sorted(by: <)
        return sections
    }
    
    convenience init(partition: String) {
        self.init()
        self._partition = partition
        self.clientID = shortCodeGenerator(length: 10)
        self.metadata = Metadata()
        self.contactMethod = ContactMethod()
        self.address = Address()
        self.phone = Phone()
        self.addedDate = Date()
    }
    
    convenience init(partition: String, tempClient: TempClient) {
        self.init()
        self._partition = partition
        self.avatar = tempClient.avatar
        self.civility = tempClient.civility
        self.firstName = tempClient.firstName ?? ""
        self.lastName = tempClient.lastName ?? ""
        self.address = tempClient.address?.copy()
        self.email = tempClient.email
        self.clientID = shortCodeGenerator(length: 10)
        self.metadata = tempClient.metadata?.copy()
        self.contactMethod = tempClient.contactMethod?.copy()
        self.birthday = tempClient.birthday
        self.phone = tempClient.phone?.copy()
        self.addedDate = Date()
    }
}

class Address: EmbeddedObject {
    @Persisted var address: String?
    @Persisted var city: String = ""
    @Persisted var province: String = ""
    @Persisted var zipCode: String?
    @Persisted var country: String?
    @Persisted var countryCode: String?
    
    static func random() -> Address {
        let random = Address()
        random.address = "\(Int.random(in: 1...9999)) \(Lorem.words(2...5))"
        random.city = Lorem.words(1...2)
        random.province = Lorem.word
        random.zipCode = Lorem.word
        random.country = Lorem.word
        return random
    }
    
    func copy() -> Address {
        let new = Address()
        new.address = address
        new.city = city
        new.province = province
        new.zipCode = zipCode
        new.country = country
        return new
    }
    
    func fullAddress() -> String {
        return "\(address ?? "Unknown address"), \(city), \(province) \(zipCode ?? "")"
    }
}

class Phone: EmbeddedObject {
    @Persisted var area: String = ""
    @Persisted var phone: String = ""
    
    convenience init(area: String, phone: String) {
        self.init()
        self.area = area
        self.phone = phone
    }
    
    static func random() -> Phone {
        let random = Phone()
        random.area = "\(Int.random(in: 1...999))"
        random.phone = "\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))"
        return random
    }
    
    func copy() -> Phone {
        let new = Phone()
        new.area = area
        new.phone = phone
        return new
    }
    
    func getNumberString() -> String {
        return area + phone
    }
    
    func getFormattedString() -> String? {
        var string: String?
        if !area.isEmpty {
            string = area.addPlusSignToAreaCode()
        }
        
        if !phone.isEmpty {
            string = (string ?? "") + " " + phone
        }
        
        return string
    }
}

class Metadata: EmbeddedObject {
    @Persisted var notes: String?
    @Persisted var rating: Float?
    @Persisted var totalSpending: Double?
    @Persisted var hashtags: List<String> = List()
    
    convenience init(rating: Float = 0.0) {
        self.init()
        self.rating = rating
    }
    
    static func random() -> Metadata {
        let random = Metadata()
        random.notes = Lorem.paragraph
        random.rating = Float(Int.random(in: 0...5))
        random.totalSpending = Double.random(in: 0...1000000.0)
        for _ in 0...Int.random(in: 0...10) {
            random.hashtags.append(Lorem.words(1...2))
        }
        return random
    }
    
    func copy() -> Metadata {
        let new = Metadata()
        new.notes = notes
        new.rating = rating
        new.totalSpending = totalSpending
        new.hashtags = hashtags
        return new
    }
}

class ContactMethod: EmbeddedObject {
    @Persisted var byMail: Bool = false
    @Persisted var byPhone: Bool = false
    @Persisted var byEmail: Bool = false
    @Persisted var byMessage: Bool = false
    
    convenience init(byMail: Bool, byPhone: Bool, byEmail: Bool, byMessage: Bool) {
        self.init()
        self.byMail = byMail
        self.byPhone = byPhone
        self.byEmail = byEmail
        self.byMessage = byMessage
    }
    
    static func random() -> ContactMethod {
        let random = ContactMethod(byMail: Bool.random(), byPhone: Bool.random(), byEmail: Bool.random(), byMessage: Bool.random())
        return random
    }
    
    func copy() -> ContactMethod {
        let new = ContactMethod()
        new.byMail = byMail
        new.byPhone = byPhone
        new.byEmail = byEmail
        new.byMessage = byMessage
        return new
    }
}

extension SKCountryPicker.Country {
    var englishName: String {
        let locale = Locale(identifier: "en_US_POSIX")
        guard let localisedCountryName = locale.localizedString(forRegionCode: self.countryCode) else {
            let message = "Failed to localised country name for Country Code:- \(self.countryCode)"
            fatalError(message)
        }
        return localisedCountryName
    }
}
