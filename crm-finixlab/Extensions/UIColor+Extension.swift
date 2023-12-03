//
//  UIColor+Extension.swift
//  Experience
//
//  Created by Nicole Ahadi on 2019-12-18.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    var hexString: String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
    
    static func fromRGBString(rgbString: String) -> UIColor? {
        let components = rgbString.components(separatedBy: " ")
        
        guard components.count == 4,
              let red = components[1].int,
              let green = components[2].int,
              let blue = components[3].int else {
            return nil
        }
        
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        return color
    }
}
