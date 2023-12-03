//
//  AccountTableViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-28.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var enabled = true {
        didSet {
            setupUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        label.text = ""
        iconContainer.roundCorners(style: .completely)
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.accountCellTheme, let theme2 = themeManager.themeData?.accountScreen else { return }
        
        label.font = theme.font.toFont()
        iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.iconBackgroundColor)
        
        if enabled {
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.iconTintColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.iconBackgroundColor)
        } else {
            icon.tintColor = UIColor.fromRGBString(rgbString: theme.iconTintColor)
            iconContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme2.disabledItemColor)
            label.textColor = UIColor.fromRGBString(rgbString: theme2.disabledItemColor)
        }
        
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
