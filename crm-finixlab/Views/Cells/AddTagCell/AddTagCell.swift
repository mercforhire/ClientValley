//
//  AddTagCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-10.
//

import UIKit

class AddTagCell: MIBubbleCollectionViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var rightArrow: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        labelButton.setTitle("Add", for: .normal)
    }
    
    func configureUI() {
        guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return }
        
        container.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        labelButton.titleLabel?.font = themeData.font.toFont()
        labelButton.setTitleColor(UIColor.fromRGBString(rgbString: themeData.textColor), for: .normal)
        rightArrow.tintColor = UIColor.fromRGBString(rgbString: themeData.textColor)
        
        container.addBorder(color: UIColor.fromRGBString(rgbString: themeData.borderColor!)!)
        rightArrow.addBorder(color: UIColor.fromRGBString(rgbString: themeData.borderColor!)!)
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.roundCorners(style: .completely)
        rightArrow.roundCorners(style: .completely)
    }

}
