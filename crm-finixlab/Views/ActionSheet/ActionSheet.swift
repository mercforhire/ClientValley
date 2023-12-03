//
//  ActionSheet.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-11-15.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//
import UIKit

class ActionSheet: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    
    // MARK: - IBOutlets
    @IBOutlet private var parentContainerView: ActionSheet!
    @IBOutlet private var actionSheetView: RoundedCornersView!
    @IBOutlet private var actionSheetContainerView: UIView!
    @IBOutlet private var actionSheetContainerViewHeight: NSLayoutConstraint!
    @IBOutlet private var actionSheetContainerTop: NSLayoutConstraint!
    @IBOutlet private var clickableDimBackGround: UIView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var topBarView: UIView!
    
    // MARK: - Params that needs to be set before the view is shown
    
    var content: ActionSheetDisplayable? {
        didSet {
            content?.actionSheet = self
        }
    }
    
    private func setupUI() {
        Bundle.main.loadNibNamed("ActionSheet", owner: self, options: nil)
        addSubview(parentContainerView)
        parentContainerView.frame = self.bounds
        parentContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        topBarView.layer.cornerRadius = 2.0
        clickableDimBackGround.alpha = 0
        clickableDimBackGround.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        actionSheetView.corners = [.topLeft, .topRight]
        actionSheetView.radius = 7.0
        actionSheetContainerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))

        setupTheme()
    }
    
    private func setupTheme() {
        guard let theme = themeManager.themeData?.teamActionSheetTheme else { return }
        
        topBarView.backgroundColor = UIColor.fromRGBString(rgbString: theme.dragBarColor)
        actionSheetView.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        frame.size.height = superview?.bounds.size.height ?? 0
        frame.size.width = superview?.bounds.size.width ?? 0
        
        if let content = content as? UIView, let actionSheet = content as? ActionSheetDisplayable {
            actionSheetContainerView.fill(with: content)
            actionSheetContainerViewHeight.constant = actionSheet.calculateHeight()
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    // MARK: - Public
    
    func show(inView view: UIView, withDelay milliseconds: Int = 10) {
        view.addSubview(self)
        
        func animateAndShow() {
            UIView.animate(withDuration: animationInterval) {
                self.clickableDimBackGround.alpha = 1.0
                self.actionSheetContainerTop.constant = -(self.actionSheetHeight())
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                self.layoutIfNeeded()
            }
        }
        
        if milliseconds == 0 {
            animateAndShow()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: animateAndShow)
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: animationInterval,
                       animations: {
            self.clickableDimBackGround.alpha = 0.0
            self.actionSheetContainerTop.constant = 0
            self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
    
    // MARK: - Private
    
    private func actionSheetHeight() -> CGFloat {
        guard let content = content, let footerView = footerView else { return 0 }
        
        return content.calculateHeight() + footerView.frame.height
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: actionSheetContainerView)
        if translation.y > 0 {
            if recognizer.state == .changed {
                actionSheetContainerTop.constant = -(actionSheetHeight() - translation.y)
            } else if recognizer.state == .ended {
                // if the user dragged it down more than 1/3, count it as a dismiss, otherwise snap it back up
                if translation.y > (actionSheetHeight() / 3) {
                    hide()
                } else {
                    UIView.animate(withDuration: animationInterval / 2) {
                        self.actionSheetContainerTop.constant = -(self.actionSheetHeight())
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
}
