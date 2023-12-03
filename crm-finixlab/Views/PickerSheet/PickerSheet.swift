//
//  AccountsPickerSheet.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-11-16.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

protocol PickerSheetDataSource: class {
    func cellHeight(pickerSheet: PickerSheet) -> CGFloat
    func numberOfRows(pickerSheet: PickerSheet) -> Int
    func cellForRowAt(pickerSheet: PickerSheet, tableView: UITableView, index: IndexPath) -> UITableViewCell
    func calculateHeight(pickerSheet: PickerSheet) -> CGFloat
}

protocol PickerSheetDelegate: class {
    func didSelectRowAt(pickerSheet: PickerSheet, tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}

class PickerSheet: UIView, ActionSheetDisplayable {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    // MARK: - Constants
    let topTableMarginHeight: CGFloat = 30.0
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: PickerSheet!
    @IBOutlet var tableView: UITableView!
    @IBOutlet private var tableViewHeightBar: NSLayoutConstraint!
    
    
    
    // MARK: - Variables
    weak var delegate: PickerSheetDelegate?
    weak var dataSource: PickerSheetDataSource?
    weak var actionSheet: ActionSheet?
    
    // MARK: - Params that needs to be set before the view is shown
    func setupUI(cell: UITableViewCell.Type) {
        Bundle.main.loadNibNamed("PickerSheet", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tableView.register(UINib(nibName: String(describing: cell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: cell.self))
        tableView.estimatedRowHeight = dataSource?.cellHeight(pickerSheet: self) ?? 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        setupTheme()
    }
    
    
    private func setupTheme() {
        guard let theme = themeManager.themeData?.teamActionSheetTheme else { return }
        
        containerView.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        tableView.reloadData()
        
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    // MARK: - Public
    
    func configure() {
        tableViewHeightBar.constant = calculateHeight() - topTableMarginHeight
        tableView.reloadData()
    }
}

extension PickerSheet {
    func calculateHeight() -> CGFloat {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.calculateHeight(pickerSheet: self)
    }
}

extension PickerSheet: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectRowAt( pickerSheet: self, tableView: tableView, didSelectRowAt: indexPath)
        actionSheet?.hide()
    }
}

extension PickerSheet: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.cellHeight(pickerSheet: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfRows(pickerSheet: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { return UITableViewCell() }
        return dataSource.cellForRowAt(pickerSheet: self, tableView:tableView, index: indexPath)
    }
}
