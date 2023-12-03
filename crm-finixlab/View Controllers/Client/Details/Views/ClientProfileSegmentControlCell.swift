//
//  ClientProfileSegmentControlCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import PuiSegmentedControl

class ClientProfileSegmentControlCell: UITableViewCell {

    @IBOutlet weak var segmentControl: ThemeSegmentedControl!
    private var observer: NSObjectProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        segmentControl.items = ProfileDetailType.listString()
        setupUI()
    }
    
    func setupUI() {
        segmentControl.setupUI(overrideFontSize: 12.0)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
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
}
