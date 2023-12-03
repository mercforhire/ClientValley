//
//  InsightsBarsTableViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-15.
//

import UIKit

class InsightsBarsTableViewCell: UITableViewCell {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var barsTableView: UITableView!
    @IBOutlet weak var barsTableViewHeight: NSLayoutConstraint!
    
    private var data: InsightsBarsDataModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupUI()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: InsightsBarsDataModel) {
        self.data = data
        let config = AvatarImageConfiguration(image: data.teamMember.avatarImage,
                                              name: data.teamMember.initials)
        avatar.config(configuration: config)
        barsTableViewHeight.constant = BarCell.CellHeight * CGFloat(data.bars.count)
        barsTableView.reloadData()
        nameLabel.text = data.teamMember.fullName
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

extension InsightsBarsTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.bars.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BarCell", for: indexPath) as? BarCell,
              let data = data else {
            return BarCell()
        }
        let barData = data.bars[indexPath.row]
        cell.config(color: barData.color, percent: Float(barData.count) / Float(data.maxCount), count: barData.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
