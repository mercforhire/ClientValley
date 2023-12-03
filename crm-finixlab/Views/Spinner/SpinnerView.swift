//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import Foundation
import UIKit
import JTMaterialSpinner

class SpinnerView: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    private let animationView = JTMaterialSpinner()
    private(set) var isAnimationPlaying = false
    private let animationViewSide: CGFloat = 50.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = themeManager.theme == .light ? UIColor(white: 1.0, alpha: 0.6) : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        addSubview(animationView)
        
        // Customize the line width
        animationView.circleLayer.lineWidth = 2.0
        
        // Change the color of the line
        animationView.circleLayer.strokeColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.mailRecipientCellTheme.textColor)?.cgColor
        
        // Change the duration of the animation
        animationView.animationDuration = 2.5
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive  = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive  = true
        animationView.heightAnchor.constraint(equalToConstant: animationViewSide).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: animationViewSide).isActive = true
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func startAnimation(bgAlpha: CGFloat = 0.6) {
        backgroundColor = themeManager.theme == .light ? UIColor(white: 1.0, alpha: bgAlpha) : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: bgAlpha)
        animationView.beginRefreshing()
        isAnimationPlaying = true
    }
    
    func stopAnimation() {
        animationView.endRefreshing()
        isAnimationPlaying = false
    }
}
