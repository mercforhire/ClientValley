//
//  BarCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-16.
//

import UIKit

class BarCell: UITableViewCell {
    static let CellHeight: CGFloat = 22.0
    
    static let barHeight: CGFloat = 15.0
    static let barRoundCornerRadius: CGFloat = 7.5
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var barWidth: NSLayoutConstraint!
    @IBOutlet weak var countLabel: UILabel!
    
    private var barMaxWidth: CGFloat = 0.0
    private var color: UIColor?
    private var percent: Float?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
        bar.layer.cornerRadius = BarCell.barHeight / 2
        barMaxWidth = barContainer.frame.width
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.insightsScreen else { return }
        
        bar.backgroundColor = color
        countLabel.textColor = UIColor.fromRGBString(rgbString: theme.teamCellForegroundColor)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        resizeBar()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(color: UIColor, percent: Float, count: Int) {
        self.color = color
        self.percent = percent.isNaN ? 0 : percent
        bar.backgroundColor = color
        countLabel.text = "\(count)"
        resizeBar()
    }

//    call this in:
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        DispatchQueue.main.async {
//            // the layout of the cell is ready
//        }
//    }
    func resizeBar() {
        guard let percent = percent else { return }
        barMaxWidth = barContainer.frame.width
        let middleSectionHeight: CGFloat = (barMaxWidth - 2 * BarCell.barRoundCornerRadius) * CGFloat(percent)
        barWidth.constant = middleSectionHeight + 2 * BarCell.barRoundCornerRadius
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
