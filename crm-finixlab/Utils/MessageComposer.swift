//
//  MessageComposer.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import Foundation
import MessageUI

class MessageComposer: NSObject {
    func canCall(phoneNumber: String) -> Bool {
        if let callUrl = URL(string: "tel://\(phoneNumber)") {
            return UIApplication.shared.canOpenURL(callUrl)
        }
        
        return false
    }
    
    func call(phoneNumber: String) {
        if let callUrl = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(callUrl) {
            UIApplication.shared.open(callUrl)
        }
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func canSendEmail() -> Bool {
        return MFMessageComposeViewController.canSendSubject() || UIApplication.shared.canOpenURL(URL(string: "mailto:abc@yahoo.com")!)
    }
    
    func configuredMessageComposeViewController(recipients: [String], message: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = recipients
        messageComposeVC.body = message
        return messageComposeVC
    }
    
    func configuredEmailComposeViewController(toRecipients: [String], ccRecipients: [String], bccRecipients: [String], subject: String, message: String) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(toRecipients)
        mailVC.setCcRecipients(ccRecipients)
        mailVC.setBccRecipients(bccRecipients)
        mailVC.setSubject(subject)
        mailVC.setMessageBody(message, isHTML: false)
        return mailVC
    }
    
    func openSystemEmailContextMenu(myEmail: String, toRecipients: [String], ccRecipients: [String], bccRecipients: [String], subject: String, message: String) {
        guard UIApplication.shared.canOpenURL(URL(string: "mailto:abc@yahoo.com")!) else { return }
        
        var ccString: String = ""
        for cc in ccRecipients {
            if cc == ccRecipients.first {
                ccString = cc
            } else {
                ccString = "\(ccString), \(cc)"
            }
        }
        var bccString: String = ""
        for bcc in bccRecipients {
            if bcc == bccRecipients.first {
                bccString = bcc
            } else {
                bccString = "\(bccString), \(bcc)"
            }
        }
        let mailString: String = "mailto:\(myEmail)?cc=\(ccString)&bcc=\(bccString)?subject=\(subject)&body=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: mailString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension MessageComposer: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notifications.MailComposeDismissed, object: nil)
    }
}

extension MessageComposer: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        NotificationCenter.default.post(name: Notifications.MailComposeDismissed, object: nil)
    }
}

