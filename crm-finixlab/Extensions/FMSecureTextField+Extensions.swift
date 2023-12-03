//
//  FMSecureTextField+Extensions.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-18.
//

import Foundation
import FMSecureTextField

extension FMSecureTextField {
    func applyTheme() {
        let themeManager = ThemeManager.shared
        guard let theme = themeManager.themeData?.textFieldTheme else { return }
        
        borderStyle = .none
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        addBorder(color: UIColor.fromRGBString(rgbString: theme.borderColor!)!)
        textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        font = theme.font.toFont()
        roundCorners()
    }
}
