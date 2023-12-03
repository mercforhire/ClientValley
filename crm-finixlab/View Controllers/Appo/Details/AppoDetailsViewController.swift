//
//  AppoDetailsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-31.
//

import UIKit
import UILabel_Copyable

class AppoDetailsViewController: BaseScrollingViewController {
    var appo: Appo!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var editButton: ThemeBarButton!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: ThemeImportantLabel!
    @IBOutlet weak var clientIDLabel: ThemeImportantLabel!
    @IBOutlet weak var rightArrowButton: UIButton!
    
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var appoTypeLabel: UILabel!
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var icon5: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var amountContainer: UIView!
    @IBOutlet weak var amountLabel: ThemeTextFieldLabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    private var client: Client?
    
    override func setup() {
        super.setup()
        
        nameLabel.text = ""
        
        clientIDLabel.text = ""
        clientIDLabel.isCopyingEnabled = true
        
        rightArrowButton.roundCorners(style: .completely)
        
        icon1.roundCorners()
        icon2.roundCorners()
        icon3.roundCorners()
        icon4.roundCorners()
        icon5.roundCorners()
        
        timeLabel.text = ""
        timeLabel.isCopyingEnabled = true
        
        appoTypeLabel.text = ""
        
        emailContainer.isHidden = true
        emailLabel.text = ""
        emailLabel.isCopyingEnabled = true
        
        phoneContainer.isHidden = true
        phoneLabel.text = ""
        phoneLabel.isCopyingEnabled = true
        
        addressContainer.isHidden = true
        addressLabel.text = ""
        addressLabel.isCopyingEnabled = true
        
        amountLabel.text = ""
        amountLabel.isCopyingEnabled = true
        
        notesLabel.text = ""
        notesLabel.isCopyingEnabled = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let textFieldTheme = themeManager.themeData?.textFieldTheme else { return }
        guard let theme = themeManager.themeData?.appoDetailsScreen else { return }
        
        nameLabel.textColor = UIColor.fromRGBString(rgbString: theme.profileLabelsTextColor)
        
        clientIDLabel.textColor = UIColor.fromRGBString(rgbString: theme.profileLabelsTextColor)
        
        rightArrowButton.backgroundColor = UIColor.fromRGBString(rgbString: theme.profileButtonColor)
        
        icon1.backgroundColor = UIColor.fromRGBString(rgbString: theme.infoIconColor)
        icon2.backgroundColor = UIColor.fromRGBString(rgbString: theme.infoIconColor)
        icon3.backgroundColor = UIColor.fromRGBString(rgbString: theme.infoIconColor)
        icon4.backgroundColor = UIColor.fromRGBString(rgbString: theme.infoIconColor)
        icon5.backgroundColor = UIColor.fromRGBString(rgbString: theme.infoIconColor)
        
        timeLabel.font = textFieldTheme.font.toFont()
        timeLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
        
        appoTypeLabel.font = textFieldTheme.font.toFont()
        appoTypeLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
        
        amountLabel.font = textFieldTheme.font.toFont()
        amountLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
        
        notesLabel.font = textFieldTheme.font.toFont()
        notesLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    private func refreshView() {
        client = teamData.objects(Client.self).filter("_id == %@", appo.clientId).first
        
        guard let client = client else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let config = AvatarImageConfiguration(image: client.avatarImage,
                                              name: client.avatar == nil ? client.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = client.fullName
        clientIDLabel.text = "#\(client.clientID)"
        timeLabel.text = "\(DateUtil.convert(input: appo.startTime, outputFormat: .format8)!) - \(DateUtil.convert(input: appo.endTime, outputFormat: .format8)!), \(DateUtil.convert(input: appo.startTime, outputFormat: .format12)!)"
        appoTypeLabel.text = AppoType(rawValue: appo.type)?.rawValue
        
        if let email = client.email, !email.isEmpty {
            emailContainer.isHidden = false
            emailLabel.text = email
        }
        
        if let phone = client.phone, !phone.phone.isEmpty {
            phoneContainer.isHidden = false
            phoneLabel.text = phone.getFormattedString()
        }
        
        if let address = client.address, !(address.address?.isEmpty ?? true) {
            addressContainer.isHidden = false
            addressLabel.text = address.fullAddress()
        }
        
        if let estimateAmount = appo.estimateAmount {
            amountLabel.text = "$\(String(format: "%.2f", estimateAmount))"
            amountContainer.isHidden = false
        } else {
            amountContainer.isHidden = true
        }
        
        notesLabel.text = appo.notes
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AppoNewOrEditViewController {
            vc.mode = .editAppo(appo)
        } else if let client = client, let vc = segue.destination as? ClientProfileViewController {
            vc.client = client
        }
    }
}
