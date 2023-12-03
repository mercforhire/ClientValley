//
//  CountryPickerCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-09.
//

import UIKit

class CountryPickerCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    static let height: CGFloat = 35.0
    
    @IBOutlet weak var highlightBar: UIView!
    @IBOutlet weak var selectionLabel: UILabel!
    private var selected2: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        selectionLabel.text = ""
        selectionStyle = .none
        configureUI()
    }

    func configureUI() {
        guard let theme = themeManager.themeData?.dropdownMenuTheme, let viewColor = themeManager.themeData?.viewColor  else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: viewColor)
        highlightBar.backgroundColor = UIColor.fromRGBString(rgbString: theme.selectedSegmentColor)
        selectionLabel.font = theme.font.toFont()
        selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedTextColor)
        if selected2 {
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedTextColor)
        } else {
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
        
        if selected {
            highlightBar.isHidden = false
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedTextColor)
        } else {
            highlightBar.isHidden = true
            selectionLabel.textColor = UIColor.fromRGBString(rgbString: theme.unSelectedTextColor)
        }
        self.selected2 = selected
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
