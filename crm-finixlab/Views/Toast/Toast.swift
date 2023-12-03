//
//  Dialogues.swift
//  Phoenix
//
//  Created by Illya Gordiyenko on 2018-06-06.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

class Toast: NSObject {
    
    private static let defaultHeight:CGFloat = 75.0
    public static let defaultDuration: TimeInterval = 3.0
    
    class func showSuccess(with status:String, for duration:TimeInterval = Toast.defaultDuration, completion:((Bool) -> Void)? = nil) {
        let toastHeight: CGFloat = defaultHeight
        
        guard let screenWidth = UIViewController.window?.rootViewController?.view.frame.width else { return }
        guard let screenHeight = UIViewController.window?.rootViewController?.view.frame.height else { return }
        
        // Setup
        let toastView = ToastView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: toastHeight))
        toastView.descriptionLabel.text = status
        
        // Animation in
        UIViewController.window?.rootViewController?.view.addSubview(toastView)
        
        var updatedFrame = toastView.frame
        updatedFrame.origin.y = screenHeight - toastHeight
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                toastView.frame = updatedFrame
        }, completion: nil)
        
        UIView.animate(
            withDuration: 0.2,
            delay: duration,
            options: .curveEaseIn,
            animations: {
                toastView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: toastHeight)
        }) { finished in
            completion?(finished)
            toastView.removeFromSuperview()
        }
    }
    
}
