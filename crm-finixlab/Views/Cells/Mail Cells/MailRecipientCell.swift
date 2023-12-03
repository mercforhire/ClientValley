//
//  MailRecipientCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit

class MailRecipientCell: UITableViewCell {
    static let CellHeight: CGFloat = 65.0
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
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
        nameLabel.font = theme.font.toFont()
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        deleteButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonTintColor)
        deleteButton.backgroundColor = UIColor.fromRGBString(rgbString: theme.buttonBackgroundColor)
        deleteButton.roundCorners(style: .completely)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    func config(client: Client) {
        let config = AvatarImageConfiguration(image: client.avatarImage,
                                              name: client.avatar == nil ? client.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = client.fullName
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
