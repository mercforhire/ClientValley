//
//  ClientProfileContactsCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit

class ClientProfileContactsCell: UITableViewCell {
    @IBOutlet weak var container1: UIView!
    let emailIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    
    @IBOutlet weak var container2: UIView!
    let phoneIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    
    @IBOutlet weak var container3: UIView!
    let messageIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    
    @IBOutlet weak var container4: UIView!
    let addressIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        container1.fill(with: emailIcon)
        container2.fill(with: phoneIcon)
        container3.fill(with: messageIcon)
        container4.fill(with: addressIcon)
        
        emailIcon.configureUI(type: ContactMethodType.email, selected: false)
        phoneIcon.configureUI(type: ContactMethodType.phone, selected: false)
        messageIcon.configureUI(type: ContactMethodType.message, selected: false)
        addressIcon.configureUI(type: ContactMethodType.address, selected: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(email: Bool, phone: Bool, message: Bool, address: Bool) {
        emailIcon.configureUI(type: ContactMethodType.email, selected: email)
        phoneIcon.configureUI(type: ContactMethodType.phone, selected: phone)
        messageIcon.configureUI(type: ContactMethodType.message, selected: message)
        addressIcon.configureUI(type: ContactMethodType.address, selected: address)
    }
}
