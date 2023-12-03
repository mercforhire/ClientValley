//
//  TeamSelectionCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-06.
//

import UIKit

class TeamSelectionCell: UITableViewCell {
    enum TeamSelectionCellStyle {
        case unchecked
        case checked
        case add
        
    }
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    static let DefaultCellHeight: CGFloat = 61
    
    @IBOutlet weak var dot: UIView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var divider: ThemeTransparentBorderView!
    
    var state: TeamSelectionCellStyle = .unchecked {
        didSet {
            guard let theme = ThemeManager.shared.themeData?.teamActionSheetTheme else { return }
            
            switch state {
            case .checked:
                dot.backgroundColor = UIColor.fromRGBString(rgbString: theme.selectedColor)
                teamNameLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedColor)
                rightIcon.image = UIImage(systemName: "checkmark.circle.fill")
                rightIcon.tintColor = UIColor.fromRGBString(rgbString: theme.selectedIconTintColor)
            case .unchecked:
                dot.backgroundColor = UIColor.fromRGBString(rgbString: theme.unselectedColor)
                teamNameLabel.textColor = UIColor.fromRGBString(rgbString: theme.unselectedColor)
                rightIcon.image = UIImage(systemName: "circle")
                rightIcon.tintColor = UIColor.fromRGBString(rgbString: theme.unselectedIconTintColor)
            case .add:
                dot.backgroundColor = UIColor.clear
                teamNameLabel.textColor = UIColor.fromRGBString(rgbString: theme.selectedColor)
                teamNameLabel.text = "Create new team"
                rightIcon.image = UIImage(systemName: "plus.circle.fill")
                rightIcon.tintColor = UIColor.fromRGBString(rgbString: theme.selectedIconTintColor)
            }
            
            divider.backgroundColor = UIColor.fromRGBString(rgbString: theme.dividerColor)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        dot.roundCorners(style: .completely)
        teamNameLabel.text = ""
        rightIcon.roundCorners(style: .completely)
        
        configureUI()
    }

    func configureUI() {
        state = { self.state }()
        
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
    
    func config(state: TeamSelectionCellStyle, team: Team?, showDivider: Bool) {
        teamNameLabel.text = team?.name ?? "No team"
        self.state = state
        divider.isHidden = !showDivider
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
