//
//  AccountInviteViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-07.
//

import UIKit

class AccountInviteViewController: BaseScrollingViewController {

    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var titleLabel: ThemeImportantLabel!
    @IBOutlet weak var emailLabel: ThemeTextFieldLabel!
    @IBOutlet weak var emailField: ThemeTextField!
    
    override func setup() {
        super.setup()
        
        requiredFields.append(RequiredField(fieldLabel: emailLabel, field: emailField))
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme,
              let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        guard let textFieldTheme = themeManager.themeData?.textFieldTheme else { return }
        
        titleLabel.setupUI(overrideFontSize: 18.0)
        emailLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
        emailLabel.font = textFieldTheme.font.toFont()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func validateEntries() -> Bool {
        if (emailField.text ?? "").isEmpty {
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            showErrorDialog(error: "Invalid email format")
            return false
        }
        
        return true
    }
    
    @IBAction func invitePressed(_ sender: Any) {
        view.endEditing(true)
        
        if validateRequiredFields(), validateEntries() {
            guard let email = emailField.text?.trim(), let team = UserManager.shared.currentTeam else { return }
            
            FullScreenSpinner().show()
            UserManager.shared.sendTeamInvitation(email: email, team: team) { [weak self] error in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self.backPressed(self.backButton)
                    
                    Toast.showSuccess(with: "Invitation sent")
                }
            }
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
    }
}

extension AccountInviteViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = simpleInputToolbar
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        textField.text = textField.text?.trim()
    }
}
