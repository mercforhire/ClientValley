//
//  AppSettingsManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation

enum Environments: String {
    case production
    case development
    
    func appId() -> String {
        switch self {
        case .production:
            return "crm-finixlab-rgofl"
        case .development:
            return "tasktracker-wczyd"
        }
    }
    
    func googleApiKey() -> String {
        switch self {
        case .production:
            return "AIzaSyAHq8TVdjuBp4ZWMMK0kVOnyCTYkV8X8OE"
        case .development:
            return "AIzaSyAHq8TVdjuBp4ZWMMK0kVOnyCTYkV8X8OE"
        }
    }
}

class AppSettingsManager {
    static let shared = AppSettingsManager()
    
    private let AppSettingsKey : String = "AppSettings"
    private let EnvironmentKey : String = "Environment"
    private let EmailVerifiedKey : String = "EmailVerified"
    private let ViewedTutorialsMemoryKey : String = "ViewedTutorialsMemory"
    
    private let defaults = UserDefaults.standard
    private var settings: [String: Any] = [:]
    
    init() {
        loadSettingsFromPersistence()
    }
    
    private func loadSettingsFromPersistence() {
        //load previous Settings
        settings = defaults.dictionary(forKey: AppSettingsKey) ?? [:]
    }
    
    func getEnvironment() -> Environments {
        return Environments(rawValue: (settings[EnvironmentKey] as? String) ?? "") ?? .production
    }
    
    func setEnvironment(environments: Environments) {
        settings[EnvironmentKey] = environments.rawValue
        saveSettings()
    }
    
    func getEmailVerified() -> Bool {
        return settings[EmailVerifiedKey] as? Bool ?? false
    }
    
    func setEmailVerified(verified: Bool) {
        settings[EmailVerifiedKey] = verified
        saveSettings()
    }
    
    func getViewedTutorialsMemory() -> [String: Bool]? {
        return settings[ViewedTutorialsMemoryKey] as? [String : Bool]
    }
    
    func setViewedTutorialsMemory(value: [String: Bool]?) {
        settings[ViewedTutorialsMemoryKey] = value
        saveSettings()
    }
    
    private func saveSettings() {
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
    
    func resetSettings() {
        // don't forget the environment settings
        let current = getEnvironment()
        settings = [:]
        settings[EnvironmentKey] = current.rawValue
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
