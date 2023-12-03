//
//  UINavigationController+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import Foundation

import Foundation
import UIKit

extension UINavigationController {
    func findViewControllerOfClass(kind: AnyClass) -> UIViewController? {
        // iterate to find the type of vc
        for element in viewControllers as Array {
            if element.isKind(of: kind) {
                return element
            }
        }
        return nil
    }
    
    func findAndRemoveViewControllerOfClass(kind: AnyClass) {
        // iterate to find the type of vc
        let newArray: [UIViewController] = viewControllers.filter { subject in
            return !subject.isKind(of: kind)
        }
        viewControllers = newArray
    }
    
    func popToViewControllerOfClass(kind: AnyClass) -> Bool {
        if let vc: UIViewController = findViewControllerOfClass(kind: kind) {
            popToViewController(vc, animated: true)
            return true
        }
        
        return false
    }
    
    func pushAndReplaceWith(viewController: UIViewController) {
        var viewControllers: [UIViewController] = self.viewControllers
        viewControllers.removeLast()
        viewControllers.append(viewController)
        setViewControllers(viewControllers, animated: false)
    }

    func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func indexOfClass(kind: AnyClass) -> Int? {
        guard !viewControllers.isEmpty else {
            return nil
        }
        
        for (index, controller) in viewControllers.enumerated() {
            if controller.isKind(of: kind) {
                return index
            }
        }
        
        return nil
    }
    
    func distanceBetween(first: AnyClass, second: AnyClass) -> Int? {
        guard let indexOfFirst = indexOfClass(kind: first),
            let indexOfSecond = indexOfClass(kind: second) else {
                return nil
        }
        
        return abs(indexOfFirst - indexOfSecond)
    }
}
