//
//  ThemeSegmentedControl.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-07.
//

import UIKit
import PuiSegmentedControl

class ThemeSegmentedControl: PuiSegmentedControl {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    func setupUI(overrideFontSize: CGFloat? = nil) {
        guard let theme = themeManager.themeData?.segmentedControlTheme else { return }
        
        let unselectedTextAttributes: [NSAttributedString.Key: Any] = [
            .font : theme.font.toFont(overrideSize: overrideFontSize)!,
            .foregroundColor : UIColor.fromRGBString(rgbString: theme.unSelectedSegmentTextColor)!
        ]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .font : theme.font.toFont(overrideSize: overrideFontSize)!,
            .foregroundColor : UIColor.fromRGBString(rgbString: theme.selectedSegmentTextColor)!
        ]
        self.selectedTextAttributes = selectedTextAttributes
        self.unselectedTextAttributes = unselectedTextAttributes
        unselectedViewBackgroundColor = UIColor.fromRGBString(rgbString: theme.unSelectedSegmentColor)!
        selectedViewBackgroundColor = UIColor.fromRGBString(rgbString:theme.selectedSegmentColor)!
        backgroundCustomColor = UIColor.fromRGBString(rgbString: theme.unSelectedSegmentColor)!
        backgroundCornerRadius = frame.height / 2
        borderCornerRadius = frame.height / 2
        isSeperatorActive = false
        isSelectViewAllCornerRadius = true
        isAnimatedTabTransition = true
        animatedTabTransitionDuration = 0.2
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI(overrideFontSize: overrideFontSize)
                self?.isConfiguredView = false
                self?.layoutSubviews()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
