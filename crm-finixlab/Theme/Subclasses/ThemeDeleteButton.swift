//
//  ThemeDeleteButton.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import UIKit

class ThemeDeleteButton: UIButton {
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
        guard let theme = themeManager.themeData?.deleteButtonTheme else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        if let borderColor = UIColor.fromRGBString(rgbString: theme.borderColor ?? "") {
            addBorder(color: borderColor)
        }
        titleLabel?.font = theme.font.toFont()
        setTitleColor(UIColor.fromRGBString(rgbString: theme.textColor), for: .normal)
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
