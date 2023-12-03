//
//  CommonUtils.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import Foundation
import UIKit
import SKCountryPicker

func openURLInBrowser(url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}

typealias Action = () -> Void

class Notifications {
    static let SwitchToFollowUp: Notification.Name = Notification.Name("SwitchToFollowUp")
    static let OpenClientProfile: Notification.Name = Notification.Name("OpenClientProfile")
    static let MailComposeDismissed: Notification.Name = Notification.Name("MailComposeDismissed")
    static let TeamInvitationArrived: Notification.Name = Notification.Name("TeamInvitationArrived")
    static let TeamChanged: Notification.Name = Notification.Name("TeamChanged")
}

func showErrorDialog(error: String) {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func showNetworkErrorDialog() {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: "Network error, please check Internet connection.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func shortCodeGenerator(base: UInt32 = 62, length: Int) -> String {
    let base62chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    var code = ""
    for _ in 0..<length {
        let random = Int(arc4random_uniform(min(base, 62)))
        code.append(base62chars[random])
    }
    return code
}

func getCurrentCountry() -> Country? {
    let locale: NSLocale = NSLocale.current as NSLocale
    if let currentCountryCode: String = locale.countryCode {
        let countries = CountryManager.shared.countries
        if let country = countries.filter({ subject in
            return subject.countryCode == currentCountryCode
        }).first {
            return country
        }
    }
    
    return nil
}
