//
//  MailAddRecipientCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit

class MailAddRecipientCell: UITableViewCell {
    static let CellHeight: CGFloat = 65.0
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.mailRecipientCellTheme else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        label.font = theme.font.toFont()
        label.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        plusButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonTintColor)
        plusButton.backgroundColor = UIColor.fromRGBString(rgbString: theme.buttonBackgroundColor)
        plusButton.roundCorners(style: .completely)
        
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
