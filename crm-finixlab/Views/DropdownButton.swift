//
//  DropdownButton.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-09.
//

import UIKit

class DropdownButton: UIButton {
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
        guard let theme = themeManager.themeData?.dropdownMenuTheme else { return }
        
        setTitle("", for: .normal)
        setImage(UIImage(named: "DropDown"), for: .normal)
        setImage(UIImage(named: "DropRight"), for: .selected)
        tintColor = UIColor.fromRGBString(rgbString: theme.arrowColor)
        
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
