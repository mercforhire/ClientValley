//
//  DropdownMenuCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-07.
//

import UIKit

class DropdownMenuCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    static let height: CGFloat = 50.0
    
    @IBOutlet weak var highlightBar: UIView!
    @IBOutlet weak var selectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        selectionLabel.text = ""
        configureUI()
    }
    
    func configureUI() {
        guard let theme = themeManager.themeData?.dropdownMenuTheme else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        highlightBar.backgroundColor = UIColor.fromRGBString(rgbString: theme.selectedSegmentColor)
        selectionLabel.font = theme.font.toFont()
        
        if isSelected {
            highlightBar.isHidden = false
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedTextColor)
        } else {
            highlightBar.isHidden = true
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.unSelectedTextColor)
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(text: String, selected: Bool) {
        guard let theme = themeManager.themeData?.dropdownMenuTheme else { return }
        
        selectionLabel.text = text
        isSelected = selected
        if isSelected {
            highlightBar.isHidden = false
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedTextColor)
        } else {
            highlightBar.isHidden = true
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.unSelectedTextColor)
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
