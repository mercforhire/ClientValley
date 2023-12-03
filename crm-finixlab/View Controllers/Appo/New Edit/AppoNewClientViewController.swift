//
//  AppoNewClientViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-01.
//

import UIKit
import RealmSwift
import SKCountryPicker

class AppoNewClientViewController: BaseScrollingViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var civilityContainer: UIView!
    @IBOutlet weak var civilityLabel: ThemeTextFieldLabel!
    @IBOutlet weak var civilityField: ThemeTextField!
    @IBOutlet weak var civilityDropButton: DropdownButton!
    @IBOutlet weak var firstnameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var firstNameField: ThemeTextField!
    @IBOutlet weak var lastNameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var lastnameField: ThemeTextField!
    @IBOutlet weak var countryContainer: UIView!
    @IBOutlet weak var countryField: ThemeTextField!
    @IBOutlet weak var countryDropButton: DropdownButton!
    @IBOutlet weak var emailLabel: ThemeTextFieldLabel!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var phoneLabel: ThemeTextFieldLabel!
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    
    private var newClient: Client?
    private var countryCode: String?
    
    override func setup() {
        super.setup()
        
        areaCodeField.setupUI(insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
        
        requiredFields.append(RequiredField(fieldLabel: civilityLabel, field: civilityField))
        requiredFields.append(RequiredField(fieldLabel: lastNameLabel, field: lastnameField))
        requiredFields.append(RequiredField(fieldLabel: firstnameLabel, field: firstNameField))
        requiredOneFields.append(RequiredOneField(fieldLabel: emailLabel, field: emailField, fieldLabel2: phoneLabel, field2: phoneField))
        
        fieldsGroup.append(firstNameField)
        fieldsGroup.append(lastnameField)
        fieldsGroup.append(emailField)
        fieldsGroup.append(areaCodeField)
        fieldsGroup.append(phoneField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        autoSelectCountry()
    }

    @IBAction func civilityDropdownButtonPress(_ sender: UIButton) {
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y - stackView.frame.origin.y
        let dropdownMenu = DropdownMenu()
        dropdownMenu.configure(selections: CivilityStatus.listString(),
                               selected: civilityField.text,
                               targetFrame: targetFrame,
                               arrowOfset: nil,
                               showDimOverlay: false,
                               overUIWindow: true)
        dropdownMenu.delegate = self
        dropdownMenu.show(inView: view, withDelay: 100)
        sender.isSelected = true
    }
    
    @IBAction func countryDropdownButtonPress(_ sender: DropdownButton) {
        sender.isSelected = true
        let vc = CountryPickerViewController.create(selected: countryCode, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    override func validateRequiredFields() -> Bool {
        let result = super.validateRequiredFields()
        
        if result {
            if let email = emailField.text, !email.isEmpty, !Validator.validate(string: email, validation: .email) {
                showErrorDialog(error: "Invalid email format")
                emailLabel.textColor = UIColor.fromRGBString(rgbString: (themeManager.themeData?.textFieldTheme.errorTextColor)!)
                return false
            } else {
                emailLabel.textColor = originalLabelColor
            }
        }
        
        return result
    }
    
    @IBAction func addPress(_ sender: Any) {
        if validateRequiredFields() {
            newClient = Client(partition: UserManager.shared.teamPartitionKey)
            
            guard let newClient = newClient else { return }
            
            newClient.civility = civilityField.text
            newClient.firstName = firstNameField.text ?? ""
            newClient.lastName = lastnameField.text ?? ""
            newClient.address?.country = countryField.text ?? ""
            newClient.address?.countryCode = countryCode
            newClient.email = emailField.text
            newClient.contactMethod?.byEmail = true
            newClient.contactMethod?.byPhone = true
            
            if !(phoneField.text?.isEmpty ?? true) {
                newClient.phone?.area = (areaCodeField.text ?? "").digits
                newClient.phone?.phone = (phoneField.text ?? "").digits
            }
            newClient.creator = app.currentUser!.id
            
            do {
                try teamData.write {
                    teamData.add(newClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
            
            performSegue(withIdentifier: "goToStep2", sender: self)
        }
    }
    
    @IBAction func clearPress(_ sender: Any) {
        civilityField.text = ""
        firstNameField.text = ""
        lastnameField.text = ""
        emailField.text = ""
        areaCodeField.text = "+ "
        phoneField.text = ""
        autoSelectCountry()
    }
    
    private func autoSelectCountry() {
        countryField.text = getCurrentCountry()?.englishName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newClient = newClient, let vc = segue.destination as? AppoNewOrEditViewController {
            vc.mode = .newAppo(newClient)
        }
    }
}

extension AppoNewClientViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == areaCodeField || textField == phoneField {
            if string.count > 1 {
                // User did copy & paste
                let filteredText = string.numbers
                textField.text = filteredText
                return false
            } else {
                // User did input by keypad
                let allowedCharacters = CharacterSet.decimalDigits
                let characterSet = CharacterSet(charactersIn: string)
                return allowedCharacters.isSuperset(of: characterSet)
            }
        } else {
            return true
        }
    }
    
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
        
        if textField == areaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.removePlusSignFromAreaCode()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        if textField == areaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.addPlusSignToAreaCode()
        }
    }
}

extension AppoNewClientViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        civilityField.text = selected
        civilityDropButton.isSelected = false
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        civilityDropButton.isSelected = false
    }
}

extension AppoNewClientViewController: CountryPickerViewControllerDelegate {
    func selected(selected: Country) {
        countryField.text = selected.englishName
        countryCode = selected.countryCode
        countryDropButton.isSelected = false
    }
    
    func dismissed() {
        countryDropButton.isSelected = false
    }
}
