//
//  ClientAddStep3ViewControllerViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-12.
//

import UIKit
import RealmSwift

class ClientAddStep3ViewController: BaseViewController {

    private var tempClient: TempClient! {
        didSet {
            mailSection.configureUI(selected: tempClient.contactMethod?.byMail ?? false)
            phoneSection.configureUI(selected: tempClient.contactMethod?.byPhone ?? false)
            emailSection.configureUI(selected: tempClient.contactMethod?.byEmail ?? false)
            messagesSection.configureUI(selected: tempClient.contactMethod?.byMessage ?? false)
        }
    }
    private var userData: UserData!
    private var notificationToken: NotificationToken?
    
    @IBOutlet weak var scrollView: ThemeScrollView!
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var quitButton: ThemeBarButton!
    @IBOutlet weak var agreementLabel: ThemeSmallLabel!
    
    @IBOutlet weak var mailSectionContainer: UIView!
    private let mailSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var photoSectionContainer: UIView!
    private let phoneSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var emailSectionContainer: UIView!
    private let emailSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var messagesSectionContainer: UIView!
    private let messagesSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var privacyContainer: UIView!
    @IBOutlet weak var privacyIcon: UIButton!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var viewTermsButtonContainer: UIView!
    private let viewTermsButton = SmallRightArrowButton.fromNib()! as! SmallRightArrowButton
    @IBOutlet weak var completeButton: ThemeSubmitButton!
    
    private var agree: Bool = false {
        didSet {
            guard let theme = themeManager.themeData?.checkboxSectionTheme else { return }
            
            if agree {
                privacyContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.checkedBackgroundColor)
                privacyLabel.textColor = UIColor.fromRGBString(rgbString: theme.checkedTextColor)
                privacyIcon.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                privacyIcon.tintColor = UIColor.fromRGBString(rgbString: theme.checkedCheckboxColor)
            } else {
                privacyContainer.backgroundColor = UIColor.fromRGBString(rgbString: theme.uncheckedBackgroundColor)
                privacyLabel.textColor = UIColor.fromRGBString(rgbString: theme.uncheckedTextColor)
                privacyIcon.setImage(UIImage(systemName: "circle"), for: .normal)
                privacyIcon.tintColor = UIColor.fromRGBString(rgbString: theme.uncheckedCheckboxColor)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        mailSection.label.text = "Mail"
        phoneSection.label.text = "Phone"
        emailSection.label.text = "Email"
        messagesSection.label.text = "Mobile Messaging"
        mailSectionContainer.fill(with: mailSection)
        photoSectionContainer.fill(with: phoneSection)
        emailSectionContainer.fill(with: emailSection)
        messagesSectionContainer.fill(with: messagesSection)
        
        mailSection.button.addTarget(self, action: #selector(mailSectionPress), for: .touchUpInside)
        phoneSection.button.addTarget(self, action: #selector(phoneSectionPress), for: .touchUpInside)
        emailSection.button.addTarget(self, action: #selector(emailSectionPress), for: .touchUpInside)
        messagesSection.button.addTarget(self, action: #selector(messageSectionPress), for: .touchUpInside)
        
        viewTermsButton.labelButton.setTitle("View full Privacy Policy", for: .normal)
        viewTermsButton.labelButton.addTarget(self, action: #selector(viewTerms), for: .touchUpInside)
        viewTermsButtonContainer.backgroundColor = .clear
        viewTermsButtonContainer.fill(with: viewTermsButton)
        
        privacyContainer.roundCorners()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let checkboxSectionTheme = themeManager.themeData?.checkboxSectionTheme else { return }
        
        privacyLabel.font = checkboxSectionTheme.font.toFont(overrideSize: 13.0)
        agree = { agree }()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        agreementLabel.text = agreementLabel.text?.replacingOccurrences(of: "COMPANY NAME", with: userData.fullName)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.roundSelectedCorners(corners: [.topLeft, .topRight], radius: 25.0)
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    @objc func mailSectionPress() {
        guard let contactMethod = tempClient?.contactMethod else { return }
        
        do {
            try realm.write {
                contactMethod.byMail = !contactMethod.byMail
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func phoneSectionPress() {
        guard let contactMethod = tempClient?.contactMethod else { return }
        
        do {
            try realm.write {
                contactMethod.byPhone = !contactMethod.byPhone
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func emailSectionPress() {
        guard let contactMethod = tempClient?.contactMethod else { return }
        
        do {
            try realm.write {
                contactMethod.byEmail = !contactMethod.byEmail
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func messageSectionPress() {
        guard let contactMethod = tempClient?.contactMethod else { return }
        
        do {
            try realm.write {
                contactMethod.byMessage = !contactMethod.byMessage
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func agreePress(_ sender: Any) {
        agree = !agree
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(TempClient.self).isEmpty {
            tempClient = TempClient(partition: UserManager.shared.userPartitionKey)
            
            do {
                try realm.write {
                    realm.add(tempClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            tempClient = realm.objects(TempClient.self).first
        }
        
        userData = UserManager.shared.userData
        
        notificationToken = tempClient.contactMethod?.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.mailSection.configureUI(selected: self?.tempClient.contactMethod?.byMail ?? false)
                self?.phoneSection.configureUI(selected: self?.tempClient.contactMethod?.byPhone ?? false)
                self?.emailSection.configureUI(selected: self?.tempClient.contactMethod?.byEmail ?? false)
                self?.messagesSection.configureUI(selected: self?.tempClient.contactMethod?.byMessage ?? false)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
    }
    
    @IBAction func completePressed(_ sender: ThemeSubmitButton) {
        if !agree {
            showErrorDialog(error: "Please read and agree to the Privacy Policy")
            return
        }
        
        let newClient = Client(partition: UserManager.shared.teamPartitionKey, tempClient: tempClient)
        newClient.creator = app.currentUser!.id
        do {
            try teamData.write {
                teamData.add(newClient)
            }
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
        
        do {
            try realm.write {
                realm.delete(tempClient)
                navigationController?.popToRootViewController(animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    NotificationCenter.default.post(name: Notifications.OpenClientProfile, object: self, userInfo: ["clientId": newClient._id])
                }
            }
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
    }
    
    @objc func viewTerms() {
        openURLInBrowser(url: URL(string: "http://finixlab-inc.com/product/clientvalley/about.html")!)
    }
}
