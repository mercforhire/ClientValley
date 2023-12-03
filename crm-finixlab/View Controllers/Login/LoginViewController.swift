//
//  LoginViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-14.
//

import UIKit
import RealmSwift
import FMSecureTextField
import GooglePlaces

class LoginViewController: BaseScrollingViewController {
    @IBOutlet weak var titleLabel: ThemeImportantLabel!
    @IBOutlet weak var subtitleLabel: ThemeImportantLabel!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var passwordField: FMSecureTextField!
    @IBOutlet weak var grayLabel: UILabel!
    
    var email: String? {
        get {
            return emailField.text
        }
    }

    var password: String? {
        get {
            return passwordField.text
        }
    }
    
    override func setup() {
        super.setup()
        
        grayLabel.textColor = UIColor.fromRGBString(rgbString: "rgb 129 129 129")
        
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordField.frame.height))
        passwordField.leftViewMode = .always
        
        fieldsGroup.append(emailField)
        fieldsGroup.append(passwordField)
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        titleLabel.setupUI(overrideFontSize: 20.0)
        subtitleLabel.setupUI(overrideFontSize: 14.0)
        passwordField.applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // If already logged in, go straight to the projects page for the user
        UserManager.shared.isLoggedIn(verifyFlow: { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "goToVerify", sender: self)
        }, completion: { [weak self] loggedIn in
            if loggedIn {
                self?.emailField.text = UserManager.shared.email
                StoryboardManager.load(storyboard: "Main", animated: false, completion: nil)
            }
        })
    }
    
    @IBAction func loginPressed(_ sender: ThemeSubmitButton) {
        guard let email = email, let password = password else { return }
        
        UserManager.shared.login(email: email, password: password) { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "goToVerify", sender: self)
        } completion: { success in
            
            if success {
                StoryboardManager.load(storyboard: "Main", animated: true, completion: nil)
            }
        }
    }
    
    private var tappedNumber: Int = 0 {
        didSet {
            if tappedNumber >= 10 {
                let ac = UIAlertController(title: nil, message: "Choose environment", preferredStyle: .actionSheet)
                let action1 = UIAlertAction(title: "Production\(AppSettingsManager.shared.getEnvironment() == .production ? "(Selected)" : "")", style: .default) { [weak self] action in
                    app = App(id: Environments.production.appId())
                    googlePlacesApiKey = Environments.production.googleApiKey()
                    GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
                    AppSettingsManager.shared.setEnvironment(environments: .production)
                    self?.clearFields()
                }
                ac.addAction(action1)
                
                let action2 = UIAlertAction(title: "Development\(AppSettingsManager.shared.getEnvironment() == .development ? "(Selected)" : "")", style: .default) { [weak self] action in
                    app = App(id: Environments.development.appId())
                    googlePlacesApiKey = Environments.development.googleApiKey()
                    GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
                    AppSettingsManager.shared.setEnvironment(environments: .development)
                    self?.clearFields()
                }
                ac.addAction(action2)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    self?.tappedNumber = 0
                }
                ac.addAction(cancelAction)
                present(ac, animated: true)
            }
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        tappedNumber = tappedNumber + 1
    }
    
    private func clearFields() {
        UserManager.shared.logOut {
        }
        tappedNumber = 0
    }
}

extension LoginViewController: UITextFieldDelegate {
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
