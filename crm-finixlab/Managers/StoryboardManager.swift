//
//  StoryboardManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import Foundation
import UIKit

class StoryboardManager: NSObject {
    class func load(storyboard: String, animated: Bool = true, completion: ((UIViewController) -> Void)? = nil) {
        guard let window = UIViewController.window else {
            return
        }
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        guard let rootController = storyboard.instantiateInitialViewController() else {
            return
        }
        
        if animated {
            let transition = CATransition()
            transition.type = CATransitionType.fade
            transition.duration = 0.3
            window.rootViewController = rootController
        }
        else {
            window.rootViewController = rootController
        }
        rootController.view.layoutIfNeeded()
        completion?(rootController)
    }
    
    class func loadViewController<T: UIViewController>(storyboard: String, viewControllerId: String, loadViewIfNeeded: Bool = false) -> T? {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerId) as? T
        // sometimes we don't need viewDidLoad to be called at this point if setupUI() is based in variables passed in later
        if loadViewIfNeeded {
            viewController?.loadViewIfNeeded()
        }
        return viewController
    }
    
    class func loadViewController<T: UIViewController>(storyboard: String, loadViewIfNeeded: Bool = false) -> T? {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T
        // sometimes we don't need viewDidLoad to be called at this point if setupUI() is based in variables passed in later
        if loadViewIfNeeded {
            viewController?.loadViewIfNeeded()
        }
        return viewController
    }
}
