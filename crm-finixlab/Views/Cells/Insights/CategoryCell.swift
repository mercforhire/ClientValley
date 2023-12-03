//
//  CategoryCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-15.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        guard let theme = themeManager.themeData?.insightsScreen else { return }
        
        button.setTitleColor(UIColor.fromRGBString(rgbString: theme.teamCellForegroundColor), for: .normal)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(selection: InsightSelections) {
        button.tintColor = selection.dotColor()
        
        UIView.performWithoutAnimation {
            self.button.setTitle("  " + selection.title(), for: .normal)
            self.button.layoutIfNeeded()
        }
    }
    
    func config(selection: FollowUpTypes) {
        button.tintColor = selection.dotColor()
        
        UIView.performWithoutAnimation {
            self.button.setTitle("  " + selection.title(), for: .normal)
            self.button.layoutIfNeeded()
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
