//
//  FollowUpClientCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-23.
//

import UIKit

class FollowUpClientCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var checkmarkContainer: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    
    var checked: Bool? {
        didSet {
            guard let theme = themeManager.themeData?.checkboxSectionTheme else { return }
            
            switch checked {
            case true:
                checkmarkContainer.isHidden = false
                checkmark.image = UIImage(systemName: "checkmark.circle.fill")
                checkmark.tintColor = UIColor.fromRGBString(rgbString: theme.checkedCheckboxColor)
            case false:
                checkmarkContainer.isHidden = false
                checkmark.image = UIImage(systemName: "circle")
                checkmark.tintColor = UIColor.fromRGBString(rgbString: theme.uncheckedCheckboxColor)
            default:
                checkmarkContainer.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
        selectionStyle = .none
    }

    func configureUI() {
        guard let theme = themeManager.themeData?.searchResultTheme else { return }
        
        checkmarkContainer.isHidden = true
        
        nameLabel.text = ""
        nameLabel.font = theme.nameLabel.font.toFont()
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.nameLabel.textColor)
        
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
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }

    func config(checked: Bool? = nil, client: Client) {
        self.checked = checked
        let config = AvatarImageConfiguration(image: client.avatarImage,
                                              name: client.avatar == nil ? client.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = client.fullName
    }
}
