//
//  ClientSearchResultCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-12.
//

import UIKit

class ClientSearchResultCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.searchResultTheme else { return }
        
        nameLabel.text = ""
        nameLabel.font = theme.nameLabel.font.toFont()
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.nameLabel.textColor)
        arrowView.tintColor = UIColor.fromRGBString(rgbString: theme.iconTintColor)
        
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Client) {
        let config = AvatarImageConfiguration(image: data.avatarImage,
                                              name: data.avatar == nil ? data.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = data.fullName
    }
}
