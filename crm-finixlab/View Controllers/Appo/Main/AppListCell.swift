//
//  AppListCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-30.
//

import UIKit

class AppListCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var appoNameLabel: UILabel!
    @IBOutlet weak var expenseContainer: UIView!
    @IBOutlet weak var expenseLabel: UILabel!
    
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
        guard let theme = themeManager.themeData?.appoScreenTheme.appListCellTheme else { return }
        
        stackView.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        stackView.roundCorners()
        
        fromTimeLabel.font = theme.timeLabelFont.toFont()
        fromTimeLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        toTimeLabel.font = theme.timeLabelFont.toFont()
        toTimeLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        divider.backgroundColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        clientNameLabel.font = theme.nameLabelFont.toFont()
        clientNameLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        appoNameLabel.font = theme.appoNameLabelFont.toFont()
        appoNameLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        expenseLabel.font = theme.nameLabelFont.toFont()
        expenseLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func config(appo: Appo, client: Client?) {
        if (appo.estimateAmount ?? 0) > 0 {
            expenseContainer.isHidden = false
            expenseLabel.text = "$\(String(format: "%.2f", appo.estimateAmount ?? 0))"
        } else {
            expenseContainer.isHidden = true
            expenseLabel.text = ""
        }
        
        fromTimeLabel.text = DateUtil.convert(input: appo.startTime, outputFormat: .format8)
        toTimeLabel.text = DateUtil.convert(input: appo.endTime, outputFormat: .format8)
        clientNameLabel.text = client?.fullName ?? "Unknown client"
        appoNameLabel.text = appo.title
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
