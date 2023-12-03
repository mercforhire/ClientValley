//
//  InsightsSingleBarTableViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-15.
//

import UIKit

class InsightsSingleBarTableViewCell: UITableViewCell {
    static let barHeight: CGFloat = 15.0
    static let barRoundCornerRadius: CGFloat = 7.5
    
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rightSection: UIView!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var barWidth: NSLayoutConstraint!
    @IBOutlet weak var countLabel: UILabel!
    
    private var data: InsightsBarsDataModel?
    private var barMaxWidth: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
        bar.layer.cornerRadius = BarCell.barHeight / 2
    }

    func setupUI() {
        guard let theme = themeManager.themeData?.insightsScreen else { return }
        
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.teamCellForegroundColor)
        container.backgroundColor = UIColor.fromRGBString(rgbString: theme.teamCellBackgroundColor)
        container.roundCorners()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeBar()
    }
    
    func resizeBar() {
        barMaxWidth = rightSection.frame.width
        
        guard let data = self.data,
              let bar = data.bars.first else { return }
        
        let percent = data.maxCount == 0 ? 0 : Float(bar.count) / Float(data.maxCount)
        let middleSectionHeight: CGFloat = (barMaxWidth - 2 * BarCell.barRoundCornerRadius) * CGFloat(percent)
        barWidth.constant = middleSectionHeight + 2 * BarCell.barRoundCornerRadius
        
    }
    
    func config(data: InsightsBarsDataModel) {
        self.data = data
        let config = AvatarImageConfiguration(image: data.teamMember.avatarImage,
                                              name: data.teamMember.initials)
        avatar.config(configuration: config)
        
        guard let data = self.data,
              let bar = data.bars.first else { return }
        
        if bar.name == InsightSelections.client.title() {
            countLabel.text = "\(bar.count) New client\(bar.count > 0 ? "s" : "")"
        } else {
            countLabel.text = "\(bar.count) \(bar.name)\(bar.count > 0 ? "s" : "")"
        }
        
        nameLabel.text = data.teamMember.fullName
        self.bar.backgroundColor = bar.color
        
        resizeBar()
    }
}
