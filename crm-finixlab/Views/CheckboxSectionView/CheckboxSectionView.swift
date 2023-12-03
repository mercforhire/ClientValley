//
//  CheckboxSectionView.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-12.
//

import UIKit

class CheckboxSectionView: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var button: UIButton!
    
    private var selected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.roundCorners()
        configureUI()
    }
    
    func configureUI(selected: Bool? = nil) {
        guard let theme = themeManager.themeData?.checkboxSectionTheme else { return }
        
        label.font = theme.font.toFont()
        checkbox.titleLabel?.font = theme.font.toFont()
        
        self.selected = selected ?? self.selected
        
        if self.selected {
            container.backgroundColor = UIColor.fromRGBString(rgbString: theme.checkedBackgroundColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.checkedTextColor)
            checkbox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkbox.tintColor = UIColor.fromRGBString(rgbString: theme.checkedCheckboxColor)
            checkbox.setTitleColor(UIColor.fromRGBString(rgbString: theme.checkedCheckboxColor), for: .normal)
        } else {
            container.backgroundColor = UIColor.fromRGBString(rgbString: theme.uncheckedBackgroundColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.uncheckedTextColor)
            checkbox.setImage(UIImage(systemName: "circle"), for: .normal)
            checkbox.tintColor = UIColor.fromRGBString(rgbString: theme.uncheckedCheckboxColor)
            checkbox.setTitleColor(UIColor.fromRGBString(rgbString: theme.uncheckedCheckboxColor), for: .normal)
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
