//
//  AppoTableViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-20.
//

import UIKit

class AppoTableViewCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!
    
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
        
        line1.textColor = UIColor.fromRGBString(rgbString: theme.secondaryLabelColor)
        line2.textColor = UIColor.fromRGBString(rgbString: theme.primaryLabelColor)
        line3.textColor = UIColor.fromRGBString(rgbString: theme.primaryLabelColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func config(index: Int, client: Client?, appo: Appo) {
        line1.text = "\(index). \(DateUtil.convert(input: appo.startTime, outputFormat: .format9)!)"
        line2.text = client?.fullNameWithCivility ?? "Unknown client"
        line3.text = "\(DateUtil.convert(input: appo.startTime, outputFormat: .format8)!) - \(DateUtil.convert(input: appo.endTime, outputFormat: .format8)!)"
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
