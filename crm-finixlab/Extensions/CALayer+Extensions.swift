//
//  CALayer+Extensions.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-11-21.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

extension CALayer {
    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    /**
     UIBezierPath is created on the bottom half rect of the self.bounds to not show shadows on the top (reason why shadowOffset = 1 not 2)
     Applied view's background color shouldn't be transaparent
     */
    func applyDropShadow(color: UIColor = UIColor.gray, opacity: Float = 0.19, x: CGFloat = 0, y: CGFloat = 1, blur: CGFloat = 12.0, spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = CGFloat(blur / 2.0)
        masksToBounds = false
        shadowPath = UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.midY, width: bounds.width, height: bounds.height/2)).cgPath
    }
}
