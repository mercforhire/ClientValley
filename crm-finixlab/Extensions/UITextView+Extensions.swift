//
//  UITextView+Extensions.swift
//  Phoenix
//
//  Created by Sunho Lee on 2018-10-22.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

extension UITextView {
    
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
