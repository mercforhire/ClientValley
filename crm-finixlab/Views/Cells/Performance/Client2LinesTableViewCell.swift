//
//  Client2LinesTableViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-20.
//

import UIKit

enum PerformanceCellTypes {
    case birthday
    case totalExpense(Double)
    case appos(Int)
}

class Client2LinesTableViewCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    
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
        guard let theme = themeManager.themeData?.performanceTables else { return }
        
        line1.textColor = UIColor.fromRGBString(rgbString: theme.primaryLabelColor)
        line2.textColor = UIColor.fromRGBString(rgbString: theme.secondaryLabelColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func config(client: Client, mode: PerformanceCellTypes) {
        let config = AvatarImageConfiguration(image: client.avatarImage,
                                              name: client.avatar == nil ? client.initials : nil)
        avatar.config(configuration: config)
        line1.text = client.fullName
        
        switch mode {
        case .birthday:
            guard let birthday = client.birthday else { return }
            
            line2.text = DateUtil.convert(input: birthday, outputFormat: .format9)
        case .totalExpense(let amount):
            line2.text = amount.currency()
        case .appos(let count):
            line2.text = "\(count) appointments"
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
