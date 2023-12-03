//
//  HashTagCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-10.
//

import UIKit

class HashTagCell: MIBubbleCollectionViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var rightArrow: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        lblTitle.text = ""
    }
    
    func configureUI() {
        guard let themeData = themeManager.themeData?.hashTheme else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        lblTitle.font = themeData.font.toFont()
        lblTitle.textColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        rightArrow.tintColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        container.addBorder(color: UIColor.fromRGBString(rgbString: themeData.borderColor)!)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.configureUI()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.roundCorners(style: .completely)
        rightArrow.roundCorners(style: .completely)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
