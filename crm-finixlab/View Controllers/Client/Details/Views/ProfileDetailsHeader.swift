//
//  ProfileDetailsHeader.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GSKStretchyHeaderView
import UILabel_Copyable

class ProfileDetailsHeader: GSKStretchyHeaderView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var star: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userNameLabel.isCopyingEnabled = true
        setupUI()
    }
    
    func setupUI() {
        guard let themeData = themeManager.themeData?.navBarTheme else { return }
        
        backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        backButton.tintColor = UIColor.fromRGBString(rgbString: themeData.textColor)!
        editButton.tintColor = UIColor.fromRGBString(rgbString: themeData.textColor)!
        star.roundCorners(style: .completely)
        navigationTitleLabel.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)!
        userNameLabel.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)!
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    func configureUI(client: Client, userSettings: UserSettings) {
        guard let theme = themeManager.themeData?.segmentedControlTheme else { return }
        
        navigationTitleLabel.text = client.fullName
        userNameLabel.text = "\(client.statusEnum?.title() ?? "") \(client.fullName)"
        let config = AvatarImageConfiguration(image: client.avatarImage, name: client.initials)
        avatar.config(configuration: config)
        star.backgroundColor = userSettings.isClientStarred(client: client) ? UIColor.fromRGBString(rgbString: theme.selectedSegmentColor) : .clear
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        var alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        alpha = max(0, min(1, alpha))

        avatar.alpha = alpha
        star.alpha = alpha
        userNameLabel.alpha = alpha

        let navTitleFactor: CGFloat = 0.4
        var navTitleAlpha: CGFloat = 0
        if stretchFactor < navTitleFactor {
            navTitleAlpha = CGFloatTranslateRange(stretchFactor, 0, navTitleFactor, 1, 0)
        }
        navigationTitleLabel.alpha = navTitleAlpha
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
