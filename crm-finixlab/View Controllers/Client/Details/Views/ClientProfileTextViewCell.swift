//
//  ClientProfileTextViewCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GrowingTextView
import UILabel_Copyable

class ClientProfileTextViewCell: UITableViewCell {
    @IBOutlet weak var label: ThemeTextFieldLabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var borderView: ThemeBorderView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentLabel.isCopyingEnabled = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(title: String, content: String, border: Bool) {
        label.text = title
        contentLabel.text = content
        borderView.isHidden = !border
    }
}
