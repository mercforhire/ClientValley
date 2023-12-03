//
//  SmallTagCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import UIKit

class SmallTagCell: MIBubbleCollectionViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.text = ""
    }
    
    func setupUI(overrideFontSize: CGFloat? = nil) {
        guard let themeData = themeManager.themeData?.emailNameTag else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        lblTitle.font = themeData.font.toFont(overrideSize: overrideFontSize)
        lblTitle.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI(overrideFontSize: overrideFontSize)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.roundCorners(style: .completely)
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
