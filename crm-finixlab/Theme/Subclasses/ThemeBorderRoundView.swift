//
//  ThemeBorderRoundView.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-09.
//

import UIKit

class ThemeBorderRoundView: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        guard let theme = themeManager.themeData?.textFieldTheme else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        addBorder(color: UIColor.fromRGBString(rgbString: theme.borderColor!)!)
        roundCorners()
        
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
