//
//  RoundIconWithLabel.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-12.
//

import UIKit

class RoundIconWithLabel: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var badge: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.backgroundColor = .clear
        badge.backgroundColor = UIColor.fromRGBString(rgbString: "rgb 255 33 33")
        badge.roundCorners(style: .completely)
        badge.isHidden = true
    }
    
    func configureUI(type: ContactMethodType, selected: Bool) {
        guard let theme = themeManager.themeData?.contactMethodIconTheme else { return }
        
        icon.image = type.icon()
        label.text = type.name()
        label.font = theme.available.font.toFont()
        
        if selected {
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.available.backgroundColor)
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.available.iconTintColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.available.textColor)
            if let borderColor = theme.available.borderColor, let color = UIColor.fromRGBString(rgbString: borderColor) {
                iconContainer.addBorder(color: color)
            }
        } else {
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.unavailable.backgroundColor)
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.unavailable.iconTintColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.unavailable.textColor)
            if let borderColor = theme.unavailable.borderColor, let color = UIColor.fromRGBString(rgbString: borderColor) {
                iconContainer.addBorder(color: color)
            }
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI(type: type, selected: selected)
            }
        }
    }
    
    func configureUI(type: FollowUpType, selected: Bool) {
        guard let theme = themeManager.themeData?.contactMethodIconTheme else { return }
        
        icon.image = type.icon()
        label.text = type.name()
        label.font = theme.available.font.toFont()
        
        if selected {
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.available.backgroundColor)
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.available.iconTintColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.available.textColor)
            if let borderColor = theme.available.borderColor, let color = UIColor.fromRGBString(rgbString: borderColor) {
                iconContainer.addBorder(color: color)
            }
        } else {
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.unavailable.backgroundColor)
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.unavailable.iconTintColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.unavailable.textColor)
            if let borderColor = theme.unavailable.borderColor, let color = UIColor.fromRGBString(rgbString: borderColor) {
                iconContainer.addBorder(color: color)
            }
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI(type: type, selected: selected)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainer.roundCorners(style: .completely)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
