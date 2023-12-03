//
//  LabelSwitchCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-14.
//

import UIKit

class LabelSwitchCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rightSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureUI() {
        guard let theme = themeManager.themeData?.labelSwitchCellTheme else { return }
        
        nameLabel.text = ""
        nameLabel.font = theme.label.font.toFont()
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.label.textColor)
        rightSwitch.onTintColor = UIColor.fromRGBString(rgbString: theme.switchTintColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func config(label: String, isOn: Bool) {
        nameLabel.text = label
        rightSwitch.isOn = isOn
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
