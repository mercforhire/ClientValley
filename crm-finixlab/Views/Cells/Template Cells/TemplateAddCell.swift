//
//  TemplateAddCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-26.
//

import UIKit

class TemplateAddCell: UITableViewCell {
    @IBOutlet weak var buttonContainer: UIView!
    
    let addButton = RightArrowButton.fromNib()! as! RightArrowButton
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        addButton.labelButton.setTitle("Add template", for: .normal)
        buttonContainer.backgroundColor = .clear
        buttonContainer.fill(with: addButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
