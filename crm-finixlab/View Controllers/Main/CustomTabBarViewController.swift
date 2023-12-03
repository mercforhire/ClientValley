//
//  CustomTabBarViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-27.
//

import UIKit
import RealmSwift

class CustomTabBarViewController: UITabBarController {
    enum Tabs: Int {
        case client
        case followUp
        case appo
        case performance
        case profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.viewControllers = [self]
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(switchToFollowUp),
                                               name: Notifications.SwitchToFollowUp,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTeamInvitation),
                                               name: Notifications.TeamInvitationArrived,
                                               object: nil)
        setupRealm()
        UserManager.shared.startMonitoringTeamInvitation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func switchToFollowUp(_ notification: Notification) {
        if selectedIndex != Tabs.followUp.rawValue {
            selectedIndex = Tabs.followUp.rawValue
        }
    }
    
    @objc func handleTeamInvitation(_ notification: Notification) {
        if selectedIndex != Tabs.profile.rawValue {
            selectedIndex = Tabs.profile.rawValue
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: Notifications.TeamInvitationArrived, object: nil)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            handleRefreshForTabBar()
        }
    }
    
    func handleRefreshForTabBar() {
        DispatchQueue.main.async {
            guard let themeData = ThemeManager.shared.themeData else { return }
            
            self.tabBar.barStyle = ThemeManager.shared.barStyle
            
            if #available(iOS 15.0, *) {
                let tabAppearance = UITabBarAppearance()
                tabAppearance.configureWithOpaqueBackground()
                tabAppearance.backgroundColor = UIColor.fromRGBString(rgbString: themeData.viewColor)
                tabAppearance.selectionIndicatorTintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.selectedColor)
                ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.compactInlineLayoutAppearance)
                ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.inlineLayoutAppearance)
                ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.stackedLayoutAppearance)
                self.tabBar.standardAppearance = tabAppearance
                self.tabBar.scrollEdgeAppearance = tabAppearance
            } else {
                self.tabBar.tintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.selectedColor)
                self.tabBar.barTintColor = UIColor.fromRGBString(rgbString: themeData.viewColor)
                self.tabBar.unselectedItemTintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.unSelectedColor)
            }
        }
    }
    
    private func setupRealm() {
        guard let realmConfiguration = UserManager.shared.teamUserRealmConfig ?? UserManager.shared.userRealmConfig else {
            fatalError()
        }
        
        let realm = try! Realm(configuration: realmConfiguration)
        let upcomingMails = Array(realm.objects(Mail.self).filter("dueDate >= %@", Date()))
        let upcomingAppos = Array(realm.objects(Appo.self).filter("startTime >= %@", Date()))
        
        NotificationManager.shared.requestAuthorization { granted in
            if !granted {
                showErrorDialog(error: "Notification not enabled, unable to set upcoming mailing reminders!")
            } else {
                if !upcomingMails.isEmpty {
                    print("\(upcomingMails.count) upcoming mails found!")
                    NotificationManager.shared.scheduleMailingNotification(mails: upcomingMails)
                }
                
                if !upcomingAppos.isEmpty {
                    print("\(upcomingAppos.count) upcoming appointments found!")
                    NotificationManager.shared.scheduleAppoNotification(appos: upcomingAppos, realm: realm)
                }
            }
        }
    }
}
