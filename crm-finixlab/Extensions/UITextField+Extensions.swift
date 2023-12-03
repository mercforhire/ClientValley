//
//  UITextField+Extensions.swift
//  Phoenix
//
//  Created by Adam Borzecki on 6/8/18.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

private var maxLengths = [UITextField: Int]()
private var minLengths = [UITextField: Int]()

extension UITextField {
    
    //MARK:- Maximum length
    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return 100
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(fixMax), for: .editingChanged)
        }
    }
    @objc func fixMax(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedTo(length: maxLength)
    }
    
    //MARk:- Minimum length
    @IBInspectable var minLegth: Int {
        get {
            guard let l = minLengths[self] else {
                return 0
            }
            return l
        }
        set {
            minLengths[self] = newValue
            addTarget(self, action: #selector(fixMin), for: .editingChanged)
        }
    }
    @objc func fixMin(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedFrom(length: minLegth)
    }
}

extension String {
    func safelyLimitedTo(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func safelyLimitedFrom(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

extension UITextField {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
            action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    func currentCursorPosition() -> Int? {
        guard let selectedRange = selectedTextRange else {
            return nil
        }
            
        return offset(from: beginningOfDocument, to: selectedRange.start)
    }
    
    func setCursorPosition(cursorPosition:Int) {
        if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
    
    func selectedAreaIsWithinText() -> Bool {
        guard let selectedTextRange = selectedTextRange else {
            return false
        }
        
        guard let text = text else {
            return false
        }
        
        let selectionEnd = offset(from: beginningOfDocument, to: selectedTextRange.end)
        
        return selectionEnd < text.count
    }
}
