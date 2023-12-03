//
//  RoundedCornersView.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-11-19.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//
import UIKit

class RoundedCornersView: UIView {
    var corners: UIRectCorner = .allCorners
    
    @IBInspectable var radius: CGFloat = 10.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners(corners: corners, radius: radius)
    }
}
