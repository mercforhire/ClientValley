//
//  Double+Extensions.swift
//  Phoenix
//
//  Created by Adam Borzecki on 9/22/18.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit
import UIKit
extension Double {
    func currency(_ withDecimal: Bool = true, showPlusSign: Bool = false) -> String {
        var string = DisplayNumberFormatter.transform(from: self, style: .currency, setOptions: { formatter in
            formatter.maximumFractionDigits = withDecimal ? 2 : 0
            formatter.minimumFractionDigits = withDecimal ? 2 : 0
        })!
        
        if self > 0 {
            if showPlusSign {
                string = "+" + string
            }
        }
        
        return string
    }
    
    func decimal(_ withDecimal: Bool = true) -> String {
        return DisplayNumberFormatter.transform(from: self, style: .decimal, setOptions: { formatter in
            formatter.maximumFractionDigits = withDecimal ? 2 : 0
            formatter.minimumFractionDigits = withDecimal ? 2 : 0
        })!
    }
    
    func dollarToCents() -> Int64 {
        return Int64(self * 100)
    }
}
