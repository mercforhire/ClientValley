//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

protocol DropdownMenuDelegate: class {
    func dropdownSelected(selected: String, menu: DropdownMenu)
    func dismissedMenu(menu: DropdownMenu)
}

class DropdownMenu: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    private let triangleHeight: CGFloat = 11.5
    private let triangleWidth: CGFloat = 20.0
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: DropdownMenu!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var topTriangle: TriangleView!
    @IBOutlet private var topMargin: NSLayoutConstraint!
    @IBOutlet private var menuHeight: NSLayoutConstraint!
    @IBOutlet private var dimBackground: UIView!
    @IBOutlet private var topTrianglePositionX: NSLayoutConstraint!
    
    // MARK: - Variables
    weak var delegate: DropdownMenuDelegate?
    
    private var selections: [String] = []
    private var selected: String?
    private var showDimOverlay: Bool = false
    private var targetFrame: CGRect = CGRect.zero
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    
    private func setupUI() {
        Bundle.main.loadNibNamed("DropdownMenu", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        dimBackground.alpha = 0
        dimBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        tutorialContainerView.alpha = 0
        tutorialContainerView.roundCorners()
        
        topTriangle.backgroundColor = .clear
        topTriangle.direction = .up
        topTriangle.alpha = 0
        
        tableView.register(UINib(nibName: "DropdownMenuCell", bundle: Bundle.main), forCellReuseIdentifier: "DropdownMenuCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.roundCorners()
        
        setupTheme()
    }
    
    private func setupTheme() {
        guard let theme = themeManager.themeData?.dropdownMenuTheme else { return }
        
        topTriangle.color = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
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
    func configure(selections: [String],
                   selected: String?,
                   targetFrame: CGRect,
                   arrowOfset: CGFloat? = nil,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        self.selections = selections
        self.selected = selected
        self.showDimOverlay = showDimOverlay
        self.targetFrame = targetFrame
        self.overUIWindow = overUIWindow
        
        // cut a hole in the dim overlay to allow the highlighted area shine through
        if !showDimOverlay {
            // draw shadows on the tutorial bubble
            tutorialContainerView.layer.applySketchShadow(color: UIColor.black, alpha: 0.25, x: 0, y: 2, blur: 12, spread: 0)
        }
        
        let arrowXConstant = arrowOfset ?? ( targetFrame.origin.x + targetFrame.size.width / 2) - triangleWidth / 2

        topMargin.constant = targetFrame.origin.y + targetFrame.size.height + triangleHeight + edgeMargin
        topTrianglePositionX.constant = arrowXConstant
        menuHeight.constant = DropdownMenuCell.height * CGFloat(selections.count)
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
            self.delegate?.dismissedMenu(menu: self)
        }
    }
    
    // MARK: - Private
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    private func hideAllViews() {
        tutorialContainerView.alpha = 0
        topTriangle.alpha = 0
        if showDimOverlay {
            dimBackground.alpha = 0
        }
    }
    
    private func showAllViews() {
        // cut a hole in the dim overlay to allow the highlighted area shine through
        if showDimOverlay {
            dimBackground.drawHole(hole: targetFrame, style: nil, border: false)
        }
        
        tutorialContainerView.alpha = 1
        topTriangle.alpha = 1
        if showDimOverlay {
            dimBackground.alpha = 1
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

extension DropdownMenu: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownMenuCell", for: indexPath) as? DropdownMenuCell else {
            return DropdownMenuCell()
        }
        let selectionText = selections[indexPath.row]
        cell.config(text: selectionText, selected: selectionText == selected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DropdownMenuCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionText = selections[indexPath.row]
        selected = selectionText
        tableView.reloadData()
        delegate?.dropdownSelected(selected: selectionText, menu: self)
        hide()
    }
}
