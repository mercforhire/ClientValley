//
//  FollowUpTemplatesViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import RealmSwift

protocol FollowUpTemplatesViewControllerDelegate: class {
    func emailTemplateChoosen(template: TemplateEmail)
    func messageTemplateChoosen(template: TemplateMessage)
}

class FollowUpTemplatesViewController: BaseViewController {
    var mode: TemplateType!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FollowUpTemplatesViewControllerDelegate?
    
    private var emailTemplates: Results<TemplateEmail>?
    private var messageTemplates: Results<TemplateMessage>?
    private var selectedEmailTemplate: TemplateEmail?
    private var selectedMessageTemplate: TemplateMessage?
    
    static func create(mode: TemplateType, delegate: FollowUpTemplatesViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpTemplatesViewController") as! FollowUpTemplatesViewController
        vc.mode = mode
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        title = mode.title()
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
    
    @objc func editTemplate(_ sender: UIButton) {
        switch mode {
        case .email:
            selectedEmailTemplate = emailTemplates![sender.tag]
        case .message:
            selectedMessageTemplate = messageTemplates![sender.tag]
        default:
            fatalError()
        }
        
        performSegue(withIdentifier: "goToEditTemplate", sender: self)
    }
    
    @objc func newTemplate(_ sender: UIButton) {
        selectedEmailTemplate = nil
        selectedMessageTemplate = nil
        performSegue(withIdentifier: "goToEditTemplate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FollowUpAddEditTemplateViewController {
            vc.emailTemplate = selectedEmailTemplate
            vc.messageTemplate = selectedMessageTemplate
            vc.mode = mode
        }
    }
    
    private func refreshView() {
        switch mode {
        case .email:
            emailTemplates = teamUserData.objects(TemplateEmail.self).sorted(byKeyPath: "lastModified", ascending: false)
        case .message:
            messageTemplates = teamUserData.objects(TemplateMessage.self).sorted(byKeyPath: "lastModified", ascending: false)
        default:
            fatalError()
        }
        tableView.reloadData()
    }
}

extension FollowUpTemplatesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .email:
            return (emailTemplates?.count ?? 0) + 1
        case .message:
            return (messageTemplates?.count ?? 0) + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var templatesCount = 0
        switch mode {
        case .email:
            templatesCount = emailTemplates?.count ?? 0
        case .message:
            templatesCount = messageTemplates?.count ?? 0
        default:
            break
        }
        
        if indexPath.row < templatesCount {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath) as? TemplateCell else {
                return TemplateCell()
            }
            switch mode {
            case .email:
                cell.config(template: emailTemplates![indexPath.row])
                cell.editButton.addTarget(self, action: #selector(editTemplate(_:)), for: .touchUpInside)
            case .message:
                cell.config(template: messageTemplates![indexPath.row])
                cell.editButton.addTarget(self, action: #selector(editTemplate(_:)), for: .touchUpInside)
            default:
                fatalError()
            }
            cell.editButton.tag = indexPath.row
            cell.border.isHidden = indexPath.row == (templatesCount - 1)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateAddCell", for: indexPath) as? TemplateAddCell else {
                return TemplateAddCell()
            }
            cell.addButton.labelButton.addTarget(self, action: #selector(newTemplate(_:)), for: .touchUpInside)
            cell.addButton.rightArrow.addTarget(self, action: #selector(newTemplate(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var templatesCount = 0
        switch mode {
        case .email:
            templatesCount = emailTemplates?.count ?? 0
        case .message:
            templatesCount = messageTemplates?.count ?? 0
        default:
            break
        }
        
        if indexPath.row < templatesCount {
            switch mode {
            case .email:
                delegate?.emailTemplateChoosen(template: emailTemplates![indexPath.row])
            case .message:
                delegate?.messageTemplateChoosen(template: messageTemplates![indexPath.row])
            default:
                fatalError()
            }
            
            backPressed(backButton)
        }
    }
}
