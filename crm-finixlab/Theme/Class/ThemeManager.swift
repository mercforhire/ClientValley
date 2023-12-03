//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import Foundation
import UIKit

public class ThemeManager {
    public static let shared = ThemeManager()
    
    struct Notifications {
        static let ModeChanged = Notification.Name("ModeChanged")
        static let ThemeChanged = Notification.Name("ThemeChanged")
    }
    
    private(set) var theme: Theme {
        didSet {
            switch theme {
            case .light:
                theme = .light
                themeData = ThemeData(dict: loadPlist(plist: "light-theme")!)
            case .dark:
                theme = .dark
                themeData = ThemeData(dict: loadPlist(plist: "dark-theme")!)
            }
            apply()
        }
    }
    
    var themeData: ThemeData?
    

    //MARK: - Public methods to set Theme
    
    public func setLightTheme() {
        theme = .light
    }
    
    public func setDarkTheme() {
        theme = .dark
    }
    
    
    public var statusBarStyle: UIStatusBarStyle {
        switch theme {
        case .dark:
            return .lightContent
        case .light:
            return .default
        }
    }
    
    //MARK: - Theme Application Methods
    
    var barStyle: UIBarStyle {
        switch theme {
        case .light:
            return .default
        case .dark:
            return .black
        }
    }
    
    init() {
        theme = .light
        themeData = ThemeData(dict: loadPlist(plist: "light-theme")!)
        apply()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleModeChanged),
                                               name: ThemeManager.Notifications.ModeChanged,
                                               object: nil)
    }
    
    private func apply() {
        guard let themeData = themeData else { return }
        
        if #available(iOS 15.0, *) {
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            tabAppearance.backgroundColor = UIColor.fromRGBString(rgbString: themeData.viewColor)
            tabAppearance.selectionIndicatorTintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.selectedColor)
            ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.compactInlineLayoutAppearance)
            ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.inlineLayoutAppearance)
            ThemeManager.updateTabBarItemAppearance(appearance: tabAppearance.stackedLayoutAppearance)
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            UITabBar.appearance().barStyle = barStyle
            
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor.fromRGBString(rgbString: themeData.navBarTheme.backgroundColor)
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor.fromRGBString(rgbString: themeData.navBarTheme.textColor)!,
                                                 .font: themeData.navBarTheme.font.toFont()!]
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().barStyle = barStyle
        } else {
            UITabBar.appearance().barTintColor = UIColor.fromRGBString(rgbString: themeData.viewColor)
            UITabBar.appearance().barStyle = barStyle
            UITabBar.appearance().unselectedItemTintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.unSelectedColor)
            UITabBar.appearance().tintColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.selectedColor)
            
            UINavigationBar.appearance().barStyle = barStyle
            UINavigationBar.appearance().barTintColor = UIColor.fromRGBString(rgbString: themeData.navBarTheme.backgroundColor)
            UINavigationBar.appearance().titleTextAttributes =
                [.foregroundColor: UIColor.fromRGBString(rgbString: themeData.navBarTheme.textColor)!,
                 .font: themeData.navBarTheme.font.toFont()!]
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            UINavigationBar.appearance().shadowImage = UIImage()
        }
    }
    
    @available(iOS 15.0, *)
    static func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
        guard let themeData = ThemeManager.shared.themeData else { return }
        
        let tintColor: UIColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.selectedColor)!
        let unselectedItemTintColor: UIColor = UIColor.fromRGBString(rgbString: themeData.tabBarTheme.unSelectedColor)!
        
        appearance.selected.iconColor = tintColor
        appearance.selected.titleTextAttributes = [.foregroundColor: tintColor]
        appearance.normal.iconColor = unselectedItemTintColor
        appearance.normal.titleTextAttributes = [.foregroundColor: unselectedItemTintColor]
    }
    
    private func loadPlist(plist: String) -> [String: Any]? {
        let bundle = Bundle.main
        let podBundle = Bundle(for: ThemeManager.self)
        var pListPath: String?
        
        if let path = bundle.path(forResource: plist, ofType: "plist") {
            pListPath = path
        } else if let path = podBundle.path(forResource: plist, ofType: "plist") {
            pListPath = path
        }
        
        if let pListPath = pListPath,
           let pListData = FileManager.default.contents(atPath: pListPath) {
            do {
                let pListObject = try PropertyListSerialization.propertyList(from: pListData, options:PropertyListSerialization.ReadOptions(), format:nil)
                guard let pListDict = pListObject as? [String: Any] else {
                    return nil
                }
                return pListDict
            } catch {
                print("Error reading regions plist file: \(error)")
                return nil
            }
        }
        return nil
    }
    
    @objc func handleModeChanged() {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            setDarkTheme()
        } else {
            setLightTheme()
        }
        apply()
        NotificationCenter.default.post(name: ThemeManager.Notifications.ThemeChanged, object: nil)
    }
}
