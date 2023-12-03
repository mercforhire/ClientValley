//
//  UserManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-27.
//

import Foundation
import RealmSwift
import GooglePlaces

class UserManager {
    static let shared = UserManager()
    let publicPartitionKey: String = "PUBLIC"
    
    private(set) var userRealmConfig: Realm.Configuration?
    private(set) var teamRealmConfig: Realm.Configuration?
    private(set) var teamUserRealmConfig: Realm.Configuration?
    private(set) var publicRealmConfig: Realm.Configuration?
    
    var accountData: [AnyHashable: Any]?
    var myTeams: [Team] = []
    private(set) var currentTeam: Team? {
        didSet {
            guard let user = app.currentUser else { return }
            
            if currentTeam != nil {
                teamRealmConfig = user.configuration(partitionValue: teamPartitionKey)
                teamUserRealmConfig = user.configuration(partitionValue: teamAndUserPartitionKey)
            } else {
                teamRealmConfig = nil
                teamUserRealmConfig = nil
            }
        }
    }
    private(set) var userData: UserData? {
        didSet {
            guard let userData = userData else { return }
            
            if let currentTeamId = userData.currentTeam {
                currentTeam = myTeams.first(where: { subject in
                    return subject._id == currentTeamId
                })
            } else {
                currentTeam = nil
            }
        }
    }
    
    var userPartitionKey: String {
        guard let user = app.currentUser else { return "" }
        
        return "user=\(user.id)"
    }
    
    var teamPartitionKey: String {
        if let team = UserManager.shared.currentTeam {
            return "team=\(team._id.stringValue)"
        }
        
        return userPartitionKey
    }
    
    var teamAndUserPartitionKey: String {
        if let _ = UserManager.shared.currentTeam {
            return "\(teamPartitionKey)&\(userPartitionKey)"
        }
        
        return userPartitionKey
    }
    
    private var teamInvitationNotification: NotificationToken?
    private var processedInvitations: [ObjectId] = []
    
    var email: String? {
        guard let userData = accountData else { return nil }
        
        return userData["name"] as? String
    }
    
