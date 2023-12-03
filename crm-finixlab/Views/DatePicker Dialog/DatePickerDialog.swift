//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit
import MonthYearPicker

protocol DatePickerDialogDelegate: class {
    func dateSelected(date: Date, dialog: DatePickerDialog)
    func dismissedDialog(dialog: DatePickerDialog)
}

enum DatePickerDialogMode : Int {
    
    case time = 0

    case date = 1

    case dateAndTime = 2

    case month = 3
}

class DatePickerDialog: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: DropdownMenu!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var dimBackground: UIView!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet weak var monthPicker: MonthYearPickerView!
    
    // MARK: - Variables
    weak var delegate: DatePickerDialogDelegate?
    
    private var selected: Date!
    private var showDimOverlay: Bool = false
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    
    private func setupUI() {
        Bundle.main.loadNibNamed("DatePickerDialog", owner: self, options: nil)
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
        guard let theme = themeManager.themeData?.datePickerTheme else { return }
        
        datePicker.setValue(UIColor.fromRGBString(rgbString:theme.row.textColor), forKey: "textColor")
        datePicker.tintColor = UIColor.fromRGBString(rgbString:theme.row.textColor)
        datePicker.backgroundColor = UIColor.fromRGBString(rgbString:theme.backgroundColor)
        
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
    func configure(mode: DatePickerDialogMode = .date,
                   selected: Date,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        self.selected = selected
        self.showDimOverlay = showDimOverlay
        self.overUIWindow = overUIWindow
        
        if mode == .month {
            monthPicker.date = selected
            monthPicker.addTarget(self, action: #selector(monthPickerValueChanged(_:)), for: .valueChanged)
            datePicker.isHidden = true
        } else {
            datePicker.date = selected
            datePicker.datePickerMode = UIDatePicker.Mode(rawValue: mode.rawValue) ?? .date
            monthPicker.isHidden = true
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
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        selected = sender.date
    }
    
    @objc func monthPickerValueChanged(_ sender: MonthYearPickerView) {
        selected = sender.date
    }
    
    @IBAction func cancelPress(_ sender: Any) {
        hide()
        delegate?.dismissedDialog(dialog: self)
    }
    
    @IBAction func selectPress(_ sender: Any) {
        hide()
        delegate?.dateSelected(date: selected, dialog: self)
    }
}
