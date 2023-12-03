//
//  FollowUpManager.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-17.
//

import Foundation
import RealmSwift

class FollowUpManager {
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
    
    func generateMissingAppoSchedules() {
        let appos = teamUserRealm.objects(Appo.self)
        guard !appos.isEmpty else {
            return
        }
        
        var new: [AppoSchedule] = []
        
        for appo in appos {
            if teamRealm.objects(AppoSchedule.self).filter("appoId == %@", appo._id).isEmpty {
                let newAppoSchedule = AppoSchedule(partition: UserManager.shared.teamPartitionKey,
                                                   teamMemberId: userId,
                                                   appoId: appo._id,
                                                   startTime: appo.startTime)
                new.append(newAppoSchedule)
            }
        }
        
        do {
            try teamRealm.write {
                teamRealm.add(new)
            }
        } catch(let error) {
            print("\(error.localizedDescription)")
        }
    }
    
    func generateMissingMailFollowUps() {
        let mails = teamUserRealm.objects(Mail.self)
        guard !mails.isEmpty else {
            return
        }
        
        for mail in mails {
            guard mail.dueDate != nil else { continue }
            
            if teamRealm.objects(FollowUp.self).filter("associatedObjectId == %@", mail._id).isEmpty {
                let newFollowUp = FollowUp(partition: UserManager.shared.teamPartitionKey,
                                           teamMemberId: userId,
                                           type: .mail,
                                           associatedObjectId: mail._id)
                do {
                    try teamRealm.write {
                        teamRealm.add(newFollowUp)
                    }
                } catch(let error) {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func recordFollowUp(mail: Mail) {
        guard let dueDate = mail.dueDate else { return }
        
        if let exist = teamRealm.objects(FollowUp.self).filter("associatedObjectId == %@", mail._id).first {
            do {
                try teamRealm.write {
                    exist.followUpDate = dueDate
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
        } else {
            let newFollowUp = FollowUp(partition: UserManager.shared.teamPartitionKey,
                                       teamMemberId: userId,
                                       type: .mail,
                                       associatedObjectId: mail._id)
            do {
                try teamRealm.write {
                    teamRealm.add(newFollowUp)
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func deleteFollowUp(mail: Mail) {
        if let exist = teamRealm.objects(FollowUp.self).filter("associatedObjectId == %@", mail._id).first {
            do {
                try teamRealm.write {
                    teamRealm.delete(exist)
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func recordFollowUp(with clients: [Client], type: FollowUpTypes) {
        var newFollowUps: [FollowUp] = []
        
        for client in clients {
            let newFollowUp = FollowUp(partition: UserManager.shared.teamPartitionKey,
                                       teamMemberId: userId,
                                       type: type,
                                       associatedObjectId: client._id)
            newFollowUps.append(newFollowUp)
        }
        
        do {
            try teamRealm.write {
                teamRealm.add(newFollowUps)
            }
        } catch(let error) {
            print("\(error.localizedDescription)")
        }
    }
    
    func generateGeneralFollowUpData(month: Date, members: [TeamMember]) -> [InsightsBarsDataModel] {
        // return array of InsightsBarsDataModel, each have 3 bars: appointment, follow up, client
        var data: [InsightsBarsDataModel] = []
        var maxCount: Int = 0
        for member in members {
            // appointment
            let appoSchedules = teamRealm.objects(AppoSchedule.self)
                .filter("teamMemberId == %@", member.userId)
                .filter("startTime BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            maxCount = max(maxCount, appoSchedules.count)
            let appoBarData = BarDataModel(name: InsightSelections.appointment.title(),
                                           color: InsightSelections.appointment.dotColor(),
                                           count: appoSchedules.count)
            
            // follow up
            let followUps = teamRealm.objects(FollowUp.self)
                .filter("teamMemberId == %@", member.userId)
                .filter("followUpDate BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            maxCount = max(maxCount, followUps.count)
            let followUpData = BarDataModel(name: InsightSelections.followUp.title(),
                                            color: InsightSelections.followUp.dotColor(),
                                            count: followUps.count)
            
            // client
            let clients = teamRealm.objects(Client.self)
                .filter("creator == %@", member.userId)
                .filter("addedDate BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            maxCount = max(maxCount, clients.count)
            let clientsData = BarDataModel(name: InsightSelections.client.title(),
                                           color: InsightSelections.client.dotColor(),
                                           count: clients.count)
            
            let new = InsightsBarsDataModel(teamMember: member, maxCount: 0, bars: [appoBarData, followUpData, clientsData])
            data.append(new)
        }
        for i in data.indices {
            data[i].maxCount = maxCount
        }
        return data
    }
    
    func generateAppoFollowUpData(month: Date, members: [TeamMember]) -> [InsightsBarsDataModel] {
        // return array of InsightsBarsDataModel, each have 1 bar: appointment
        var data: [InsightsBarsDataModel] = []
        var maxCount: Int = 0
        for member in members {
            // appointment
            let appoSchedules = teamRealm.objects(AppoSchedule.self)
                .filter("teamMemberId == %@", member.userId)
                .filter("startTime BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            maxCount = max(maxCount, appoSchedules.count)
            let appoBarData = BarDataModel(name: InsightSelections.appointment.title(),
                                           color: InsightSelections.appointment.dotColor(),
                                           count: appoSchedules.count)
            
            let new = InsightsBarsDataModel(teamMember: member, maxCount: 0, bars: [appoBarData])
            data.append(new)
        }
        for i in data.indices {
            data[i].maxCount = maxCount
        }
        return data
    }
    
    func generateFollowUpDetailsData(month: Date, members: [TeamMember]) -> [InsightsBarsDataModel] {
        // return array of InsightsBarsDataModel, each have 4 bars: email, phone, message, mail
        var data: [InsightsBarsDataModel] = []
        var maxCount: Int = 0
        for member in members {
            let followUps = teamRealm.objects(FollowUp.self)
                .filter("teamMemberId == %@", member.userId)
                .filter("followUpDate BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            
            // email
            let emailFollowups = followUps
                .filter("type == %@", FollowUpTypes.email.rawValue)
            maxCount = max(maxCount, emailFollowups.count)
            let emailFollowupsData = BarDataModel(name: FollowUpTypes.email.title(),
                                                  color: FollowUpTypes.email.dotColor(),
                                                  count: emailFollowups.count)
            
            // phone
            let phoneFollowups = followUps
                .filter("type == %@", FollowUpTypes.phone.rawValue)
            maxCount = max(maxCount, phoneFollowups.count)
            let phoneFollowupsData = BarDataModel(name: FollowUpTypes.phone.title(),
                                                  color: FollowUpTypes.phone.dotColor(),
                                                  count: phoneFollowups.count)
            
            // message
            let messageFollowups = followUps
                .filter("type == %@", FollowUpTypes.message.rawValue)
            maxCount = max(maxCount, messageFollowups.count)
            let messageFollowupsData = BarDataModel(name: FollowUpTypes.message.title(),
                                                    color: FollowUpTypes.message.dotColor(),
                                                    count: messageFollowups.count)
            
            // mail
            let mailFollowups = followUps
                .filter("type == %@", FollowUpTypes.mail.rawValue)
            maxCount = max(maxCount, mailFollowups.count)
            let mailFollowupsData = BarDataModel(name: FollowUpTypes.mail.title(),
                                                 color: FollowUpTypes.mail.dotColor(),
                                                 count: mailFollowups.count)
            
            let new = InsightsBarsDataModel(teamMember: member, maxCount: 0, bars: [emailFollowupsData, phoneFollowupsData, messageFollowupsData, mailFollowupsData])
            data.append(new)
        }
        for i in data.indices {
            data[i].maxCount = maxCount
        }
        return data
    }
    
    func generateClientFollowUpData(month: Date, members: [TeamMember]) -> [InsightsBarsDataModel] {
        // return array of InsightsBarsDataModel, each have 1 bar client
        var data: [InsightsBarsDataModel] = []
        var maxCount: Int = 0
        for member in members {
            // client
            let clients = teamRealm.objects(Client.self)
                .filter("creator == %@", member.userId)
                .filter("addedDate BETWEEN {%@, %@}", month.startOfMonth(), month.endOfMonth())
            maxCount = max(maxCount, clients.count)
            let clientsData = BarDataModel(name: InsightSelections.client.title(),
                                           color: InsightSelections.client.dotColor(),
                                           count: clients.count)
            
            let new = InsightsBarsDataModel(teamMember: member, maxCount: 0, bars: [clientsData])
            data.append(new)
        }
        for i in data.indices {
            data[i].maxCount = maxCount
        }
        return data
    }
}
