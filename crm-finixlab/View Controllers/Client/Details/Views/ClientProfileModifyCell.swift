//
//  ClientProfileModifyCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit

class ClientProfileModifyCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    let addButton = RightArrowButton.fromNib()! as! RightArrowButton
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addButton.labelButton.setTitle("Add/Edit attributes", for: .normal)
        container.backgroundColor = .clear
        container.fill(with: addButton)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
