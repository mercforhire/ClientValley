//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit
protocol DialogDelegate: class {
    func buttonSelected(index: Int, dialog: Dialog)
    func dismissedDialog(dialog: Dialog)
}

struct DialogConfig {
    var title: String
    var body: String
    var primary: String
    var secondary: String?
    
    init(title: String, body: String, secondary: String?, primary: String) {
        self.title = title
        self.body = body
        self.secondary = secondary
        self.primary = primary
    }
}

class Dialog: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var dimBackground: UIView!
    @IBOutlet weak var container1: ThemeView!
    @IBOutlet weak var container2: ThemeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var secondaryButton: ThemeSecondaryButton!
    @IBOutlet weak var primaryButton: ThemeSubmitButton!
    
    // MARK: - Variables
    weak var delegate: DialogDelegate?
    
    private var selected: Date!
    private var showDimOverlay: Bool = false
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    
    private func setupUI() {
        Bundle.main.loadNibNamed("Dialog", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        dimBackground.alpha = 0
        dimBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        tutorialContainerView.alpha = 0
        tutorialContainerView.roundCorners()
        
        setupTheme()
    }
    
    private func setupTheme() {
        guard let theme = themeManager.themeData?.customDialogTheme else { return }
        
        container1.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        container2.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
        titleLabel.font = theme.title.font.toFont()
        titleLabel.textColor = UIColor.fromRGBString(rgbString: theme.title.textColor)
        
        bodyLabel.font = theme.body.font.toFont()
        bodyLabel.textColor = UIColor.fromRGBString(rgbString: theme.body.textColor)
        
        primaryButton.titleLabel?.font = theme.primary.font.toFont()
        secondaryButton.setTitleColor(UIColor.fromRGBString(rgbString: theme.secondary.textColor), for: .normal)
        
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
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    // MARK: - Public
    func configure(config: DialogConfig,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        self.showDimOverlay = showDimOverlay
        self.overUIWindow = overUIWindow
        self.titleLabel.text = config.title
        self.bodyLabel.text = config.body
        
        if config.secondary != nil {
            self.secondaryButton.setTitle(config.secondary, for: .normal)
        } else {
            self.secondaryButton.isHidden = true
        }
        self.primaryButton.setTitle(config.primary, for: .normal)
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
            self.delegate?.dismissedDialog(dialog: self)
        }
    }
    
    // MARK: - Private
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    private func hideAllViews() {
        tutorialContainerView.alpha = 0
        if showDimOverlay {
            dimBackground.alpha = 0
        }
    }
    
    private func showAllViews() {
        tutorialContainerView.alpha = 1
        if showDimOverlay {
            dimBackground.alpha = 1
        }
    }
    
    @IBAction func cancelPress(_ sender: Any) {
        hide()
        delegate?.buttonSelected(index: 0, dialog: self)
    }
    
    @IBAction func selectPress(_ sender: Any) {
        hide()
        delegate?.buttonSelected(index: 1, dialog: self)
    }
}
