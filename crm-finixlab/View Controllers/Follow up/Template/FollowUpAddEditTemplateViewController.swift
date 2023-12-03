//
//  FollowUpAddEditTemplateViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import RealmSwift
import GrowingTextView

class FollowUpAddEditTemplateViewController: BaseScrollingViewController {
    var mode: TemplateType!
    var emailTemplate: TemplateEmail?
    var messageTemplate: TemplateMessage?
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var randomButton: ThemeBarButton!
    @IBOutlet weak var nameTextView: ThemeGrowingTextView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var titleTextView: ThemeGrowingTextView!
    @IBOutlet weak var bodyTextView: ThemeGrowingTextView!
    @IBOutlet weak var editButtonsContainer: UIStackView!
    @IBOutlet weak var addButton: ThemeSubmitButton!
    
    private var newEmailTemplate: TemplateEmail?
    private var newMessageTemplate: TemplateMessage?
    
    override func setup() {
        super.setup()
    
        title = mode.title()
        
        switch mode {
        case .email:
            if emailTemplate != nil {
                addButton.isHidden = true
            } else {
                editButtonsContainer.isHidden = true
            }
        case .message:
            if messageTemplate != nil {
                addButton.isHidden = true
            } else {
                editButtonsContainer.isHidden = true
            }
            titleContainer.isHidden = true
        default:
            break
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        setupNavBar()
    }
    
    private func setupNavBar() {
        guard let theme = themeManager.themeData?.countryPickerTheme, let viewColor = themeManager.themeData?.viewColor else { return }
        
        navigationController?.navigationBar.backgroundColor = UIColor.fromRGBString(rgbString: viewColor)
        navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.fromRGBString(rgbString: theme.title.textColor)!,
             .font: theme.title.font.toFont()!]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        refreshView()
    }
    
    @IBAction func randomPressed(_ sender: Any) {
        switch mode {
        case .email:
            nameTextView.text = Lorem.sentence
            titleTextView.text = Lorem.sentence
            bodyTextView.text = Lorem.paragraphs(1...3)
        case .message:
            nameTextView.text = Lorem.sentence
            bodyTextView.text = Lorem.paragraphs(1...2)
        default:
            fatalError()
        }
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @IBAction func deletePress(_ sender: Any) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to delete this template?", secondary: "Cancel", primary: "Yes")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1 {
            do {
                try teamUserData.write {
                    switch mode {
                    case .email:
                        teamUserData.delete(emailTemplate!)
                    case .message:
                        teamUserData.delete(messageTemplate!)
                    default:
                        break
                    }
                }
                backPressed(backButton)
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func savePress(_ sender: Any) {
        do {
            try teamUserData.write {
                switch mode {
                case .email:
                    emailTemplate!.name = nameTextView.text
                    emailTemplate!.subject = titleTextView.text
                    emailTemplate!.body = bodyTextView.text
                    emailTemplate!.lastModified = Date()
                case .message:
                    messageTemplate!.name = nameTextView.text
                    messageTemplate!.message = bodyTextView.text
                    messageTemplate!.lastModified = Date()
                default:
                    break
                }
            }
            backPressed(backButton)
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
    }
    
    @IBAction func addPress(_ sender: Any) {
        do {
            try teamUserData.write {
                switch mode {
                case .email:
                    newEmailTemplate?.name = nameTextView.text
                    newEmailTemplate?.subject = titleTextView.text
                    newEmailTemplate?.body = bodyTextView.text
                    newEmailTemplate?.lastModified = Date()
                    teamUserData.add(newEmailTemplate!)
                case .message:
                    newMessageTemplate?.name = nameTextView.text
                    newMessageTemplate?.message = bodyTextView.text
                    newMessageTemplate?.lastModified = Date()
                    teamUserData.add(newMessageTemplate!)
                default:
                    break
                }
            }
            backPressed(backButton)
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
    }
    
    private func refreshView() {
        switch mode {
        case .email:
            if let selectedEmailTemplate = emailTemplate {
                nameTextView.text = selectedEmailTemplate.name
                titleTextView.text = selectedEmailTemplate.subject
                bodyTextView.text = selectedEmailTemplate.body
            } else if let newEmailTemplate = newEmailTemplate  {
                nameTextView.text = newEmailTemplate.name
                titleTextView.text = newEmailTemplate.subject
                bodyTextView.text = newEmailTemplate.body
            }
        case .message:
            if let selectedMessageTemplate = messageTemplate {
                nameTextView.text = selectedMessageTemplate.name
                bodyTextView.text = selectedMessageTemplate.message
            } else if let newMessageTemplate = newMessageTemplate {
                nameTextView.text = newMessageTemplate.name
                bodyTextView.text = newMessageTemplate.message
            }
        default:
            fatalError()
        }
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        switch mode {
        case .email:
            if emailTemplate == nil {
                newEmailTemplate = TemplateEmail(partition: UserManager.shared.teamAndUserPartitionKey)
            }
        case .message:
            if messageTemplate == nil {
                newMessageTemplate = TemplateMessage(partition: UserManager.shared.teamAndUserPartitionKey)
            }
        default:
            fatalError()
        }
    }
}

extension FollowUpAddEditTemplateViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
}
