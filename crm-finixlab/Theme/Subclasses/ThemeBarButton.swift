//
//  ThemeBarButton.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-27.
//

import UIKit

class ThemeBarButton: UIBarButtonItem {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        guard let navButtonTheme = themeManager.themeData?.navBarTheme.barButton else { return }
        
        tintColor = UIColor.fromRGBString(rgbString: navButtonTheme.textColor)!
        setTitleTextAttributes([.font: navButtonTheme.font.toFont()!,
                                .foregroundColor: UIColor.fromRGBString(rgbString: navButtonTheme.textColor)!],
                               for: .normal)
        
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
