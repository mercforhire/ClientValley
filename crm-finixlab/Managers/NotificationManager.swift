//
//  NotificationManager.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-29.
//

import Foundation
import UserNotifications
import RealmSwift

class NotificationManager {
    static let shared = NotificationManager()
    var settings: UNNotificationSettings?
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
                DispatchQueue.main.async {
                    self.fetchNotificationSettings()
                    completion(granted)
                }
            }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func createTestNotication() {
        let content = UNMutableNotificationContent()
        content.title = "TEST"
        content.body = "TEST TEST TEST TEST TEST "
        content.categoryIdentifier = "TestCategory"
        content.badge = 1
        
        let trigger: UNNotificationTrigger =
            UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date().getPastOrFutureDate(minute: 1)), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test notification",
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func removeMailingNotification(mail: Mail) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [mail._id.stringValue])
    }
    
    func scheduleMailingNotification(mail: Mail, overrideDate: Date? = nil, overridePrevious: Bool = false, completion: @escaping (Bool) -> Void) {
        var completed: Bool = false
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            if !overridePrevious {
                // check if this mail is already in the notification queue
                UNUserNotificationCenter.current().getPendingNotificationRequests { pendings in
                    DispatchQueue.main.async {
                        for noti in pendings {
                            if noti.identifier == mail._id.stringValue {
                                // already exist
                                print("NotificationManager: Mail \(mail.title) already have a pending notification: \(mail._id.stringValue)")
                                completed = true
                                completion(true)
                                break
                            }
                        }
                        semaphore.signal()
                    }
                }
                semaphore.wait()
                
                if completed {
                    return
                }
            }
            
            DispatchQueue.main.async {
                // create new notification
                let content = UNMutableNotificationContent()
                content.title = "Upcoming Mail"
                content.body = "Just a reminder, mail “\(mail.title)” is scheduled sending today."
                content.categoryIdentifier = "MailReminderCategory"
                content.userInfo = ["type": "mail", "mailId" : mail._id.stringValue]
                content.sound = .default
                content.badge = 1
                
                guard let date = overrideDate ?? mail.dueDate?.startOfDay().getPastOrFutureDate(hour: 9), date > Date() else {
                    print("NotificationManager: Mail \(mail.title) already past due.")
                    completion(false)
                    return
                }
                
                let trigger: UNNotificationTrigger =
                    UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date), repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: mail._id.stringValue,
                    content: content,
                    trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("NotificationManager: Create notification for mail \(mail.title) error: \(error)")
                            completion(false)
                        } else {
                            print("NotificationManager: Created notification for mail \(mail.title) at \(DateUtil.convert(input: date, outputFormat: .format1) ?? "")")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    // schedule for multiple mails
    func scheduleMailingNotification(mails: [Mail]) {
        for mail in mails {
            scheduleMailingNotification(mail: mail, completion: { success in
            })
        }
    }
    
    func removeAppoNotification(appo: Appo) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [appo._id.stringValue])
    }
    
    func scheduleAppoNotification(appo: Appo, client: Client, overrideDate: Date? = nil, overridePrevious: Bool = false, completion: @escaping (Bool) -> Void) {
        var completed: Bool = false
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            if !overridePrevious {
                // check if this mail is already in the notification queue
                UNUserNotificationCenter.current().getPendingNotificationRequests { pendings in
                    DispatchQueue.main.async {
                        for noti in pendings {
                            if noti.identifier == appo._id.stringValue {
                                // already exist
                                print("NotificationManager: Appo with \(client.firstName) already have a pending notification: \(appo._id.stringValue)")
                                completed = true
                                completion(true)
                                break
                            }
                        }
                        semaphore.signal()
                    }
                }
                semaphore.wait()
                
                if completed {
                    return
                }
            }
            
            DispatchQueue.main.async {
                // create new notification
                let content = UNMutableNotificationContent()
                content.title = "Upcoming Appointment"
                content.body = "Your appointment with \(client.fullName) starts in \(ReminderChoices(rawValue: appo.reminder)?.timeRemaining() ?? "")."
                content.categoryIdentifier = "AppoReminderCategory"
                content.userInfo = ["type": "apo", "appoId" : appo._id.stringValue]
                content.sound = .default
                content.badge = 1
                
                guard let date = overrideDate ?? appo.reminderFireTime, date > Date() else {
                    print("NotificationManager: Appo reminder time invalid.")
                    completion(false)
                    return
                }
                
                let trigger: UNNotificationTrigger =
                    UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date), repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: appo._id.stringValue,
                    content: content,
                    trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("NotificationManager: Create notification for appo with \(client.firstName) error: \(error)")
                            completion(false)
                        } else {
                            print("NotificationManager: Created notification for appo with \(client.firstName) at \(DateUtil.convert(input: date, outputFormat: .format1) ?? "")")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    // schedule for multiple Appo
    func scheduleAppoNotification(appos: [Appo], realm: Realm) {
        for appo in appos where appo.needReminder {
            if let client = realm.objects(Client.self).filter("_id == %@", appo.clientId).first {
                scheduleAppoNotification(appo: appo, client: client, completion: { success in
                })
            }
        }
    }
    
    func removeNotificationsFor(client: Client, realm: Realm) {
        let mailsToModify = realm.objects(Mail.self).filter { subject in
            return subject.recipients.contains(client._id)
        }
        for mail in mailsToModify {
            if let index = mail.recipients.index(of: client._id) {
                do {
                    try realm.write {
                        mail.recipients.remove(at: index)
                    }
                } catch(let error) {
                    print("NotificationManager: \(error.localizedDescription)")
                }
                
                if mail.recipients.isEmpty {
                    removeMailingNotification(mail: mail)
                    do {
                        try realm.write {
                            realm.delete(mail)
                        }
                    } catch(let error) {
                        print("NotificationManager: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        let apposToUnschedule = realm.objects(Appo.self).filter("clientId == %@", client._id)
        for appo in apposToUnschedule {
            removeAppoNotification(appo: appo)
        }
    }
        
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