    func refreshAccountData(realm: Realm, completion: @escaping (Bool) -> Void) {
        guard let user = app.currentUser else { return }
        
        let queue = DispatchQueue.global(qos: .default)
        var isSuccess: Bool = true
        var teams: [Team] = []
        
        queue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Refresh the custom user data
            user.refreshCustomData(completion: { result, error in
                if let error = error {
                    print("Failed to refresh custom data: \(error.localizedDescription)")
                    isSuccess = false
                } else if let result = result {
                    self.accountData = result
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            user.functions.getMyJoinedTeams([], { data, err in
                if let err = err {
                    print("getMyJoinedTeams error: \(err.localizedDescription)")
                    isSuccess = false
                } else if let data = data {
                    if let teamsBSON = data.arrayValue {
                        for teamBSON in teamsBSON {
                            guard let document = teamBSON?.documentValue else { continue }
                            
                            let team: Team = Team(document: document)
                            teams.append(team)
                        }
                    }
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            user.functions.initTeamMember([], { _,err in
                if let err = err {
                    print("initTeamMember error: \(err.localizedDescription)")
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.myTeams = teams
                
                if realm.objects(UserData.self).isEmpty {
                    let userData = UserData(partition: self.userPartitionKey)
                    do {
                        try realm.write {
                            realm.add(userData)
                        }
                    } catch(let error) {
                        print("setupRealm \(error.localizedDescription)")
                    }
                    self.userData = userData
                } else {
                    self.userData = realm.objects(UserData.self).first
                }
                
                completion(isSuccess)
            }
        }
    }
    
    private var verifyFlow: (() -> Void)?
    private var completion: ((Bool) -> Void)?
    
    func isLoggedIn(verifyFlow: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        self.verifyFlow = verifyFlow
        self.completion = completion
        
        if let user = app.currentUser, user.isLoggedIn {
            FullScreenSpinner().show()
            userRealmConfig = user.configuration(partitionValue: userPartitionKey)
            userRealmConfig?.schemaVersion = 3
            userRealmConfig?.migrationBlock = { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Appo.className()) { oldObject, newObject in
                        newObject!["creator"] = user.id
                    }
                    migration.enumerateObjects(ofType: Client.className()) { oldObject, newObject in
                        newObject!["creator"] = user.id
                    }
                    migration.enumerateObjects(ofType: Mail.className()) { oldObject, newObject in
                        newObject!["creator"] = user.id
                    }
                    migration.enumerateObjects(ofType: UserData.className()) { oldObject, newObject in
                        newObject!["joinTeams"] = AnyBSON.array([])
                    }
                }
            }
            self.publicRealmConfig = user.configuration(partitionValue: publicPartitionKey)
            
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = userRealmConfig!
            app.syncManager.errorHandler = { (error, session)  in
                 // Perform error handling
                print("syncManager error:\(error)")
            }
            Realm.asyncOpen(configuration: self.userRealmConfig!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        FullScreenSpinner().hide()
                        showErrorDialog(error: "Failed to open Realm database(\(error)), please login again")
                        _ = try? Realm.deleteFiles(for: self.userRealmConfig!)
                        _ = user.logOut()
                    case .success(let realm):
                        // Go to the list of projects in the user object contained in the user realm.
                        self.refreshAccountData(realm: realm) { success in
                            if success {
                                if AppSettingsManager.shared.getEmailVerified() {
                                    completion(true)
                                } else {
                                    user.functions.isUserVerified([], self.onIsUserVerifiedComplete)
                                }
                            } else {
                                showErrorDialog(error: "Failed to load account data")
                                completion(false)
                            }
                            
                            FullScreenSpinner().hide()
                        }
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    func login(email: String, password: String, verifyFlow: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        guard let topVC = UIViewController.topViewController else { return }
        
        self.verifyFlow = verifyFlow
        self.completion = completion
        FullScreenSpinner().show()
        app.login(credentials: Credentials.emailPassword(email: email, password: password)) { [weak self] result in
            guard let self = self else { return }
            
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.async ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    FullScreenSpinner().hide()
                    // Auth error: user already exists? Try logging in as that user.
                    print("Login failed: \(error)")
                    let dialog = Dialog()
                    let config = DialogConfig(title: "Login failed", body: "\(error.localizedDescription)", secondary: nil, primary: "Dismiss")
                    dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
                    dialog.show(inView: topVC.view, withDelay: 100)
                    completion(false)
                    return
                case .success(let user):
                    print("Login succeeded!")
        
                    // Load again while we open the realm.
                    // Get a configuration to open the synced realm.
                    self.userRealmConfig = user.configuration(partitionValue: self.userPartitionKey)
                    self.userRealmConfig?.schemaVersion = 3
                    self.userRealmConfig?.migrationBlock = { migration, oldSchemaVersion in
                        if oldSchemaVersion < 2 {
                            migration.enumerateObjects(ofType: Appo.className()) { oldObject, newObject in
                                newObject!["creator"] = user.id
                            }
                            migration.enumerateObjects(ofType: Client.className()) { oldObject, newObject in
                                newObject!["creator"] = user.id
                            }
                            migration.enumerateObjects(ofType: Mail.className()) { oldObject, newObject in
                                newObject!["creator"] = user.id
                            }
                            migration.enumerateObjects(ofType: UserData.className()) { oldObject, newObject in
                                newObject!["joinTeams"] = AnyBSON.array([])
                            }
                        }
                    }
                    self.publicRealmConfig = user.configuration(partitionValue: self.publicPartitionKey)                    
                    // Tell Realm to use this new configuration object for the default Realm
                    Realm.Configuration.defaultConfiguration = self.userRealmConfig!
                    
                    // Open the realm asynchronously so that it downloads the remote copy before
                    // opening the local copy.
                    app.syncManager.errorHandler = { (error, session)  in
                         // Perform error handling
                        print("syncManager error:\(error)")
                    }
                    Realm.asyncOpen(configuration: self.userRealmConfig!) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(let error):
                                FullScreenSpinner().hide()
                                showErrorDialog(error: "Failed to open Realm database(\(error)), please login again")
                                _ = try? Realm.deleteFiles(for: self.userRealmConfig!)
                            case .success(let realm):
                                // Go to the list of projects in the user object contained in the user realm.
                                self.refreshAccountData(realm: realm) { success in
                                    if success {
                                        if AppSettingsManager.shared.getEmailVerified() {
                                            completion(true)
                                        } else {
                                            user.functions.isUserVerified([], self.onIsUserVerifiedComplete)
                                        }
                                    } else {
                                        showErrorDialog(error: "Failed to load account data")
                                        completion(false)
                                    }
                                    
                                    FullScreenSpinner().hide()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func onIsUserVerifiedComplete(result: AnyBSON?, realmError: Error?) {
        DispatchQueue.main.async { [weak self] in
            // Always be sure to stop the activity indicator
            FullScreenSpinner().hide()

            // There are two kinds of errors:
            // - The Realm function call itself failed (for example, due to network error)
            // - The Realm function call succeeded, but our business logic within the function returned an error,
            //   (for example, user is not a member of the team).
            var errorMessage: String?

            if realmError != nil {
                // Error from Realm (failed function call, network error...)
                errorMessage = realmError!.localizedDescription
            } else if let resultDocument = result?.documentValue {
                // Check for user error. The addTeamMember function we defined returns an object
                // with the `error` field set if there was a user error.
                errorMessage = resultDocument["error"]??.stringValue
            }

            // Present error message if any
            guard errorMessage == nil else {
                showErrorDialog(error: "Resend email failed: \(errorMessage!)")
                return
            }
            
            if result?.boolValue == true {
                AppSettingsManager.shared.setEmailVerified(verified: true)
                self?.completion?(true)
            } else {
                self?.verifyFlow?()
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let topVC = UIViewController.topViewController else { return }
        
        FullScreenSpinner().show()
        app.emailPasswordAuth.registerUser(email: email, password: password, completion: { error in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.async ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                guard error == nil else {
                    print("Signup failed: \(error!)")
                    let dialog = Dialog()
                    let config = DialogConfig(title: "Sign up failed", body: "\(error!.localizedDescription)", secondary: nil, primary: "Dismiss")
                    dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
                    dialog.show(inView: topVC.view, withDelay: 100)
                    completion(false)
                    return
                }
                print("Signup successful!")
    
                // Registering just registers. Now we need to sign in, but we can reuse the existing email and password.
                completion(true)
            }
        })
    }
    
    func logOut(completion: @escaping () -> Void) {
        NotificationManager.shared.removeAllNotifications()
        app.currentUser?.logOut { (_) in
            DispatchQueue.main.async {
                print("Logged out!")
                AppSettingsManager.shared.resetSettings()
                self.userRealmConfig = nil
                self.teamRealmConfig = nil
                self.teamUserRealmConfig = nil
                self.publicRealmConfig = nil
                self.accountData = nil
                self.teamInvitationNotification?.invalidate()
                self.teamInvitationNotification = nil
                self.myTeams.removeAll()
                self.processedInvitations.removeAll()
                completion()
            }
        }
    }
    
    var handlingInvitation = false
    
    func startMonitoringTeamInvitation() {
        guard let realmConfiguration = userRealmConfig, let realm = try? Realm(configuration: realmConfiguration) else { return }

        teamInvitationNotification = realm.objects(TeamInvitation.self).observe({ [weak self] changes in
            switch changes {
            case .initial(let results):
                if let invitation = results.first {
                    self?.processInvitation(invitation: invitation)
                }
            case .update(let invitations, _: _, let insertions, _):
                if !insertions.isEmpty {
                    if let invitation = invitations.first {
                        self?.processInvitation(invitation: invitation)
                    }
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        })
    }
    
    func checkForInvitations() {
        guard !handlingInvitation,
              let realmConfiguration = userRealmConfig,
              let realm = try? Realm(configuration: realmConfiguration) else { return }
        
        let invitations = realm.objects(TeamInvitation.self)
        if let invitation = invitations.first {
            processInvitation(invitation: invitation)
        }
    }
    
    func processInvitation(invitation: TeamInvitation) {
        guard !handlingInvitation, !processedInvitations.contains(invitation._id) else { return }
        
        NotificationCenter.default.post(name: Notifications.TeamInvitationArrived, object: nil)
    }
    
    func sendTeamInvitation(email: String, team: Team, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.sendTeamInvitation([AnyBSON(email), AnyBSON(team._id.stringValue)], { data, err in
            if let err = err, err.localizedDescription != "mongo: no documents in result" {
                print("sendTeamInvitation error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else {
                print("sendTeamInvitation result: \(data?.stringValue ?? "")")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
    }
    
    func acceptTeamInvitation(invitation: TeamInvitation, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.acceptTeamInvitation([AnyBSON(invitation._id.stringValue)], { data, err in
            if let err = err {
                print("acceptTeamInvitation error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                    self.handlingInvitation = false
                }
            } else if let data = data {
                print("acceptTeamInvitation result: \(data)")
                DispatchQueue.main.async {
                    self.handlingInvitation = false
                    self.processedInvitations.append(invitation._id)
                    self.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func declineTeamInvitation(invitation: TeamInvitation, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.declineTeamInvitation([AnyBSON(invitation._id.stringValue)], { data, err in
            if let err = err {
                print("declineTeamInvitation error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                    self.handlingInvitation = false
                }
            } else if let data = data {
                print("declineTeamInvitation result: \(data)")
                DispatchQueue.main.async {
                    self.handlingInvitation = false
                    self.processedInvitations.append(invitation._id)
                    self.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func ignoreTeamInvitation() {
        handlingInvitation = false
    }
    
    func deleteInvitation(invitation: TeamInvitation) {
        guard let realmConfiguration = userRealmConfig,
              let realm = try? Realm(configuration: realmConfiguration) else { return }

        do {
            try realm.write {
                realm.delete(invitation)
            }
        } catch(let error) {
            print("deleteInvitation: \(error.localizedDescription)")
        }
    }
    
    func changeTeam(team: Team?) {
        guard let realmConfiguration = userRealmConfig,
              let realm = try? Realm(configuration: realmConfiguration),
              let userData = userData
        else { return }
        
        do {
            try realm.write {
                userData.currentTeam = team?._id
            }
            currentTeam = team
        } catch(let error) {
            print("changeTeam: \(error.localizedDescription)")
        }
        
        NotificationCenter.default.post(name: Notifications.TeamChanged, object: nil)
    }
    
    func deleteTeam(team: Team, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.deleteTeam([AnyBSON(team._id.stringValue)], { [weak self] data, err in
            if let err = err {
                print("deleteTeam error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("deleteTeam result: \(data)")
                DispatchQueue.main.async {
                    self?.changeTeam(team: nil)
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func newTeam(teamName: String, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.createNewTeam([AnyBSON(teamName)], { [weak self] data, err in
            if let err = err {
                print("createNewTeam error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("createNewTeam result: \(data)")
                DispatchQueue.main.async {
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func leaveTeam(team: Team, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.leaveTeam([AnyBSON(team._id.stringValue)], { [weak self] data, err in
            if let err = err {
                print("leaveTeam error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("leaveTeam result: \(data)")
                DispatchQueue.main.async {
                    self?.changeTeam(team: nil)
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func refreshTeams(completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        var teams: [Team] = []
        user.functions.getMyJoinedTeams([], { data, err in
            if let err = err {
                print("getMyJoinedTeams error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                if let teamsBSON = data.arrayValue {
                    for teamBSON in teamsBSON {
                        guard let document = teamBSON?.documentValue else { continue }
                        
                        let team: Team = Team(document: document)
                        teams.append(team)
                    }
                    self.myTeams = teams
                }
                if self.currentTeam != nil {
                    self.currentTeam = teams.first(where: { subject in
                        return subject._id == self.currentTeam?._id
                    })
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
    }
    
    func promoteTeamMember(team: Team, memberUserId: String, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.promoteTeamMember([AnyBSON(team._id.stringValue), AnyBSON(memberUserId)], { [weak self] data, err in
            if let err = err {
                print("promoteTeamMember error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("promoteTeamMember result: \(data)")
                DispatchQueue.main.async {
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func demoteTeamManager(team: Team, memberUserId: String, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.demoteTeamManager([AnyBSON(team._id.stringValue), AnyBSON(memberUserId)], { [weak self] data, err in
            if let err = err {
                print("demoteTeamManager error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("demoteTeamManager result: \(data)")
                DispatchQueue.main.async {
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
    
    func removeTeamMember(team: Team, memberUserId: String, completion: @escaping (Error?) -> Void) {
        guard let user = app.currentUser else { return }
        
        user.functions.removeTeamMember([AnyBSON(team._id.stringValue), AnyBSON(memberUserId)], { [weak self] data, err in
            if let err = err {
                print("demoteTeamManager error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(err)
                }
            } else if let data = data {
                print("demoteTeamManager result: \(data)")
                DispatchQueue.main.async {
                    self?.refreshTeams(completion: completion)
                }
            }
        })
    }
}
