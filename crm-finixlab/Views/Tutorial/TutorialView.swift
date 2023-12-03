//
//  TutorialView.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-12-06.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

protocol TutorialViewDelegate: class {
    func dismissedTutorial(tutorialView: TutorialView)
}

class TutorialView: UIView {
    enum PointingDirection {
        case up
        case down
    }
    
    enum PointingPosition {
        case edge
        case center
    }
    
    // MARK: - Constants
    private let themeManager = ThemeManager.shared
    
    private let animationInterval: Double = 0.45
    private let triangleHeight: CGFloat = 11.5
    private let triangleWidth: CGFloat = 20.0
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: TutorialView!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var bodyTextLabel: UILabel!
    @IBOutlet private var topTriangle: TriangleView!
    @IBOutlet private var bottomTriangle: TriangleView!
    @IBOutlet private var topMargin: NSLayoutConstraint!
    @IBOutlet private var distanceTopToTutorialBottom: NSLayoutConstraint!
    @IBOutlet private var dimBackground: UIView!
    
    @IBOutlet weak var bottomTrianglePositionX: NSLayoutConstraint!
    @IBOutlet weak var topTrianglePositionX: NSLayoutConstraint!
    
    // MARK: - Variables
    weak var delegate: TutorialViewDelegate?
    
    private var observer: NSObjectProtocol?
    private var showDimOverlay: Bool = false
    private var targetFrame: CGRect?
    
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    
    private func setupUI() {
        Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        dimBackground.alpha = 0
        dimBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        tutorialContainerView.alpha = 0
        tutorialContainerView.roundCorners(style: .medium)
        
        bodyTextLabel.text = ""
        
        topTriangle.direction = .up
        topTriangle.alpha = 0
        
        bottomTriangle.direction = .down
        bottomTriangle.alpha = 0
        
        topTriangle.backgroundColor = UIColor.clear
        bottomTriangle.backgroundColor = UIColor.clear
        
        setupTheme()
    }
    
    private func setupTheme() {
        guard let theme = themeManager.themeData?.tutorialTheme else { return }
        
        bodyTextLabel.textColor = UIColor.fromRGBString(rgbString: theme.textColor)

        topTriangle.fillColor = UIColor.fromRGBString(rgbString: theme.bubbleBackgroundColor)
        bottomTriangle.fillColor = UIColor.fromRGBString(rgbString: theme.bubbleBackgroundColor)
        tutorialContainerView.backgroundColor = UIColor.fromRGBString(rgbString: theme.bubbleBackgroundColor)

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        frame.size.height = UIScreen.main.bounds.size.height
        frame.size.width = UIScreen.main.bounds.size.width
    }
    
    // MARK: - Public
    func configure(tutorialStep: TutorialStep) {
        configure(body: tutorialStep.body,
                  pointingDirection: tutorialStep.pointingDirection,
                  pointPosition: tutorialStep.pointPosition,
                  targetFrame: tutorialStep.targetFrame,
                  arrowOfset: tutorialStep.arrowOffset,
                  showDimOverlay: tutorialStep.showDimOverlay,
                  overUIWindow: tutorialStep.overUIWindow)
    }
    
    func configure(body: String,
                   pointingDirection: PointingDirection,
                   pointPosition: PointingPosition,
                   targetFrame: CGRect?,
                   arrowOfset: CGFloat? = nil,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        bodyTextLabel.text = body

        self.showDimOverlay = showDimOverlay
        self.targetFrame = targetFrame
        self.overUIWindow = overUIWindow
        
        // cut a hole in the dim overlay to allow the highlighted area shine through
        if !showDimOverlay {
            // draw shadows on the tutorial bubble
            tutorialContainerView.layer.applySketchShadow(color: UIColor.lightGray, alpha: 0.25, x: 0, y: 2, blur: 12, spread: 0)
        }
        
        if let targetFrame = targetFrame {
            let arrowXConstant = arrowOfset ?? ( targetFrame.origin.x + targetFrame.size.width / 2) - triangleWidth / 2

            switch pointingDirection {
            case .up:
                topTriangle.isHidden = false
                bottomTriangle.isHidden = true
                distanceTopToTutorialBottom.isActive = false
                
                switch pointPosition {
                case .edge:
                    topMargin.constant = targetFrame.origin.y + targetFrame.size.height + triangleHeight + edgeMargin
                case .center:
                    topMargin.constant = targetFrame.origin.y + (targetFrame.size.height / 2) + triangleHeight
                }
                topTrianglePositionX.constant = arrowXConstant
            case .down:
                topTriangle.isHidden = true
                bottomTriangle.isHidden = false
                topMargin.isActive = false
                
                switch pointPosition {
                case .edge:
                    distanceTopToTutorialBottom.constant = -1 * (targetFrame.origin.y - triangleHeight - edgeMargin)
                case .center:
                    distanceTopToTutorialBottom.constant = -1 * (targetFrame.origin.y + (targetFrame.size.height / 2) - triangleHeight)
                }
                bottomTrianglePositionX.constant = arrowXConstant
            }
        } else {
            topTriangle.isHidden = true
            bottomTriangle.isHidden = true
            
            topMargin.isActive = false
            distanceTopToTutorialBottom.isActive = false
            bottomTrianglePositionX.isActive = false
            
            tutorialContainerView.translatesAutoresizingMaskIntoConstraints = false
            tutorialContainerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        }
    }
    
    func show(inView view: UIView, withDelay milliseconds: Int = 0) {
        if overUIWindow {
            guard let window = UIViewController.window else { return }
            
            window.addSubview(self)
        } else {
            view.addSubview(self)
        }
        
        func animateAndShow() {
            UIView.animate(withDuration: animationInterval) {
                self.showAllViews()
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
                        self.hideAllViews()
                        self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            self.delegate?.dismissedTutorial(tutorialView: self)
        }
    }
    
    // MARK: - Private
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @objc private func tabBarPressed() {
        hide()
    }
    
    private func hideAllViews() {
        tutorialContainerView.alpha = 0
        topTriangle.alpha = 0
        bottomTriangle.alpha = 0
        if showDimOverlay {
            dimBackground.alpha = 0
        }
    }
    
    private func showAllViews() {
        // cut a hole in the dim overlay to allow the highlighted area shine through
        if let targetFrame = targetFrame, showDimOverlay {
            dimBackground.drawHole(hole: targetFrame, style: .medium, border: themeManager.theme == .dark)
        }
        
        tutorialContainerView.alpha = 1
        topTriangle.alpha = 1
        bottomTriangle.alpha = 1
        
        if showDimOverlay {
            dimBackground.alpha = 1
        }
    }
}
