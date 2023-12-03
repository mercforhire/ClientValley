//
//  MailSavedCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-26.
//

import UIKit

class MailSavedCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var badge: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        badge.isHidden = true
        icon.roundCorners(style: .completely)
        badge.roundCorners(style: .completely)
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.templateCellTheme else { return }
        
        icon.backgroundColor = UIColor.fromRGBString(rgbString: theme.iconBackgroundColor)
        icon.tintColor = UIColor.fromRGBString(rgbString: theme.iconTintColor)
        titleLabel.font = theme.font.toFont()
        titleLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        dateLabel.font = theme.font.toFont()
        dateLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        editButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonTintColor)
        badge.backgroundColor = UIColor.fromRGBString(rgbString: "rgb 255 33 33")
        
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
    
    func config(mail: Mail, upcoming: Bool) {
        titleLabel.text = mail.title
        if let date = mail.dueDate {
            dateLabel.text = "Mailing Date: \(DateUtil.convert(input: date, outputFormat: .format5) ?? "Unknown")"
        } else {
            dateLabel.text = "Mailing Date: Unknown"
        }
        if upcoming {
            editButton.isHidden = false
        } else {
            editButton.isHidden = true
        }
    }
}
