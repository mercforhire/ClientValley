//
//  ThemeCalendar.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-01.
//

import UIKit
import FSCalendar

class ThemeCalendar: FSCalendar {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setupUI() {
        guard let theme = themeManager.themeData?.appoScreenTheme.calender else { return }
        
        roundCorners()
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
        self.appearance.headerTitleFont = theme.monthLabelFont.toFont()
        self.appearance.headerTitleColor = UIColor.fromRGBString(rgbString: theme.monthLabelTextColor)
        
        self.headerHeight = 40.0
        self.weekdayHeight = 35.0
        self.appearance.weekdayFont = theme.weekdayLabelFont.toFont()
        self.appearance.weekdayTextColor = UIColor.fromRGBString(rgbString: theme.weekdayLabelTextColor)
        
        self.appearance.titleFont = theme.dayLabelFont.toFont()
        self.appearance.titleTodayColor = UIColor.fromRGBString(rgbString: theme.dayLabelUnselectedTextColor)
        self.appearance.titleDefaultColor = UIColor.fromRGBString(rgbString: theme.dayLabelUnselectedTextColor)
        self.appearance.titleWeekendColor = UIColor.fromRGBString(rgbString: theme.dayLabelUnselectedTextColor)
        self.appearance.titlePlaceholderColor = UIColor.fromRGBString(rgbString: theme.dayLabelPreviousMonthTextColor)
        self.appearance.selectionColor = UIColor.fromRGBString(rgbString: theme.dayLabelSelectedTintColor)
        self.appearance.headerMinimumDissolvedAlpha = 0.0
        self.appearance.todaySelectionColor = UIColor.fromRGBString(rgbString: theme.dayLabelSelectedTintColor)
        self.appearance.titleSelectionColor = UIColor.fromRGBString(rgbString: theme.dayLabelSelectedTextColor)
        self.appearance.todayColor = .clear
        configureAppearance()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
