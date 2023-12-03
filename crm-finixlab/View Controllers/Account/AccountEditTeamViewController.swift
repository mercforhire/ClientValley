//
//  AccountEditTeamViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-23.
//

import UIKit

protocol AccountEditTeamViewControllerDelegate: class {
    func teamModified()
}

class AccountEditTeamViewController: BaseScrollingViewController {
    enum Mode {
        case new
        case edit
    }
    
    var mode: Mode!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var teamNameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var teamNameField: ThemeTextField!
    @IBOutlet weak var confirmButton: ThemeSubmitButton!
    @IBOutlet weak var saveButton: ThemeSubmitButton!
    @IBOutlet weak var deleteButton: ThemeDeleteButton!
    
    private var team: Team?
    weak var delegate: AccountEditTeamViewControllerDelegate?
    
    override func setup() {
        super.setup()
        
        requiredFields.append(RequiredField(fieldLabel: teamNameLabel, field: teamNameField))
        fieldsGroup.append(teamNameField)
        
        switch mode {
        case .new:
            title = "New Team"
            saveButton.isHidden = true
            deleteButton.isHidden = true
        case .edit:
            title = "Edit Team"
            confirmButton.isHidden = true
        default:
            fatalError()
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
    }
    
    static func create(mode: Mode, delegate: AccountEditTeamViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Account", viewControllerId: "AccountEditTeamViewController") as! AccountEditTeamViewController
        vc.mode = mode
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        refreshView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let theme = themeManager.themeData?.countryPickerTheme, let viewColor = themeManager.themeData?.viewColor else { return }
        
        navigationController?.navigationBar.backgroundColor = UIColor.fromRGBString(rgbString: viewColor)
        navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.fromRGBString(rgbString: theme.title.textColor)!,
             .font: theme.title.font.toFont()!]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        view.endEditing(true)
        if validateRequiredFields() {
            FullScreenSpinner().show()
            UserManager.shared.newTeam(teamName: teamNameField.text ?? "") { [weak self] error in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self.backPressed(self.backButton)
                    
                    Toast.showSuccess(with: "New team created")
                }
            }
        }
    }
    
    @IBAction func deletePress(_ sender: ThemeDeleteButton) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to delete this team? It will delete all data attached to this team.", secondary: "Cancel", primary: "Yes")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let teamRealm = teamRealm, let team = team else {
            return
        }
        view.endEditing(true)
        if validateRequiredFields() {
            do {
                try teamRealm.write {
                    team.name = teamNameField.text?.trim() ?? team.name
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
            delegate?.teamModified()
            backPressed(backButton)
        }
    }
    
    private func refreshView() {
        switch mode {
        case .edit:
            guard let team = UserManager.shared.currentTeam else { return }
            
            teamNameField.text = team.name
        default:
            break
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        guard let teamRealm = teamRealm else {
            return
        }
        
        if let team = teamRealm.objects(Team.self).first {
            self.team = team
        } else {
            backPressed(backButton)
        }
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1, let team = UserManager.shared.currentTeam {
            view.endEditing(true)
            
            FullScreenSpinner().show()
            
            UserManager.shared.deleteTeam(team: team) { [weak self] error in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self.delegate?.teamModified()
                    self.backPressed(self.backButton)
                    Toast.showSuccess(with: "Team deleted")
                }
            }
        }
    }
}
