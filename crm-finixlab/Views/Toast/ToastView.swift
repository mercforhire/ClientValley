//
//  ToastView.swift
//  Phoenix
//
//  Created by Illya Gordiyenko on 2018-06-06.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

class ToastView: UIView {
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ToastView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        configureUI()
    }
    
    func configureUI() {
        guard let theme = ThemeManager.shared.themeData?.toastTheme else { return }
        
        containerView.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        descriptionLabel.font = theme.font.toFont()
        descriptionLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        
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
}
