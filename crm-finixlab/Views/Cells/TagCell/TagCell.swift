//
//  TagCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-11.
//

import UIKit

class TagCell: MIBubbleCollectionViewCell {

    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.text = ""
    }
    
    func configureUI() {
        guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        lblTitle.font = themeData.font.toFont()
        lblTitle.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    func configureUIAlternate(overrideFontSize: CGFloat? = nil) {
        guard let themeData = themeManager.themeData?.hashTheme else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        lblTitle.font = themeData.font.toFont(overrideSize: overrideFontSize)
        lblTitle.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUIAlternate(overrideFontSize: overrideFontSize)
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
