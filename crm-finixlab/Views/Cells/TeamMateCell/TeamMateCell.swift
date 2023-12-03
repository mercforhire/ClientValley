//
//  TeamMateCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-08.
//

import UIKit

class TeamMateCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.searchResultTheme else { return }
        nameLabel.text = ""
        nameLabel.font = theme.nameLabel.font.toFont()
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.nameLabel.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    func config(teamMember: TeamMember) {
        let config = AvatarImageConfiguration(image: teamMember.avatarImage,
                                              name: teamMember.avatar == nil ? teamMember.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = teamMember.fullName
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
