//
//  AppDelegate.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit
import RealmSwift
import GooglePlaces

var app: App!
var googlePlacesApiKey: String!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let env = AppSettingsManager.shared.getEnvironment()
        app = App(id: env.appId())
        googlePlacesApiKey = env.googleApiKey()
        GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
        
        if UITraitCollection.current.userInterfaceStyle == .dark {
            ThemeManager.shared.setDarkTheme()
        } else {
            ThemeManager.shared.setLightTheme()
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

