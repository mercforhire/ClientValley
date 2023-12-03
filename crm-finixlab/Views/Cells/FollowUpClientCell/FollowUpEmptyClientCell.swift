//
//  FollowUpEmptyClientCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-26.
//

import UIKit

class FollowUpEmptyClientCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
    }
    
    func setupUI() {
        guard let theme = themeManager.themeData?.searchResultTheme else { return }
        
        label.font = theme.nameLabel.font.toFont()
        label.textColor = UIColor.fromRGBString(rgbString: theme.nameLabel.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
