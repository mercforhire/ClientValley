//
//  RightArrowButton.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import UIKit

class SmallRightArrowButton: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configureUI() {
        guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        labelButton.titleLabel?.font = themeData.font.toFont(overrideSize: 11.5)
        labelButton.setTitleColor(UIColor.fromRGBString(rgbString: themeData.textColor), for: .normal)
        rightArrow.tintColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        if let borderColor = UIColor.fromRGBString(rgbString: themeData.borderColor ?? "") {
            container.addBorder(color: borderColor)
            rightArrow.addBorder(color: borderColor)
        }
        
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
