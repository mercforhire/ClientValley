//
//  ResetPasswordViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-14.
//

import UIKit
import RealmSwift

class ResetPasswordViewController: BaseScrollingViewController {
    @IBOutlet weak var backButton: ThemeBarButton!
    
    @IBOutlet var titleLabels: [ThemeImportantLabel]!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var code1Field: UITextField!
    @IBOutlet weak var code2Field: UITextField!
    @IBOutlet weak var code3Field: UITextField!
    @IBOutlet weak var code4Field: UITextField!
    @IBOutlet weak var code5Field: UITextField!
    @IBOutlet weak var code6Field: UITextField!
    @IBOutlet weak var passwordField: ThemeTextField!
    
    override func setup() {
        super.setup()
        
        code1Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code3Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code4Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code5Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code6Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fieldsGroup.append(emailField)
        fieldsGroup.append(code1Field)
        fieldsGroup.append(code2Field)
        fieldsGroup.append(code3Field)
        fieldsGroup.append(code4Field)
        fieldsGroup.append(code5Field)
        fieldsGroup.append(code6Field)
        fieldsGroup.append(passwordField)
        
        requiredFields.append(RequiredField(fieldLabel: titleLabels.first!, field: emailField))
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        for label in titleLabels {
            label.setupUI(overrideFontSize: 14.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resendPressed(_ sender: Any) {
        if validateRequiredFields() {
            FullScreenSpinner().show()
            let client = app.emailPasswordAuth
            client.callResetPasswordFunction(email: emailField.text ?? "", password: "12345678", args: []) { [weak self] error in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    FullScreenSpinner().hide()
                    
                    if let _ = error {
                        showErrorDialog(error: "User with email \(self.emailField.text ?? "") not found.")
                    } else {
                        showErrorDialog(error: "Code sent to \(self.emailField.text ?? "")")
                    }
                }
            }
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        guard validateRequiredFields() else { return }
        
        guard let digit1 = code1Field.text, let digit2 = code2Field.text,
              let digit3 = code3Field.text, let digit4 = code4Field.text,
              let digit5 = code5Field.text, let digit6 = code6Field.text,
              !digit1.isEmpty, !digit2.isEmpty, !digit3.isEmpty,
              !digit4.isEmpty, !digit5.isEmpty, !digit6.isEmpty else {
            showErrorDialog(error: "Invalid code entry")
            return
        }
        
        if let error = PasswordValidator.validate(string: passwordField.text ?? "") {
            showErrorDialog(error: error)
            return
        }
        
        let verifyCode = "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")\(code4Field.text ?? "")\(code5Field.text ?? "")\(code6Field.text ?? "")"
        
        let client = app.emailPasswordAuth
        client.callResetPasswordFunction(email: emailField.text ?? "", password: passwordField.text ?? "", args: [AnyBSON(verifyCode)]) { error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let _ = error {
                    showErrorDialog(error: "Verification code is incorrect")
                } else {
                    let ac = UIAlertController(title: "", message: "Password successfully changed!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    ac.addAction(action)
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    private func onResendPressedOperationComplete(result: AnyBSON?, realmError: Error?) {
        DispatchQueue.main.async {
            // Always be sure to stop the activity indicator
            FullScreenSpinner().hide()

            // There are two kinds of errors:
            // - The Realm function call itself failed (for example, due to network error)
            // - The Realm function call succeeded, but our business logic within the function returned an error,
            //   (for example, user is not a member of the team).
            var errorMessage: String?

            if realmError != nil {
                // Error from Realm (failed function call, network error...)
                errorMessage = realmError!.localizedDescription
            } else if let resultDocument = result?.documentValue {
                // Check for user error. The addTeamMember function we defined returns an object
                // with the `error` field set if there was a user error.
                errorMessage = resultDocument["error"]??.stringValue
            }

            // Present error message if any
            guard errorMessage == nil else {
                showErrorDialog(error: "Resend email failed: \(errorMessage!)")
                return
            }
            
            if result?.boolValue == true {
                showErrorDialog(error: "Verification email sent")
            }
        }
    }
    
    private func onValidateSecurityQuestionAnswerComplete(result: AnyBSON?, realmError: Error?) {
        DispatchQueue.main.async {
            // Always be sure to stop the activity indicator
            FullScreenSpinner().hide()

            // There are two kinds of errors:
            // - The Realm function call itself failed (for example, due to network error)
            // - The Realm function call succeeded, but our business logic within the function returned an error,
            //   (for example, user is not a member of the team).
            var errorMessage: String?

            if realmError != nil {
                // Error from Realm (failed function call, network error...)
                errorMessage = realmError!.localizedDescription
            } else if let resultDocument = result?.documentValue {
                // Check for user error. The addTeamMember function we defined returns an object
                // with the `error` field set if there was a user error.
                errorMessage = resultDocument["error"]??.stringValue
            }

            // Present error message if any
            guard errorMessage == nil else {
                showErrorDialog(error: "Verify email code failed: \(errorMessage!)")
                return
            }
            
            if result?.boolValue == true {
                showErrorDialog(error: "Code is right!")
            } else if result?.boolValue == false {
                showErrorDialog(error: "Incorrect email verification code")
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == code1Field {
            if (textfield.text ?? "").isEmpty {
            } else {
                code2Field.becomeFirstResponder()
            }
        } else if textfield == code2Field {
            if (textfield.text ?? "").isEmpty {
                code1Field.becomeFirstResponder()
            } else {
                code3Field.becomeFirstResponder()
            }
        } else if textfield == code3Field {
            if (textfield.text ?? "").isEmpty {
                code2Field.becomeFirstResponder()
            } else {
                code4Field.becomeFirstResponder()
            }
        } else if textfield == code4Field {
            if (textfield.text ?? "").isEmpty {
                code3Field.becomeFirstResponder()
            } else {
                code5Field.becomeFirstResponder()
            }
        } else if textfield == code5Field {
            if (textfield.text ?? "").isEmpty {
                code4Field.becomeFirstResponder()
            } else {
                code6Field.becomeFirstResponder()
            }
        } else if textfield == code6Field {
            if (textfield.text ?? "").isEmpty {
                code5Field.becomeFirstResponder()
            }
        }
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
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
    }
}
