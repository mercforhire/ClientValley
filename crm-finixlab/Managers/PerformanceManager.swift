//
//  PerformanceManager.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-21.
//

import Foundation
import RealmSwift

class PerformanceManager {
    let teamRealm: Realm
    let teamUserRealm: Realm
    
    var userId: String {
        guard let user = app.currentUser else { return "" }
        
        return user.id
    }
    
    init(teamRealm: Realm, teamUserRealm: Realm) {
        self.teamRealm = teamRealm
        self.teamUserRealm = teamUserRealm
    }
    
    var myTotalClients: Results<Client>!
    var teamTotalClients: Results<Client>!
    
    var myNewClientsMonthCount: Int!
    var teamNewClientsMonthCount: Int!
    
    var myNewClientsQuarterCount: Int!
    var teamNewClientsQuarterCount: Int!
    
    var myNewClientsYearCount: Int!
    var teamNewClientsYearCount: Int!
    
    var myEmailsCount: Int!
    var teamEmailsCount: Int!
    
    var myNumbersCount: Int!
    var teamNumbersCount: Int!
    
    var myAddressCount: Int!
    var teamAddressCount: Int!
    
    var myTotalAppos: Int!
    var teamTotalAppos: Int!
    
    var myThisMonthAppos: Int!
    var teamThisMonthAppos: Int!
    
    var myOverallClientsRating: Double!
    
    var myUpcomingBirthdays: [Client]!
    
    var myClientExpenses: Double!
    
    var clientsAndAppos: [(Client, [Appo])]!
    
    func calculate() {
        myTotalClients = teamRealm.objects(Client.self).filter("creator == %@", userId)
        teamTotalClients = teamRealm.objects(Client.self)
        
        let myNewClientsMonth = myTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        myNewClientsMonthCount = myNewClientsMonth.count
        
        let teamNewClientsMonth = teamTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        teamNewClientsMonthCount = teamNewClientsMonth.count
        
        let myNewClientsQuarter = myTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfQuarter(), Date().endOfQuarter())
        myNewClientsQuarterCount = myNewClientsQuarter.count
        
        let teamNewClientsQuarter = teamTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfQuarter(), Date().endOfQuarter())
        teamNewClientsQuarterCount = teamNewClientsQuarter.count
        
        let myNewClientsYear = myTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfYear(), Date().endOfYear())
        myNewClientsYearCount = myNewClientsYear.count
        
        let teamNewClientsYear = teamTotalClients.filter("addedDate BETWEEN {%@, %@}", Date().startOfYear(), Date().endOfYear())
        teamNewClientsYearCount = teamNewClientsYear.count
        
        let myClientsWithEmail = myTotalClients.filter("email != %@", "")
        myEmailsCount = myClientsWithEmail.count
        
        let teamClientsWithEmail = teamTotalClients.filter("email != %@", "")
        teamEmailsCount = teamClientsWithEmail.count
        
        let myClientsWithPhone = myTotalClients.filter("phone.phone != %@", "")
        myNumbersCount = myClientsWithPhone.count
        
        let teamClientsWithPhone = teamTotalClients.filter("phone.phone != %@", "")
        teamNumbersCount = teamClientsWithPhone.count
        
        let myClientsWithAddress = myTotalClients.filter("address.address != %@", "")
        myAddressCount = myClientsWithAddress.count
        
        let teamClientsWithAddress = teamTotalClients.filter("address.address != %@", "")
        teamAddressCount = teamClientsWithAddress.count
        
        let myAppos = teamRealm.objects(AppoSchedule.self).filter("teamMemberId == %@", userId)
        myTotalAppos = myAppos.count
        
        let teamAppos = teamRealm.objects(AppoSchedule.self)
        teamTotalAppos =  teamAppos.count
    
        let myApposMonth = myAppos.filter("startTime BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        myThisMonthAppos = myApposMonth.count
        
        let teamApposMonth = teamAppos.filter("startTime BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        teamThisMonthAppos = teamApposMonth.count
        
        var count = 0
        var sum: Double = 0.0
        for client in myTotalClients {
            if client.metadata?.rating ?? 0 > 0 {
                count = count + 1
                sum = sum + Double((client.metadata?.rating ?? 0.0))
            }
        }
        myOverallClientsRating = count == 0 ? 0.0 : sum / Double(count)
        
        myUpcomingBirthdays = myTotalClients.filter { client in
            if let birthday = client.birthday {
                return Date().daysUntil(birthday: birthday) <= 30
            }
            return false
        }
        myUpcomingBirthdays.sort { left, right in
            guard left.birthday != nil, right.birthday != nil else { return true }
            
            return left.birthday! < right.birthday!
        }
        
        myClientExpenses = 0.0
        for client in myTotalClients {
            if let totalSpending = client.metadata?.totalSpending {
                myClientExpenses = myClientExpenses + totalSpending
            }
        }
        
        clientsAndAppos = []
        
        let myAppointments = teamUserRealm.objects(Appo.self)
        for appo in myAppointments {
            myClientExpenses = myClientExpenses + Double(appo.estimateAmount ?? 0.0)
            
            guard let client = myTotalClients.filter("_id == %@", appo.clientId).first else { continue }
            
            if let index = clientsAndAppos.firstIndex(where: { tuple in
                return tuple.0._id == client._id
            }) {
                clientsAndAppos[index].1.append(appo)
            } else {
                clientsAndAppos.append((client,[appo]))
            }
        }
        
        clientsAndAppos.sort { left, right in
            return left.1.count > right.1.count
        }
    }
}
