//
//  TemplateCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-26.
//

import UIKit

class TemplateCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var border: ThemeBorderView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureUI() {
        guard let theme = themeManager.themeData?.templateCellTheme else { return }
        
        label.font = theme.font.toFont()
        label.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        editButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonTintColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func config(template: TemplateEmail) {
        label.text = template.name
    }
    
    func config(template: TemplateMessage) {
        label.text = template.name
    }
}
