//
//  SignUpViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-06.
//

import UIKit
import FMSecureTextField

class SignUpViewController: BaseScrollingViewController {
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var titleLabel: ThemeImportantLabel!
    @IBOutlet weak var emailLabel: ThemeImportantLabel!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var firstNameLabel: ThemeImportantLabel!
    @IBOutlet weak var firstNameField: ThemeTextField!
    @IBOutlet weak var lastNameLabel: ThemeImportantLabel!
    @IBOutlet weak var lastNameField: ThemeTextField!
    @IBOutlet weak var passwordLabel: ThemeImportantLabel!
    @IBOutlet weak var passwordField: FMSecureTextField!

    override func setup() {
        super.setup()
        
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordField.frame.height))
        passwordField.leftViewMode = .always
        
        fieldsGroup.append(emailField)
        fieldsGroup.append(firstNameField)
        fieldsGroup.append(lastNameField)
        fieldsGroup.append(passwordField)
        
        requiredFields.append(RequiredField(fieldLabel: emailLabel, field: emailField))
        requiredFields.append(RequiredField(fieldLabel: firstNameLabel, field: firstNameField))
        requiredFields.append(RequiredField(fieldLabel: lastNameLabel, field: lastNameField))
        requiredFields.append(RequiredField(fieldLabel: passwordLabel, field: passwordField))
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        titleLabel.setupUI(overrideFontSize: 20.0)
        emailLabel.setupUI(overrideFontSize: 14.0)
        firstNameLabel.setupUI(overrideFontSize: 14.0)
        lastNameLabel.setupUI(overrideFontSize: 14.0)
        passwordLabel.setupUI(overrideFontSize: 14.0)
        passwordField.applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(_ sender: ThemeSubmitButton) {
        if validateRequiredFields(), validateEntries() {
            guard let email = emailField.text, let password = passwordField.text else { return }
            
            UserManager.shared.signUp(email: email, password: password) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.loginAndInitializeNewAccount()
                }
            }
        }
    }
    
    private func validateEntries() -> Bool {
        if (emailField.text ?? "").isEmpty {
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            showErrorDialog(error: "Invalid email format")
            return false
        }
        
        if (passwordField.text ?? "").isEmpty {
            return false
        } else if let error = PasswordValidator.validate(string: (passwordField.text ?? "")) {
            showErrorDialog(error: error)
            return false
        }
        
        return true
    }
    
    private func loginAndInitializeNewAccount() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        UserManager.shared.login(email: email, password: password) { [weak self] in
            self?.setupRealm()
            self?.performSegue(withIdentifier: "goToVerify", sender: self)
        } completion: { [weak self] success in
            if success {
                self?.setupRealm()
                StoryboardManager.load(storyboard: "Main", animated: true, completion: nil)
            }
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text else { return }
        
        if let userData = realm.objects(UserData.self).first {
            do {
                try realm.write {
                    userData.firstName = firstName
                    userData.lastName = lastName
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            let userData = UserData(partition: UserManager.shared.userPartitionKey)
            userData.firstName = firstName
            userData.lastName = lastName
            do {
                try realm.write {
                    realm.add(userData)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        }
    }
}
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = inputToolbar
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let index = fieldsGroup.firstIndex(of: textField) else {
            print("Error: \(textField) not added to searchFieldsGroup!")
            return
        }
        highlightedFieldIndex = index
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        textField.text = textField.text?.trim()
    }
}
