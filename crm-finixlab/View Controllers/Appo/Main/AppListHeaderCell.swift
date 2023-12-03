//
//  AppListHeaderCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-31.
//

import UIKit

class AppListHeaderCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureUI() {
        guard let theme = themeManager.themeData?.textFieldLabelTheme else { return }
        icon.tintColor = UIColor.fromRGBString(rgbString: theme.textColor)
        timeLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func config(date: Date) {
        timeLabel.text = DateUtil.convert(input: date, outputFormat: .format9)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
