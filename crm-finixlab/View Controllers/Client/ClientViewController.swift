//
//  FindClientViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-08.
//

import UIKit
import PuiSegmentedControl
import RealmSwift
import SKCountryPicker
import ContactsUI

class ClientViewController: BaseScrollingViewController {
    private enum Mode: Int {
        case search
        case newClient
        
        func name() -> String {
            switch self {
            case .search:
                return "Search"
            case .newClient:
                return "New Client"
            }
        }
        
        static func listSelections() -> [String] {
            return [Mode.search.name(), Mode.newClient.name()]
        }
    }
    
    private var savedSearch: SavedSearch!
    private var tempClient: TempClient!
    
    @IBOutlet weak var randomUserButton: ThemeBarButton!
    @IBOutlet weak var segment: ThemeSegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    
    // search mode
    @IBOutlet weak var fLastNameField: ThemeTextField!
    @IBOutlet weak var fFirstNameField: ThemeTextField!
    @IBOutlet weak var fPhoneContainer: UIView!
    @IBOutlet weak var fAreaCodeField: ThemeTextField!
    @IBOutlet weak var fPhoneField: ThemeTextField!
    @IBOutlet weak var fEmailField: ThemeTextField!
    @IBOutlet weak var fClientIDField: ThemeTextField!
    @IBOutlet weak var fGoClientContainer: UIView!
    private let fGoClientButton = RightArrowButton.fromNib()! as! RightArrowButton
    
    // new client mode
    @IBOutlet weak var nCivilityContainer: UIView!
    @IBOutlet weak var nCivilityField: ThemeTextField!
    @IBOutlet weak var nCivilityDropButton: DropdownButton!
    @IBOutlet weak var nLastNameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var nLastnameField: ThemeTextField!
    @IBOutlet weak var nFirstnameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var nFirstNameField: ThemeTextField!
    @IBOutlet weak var nCountryContainer: UIView!
    @IBOutlet weak var nCountryField: ThemeTextField!
    @IBOutlet weak var nCountryDropButton: DropdownButton!
    @IBOutlet weak var nEmailLabel: ThemeTextFieldLabel!
    @IBOutlet weak var nEmailField: ThemeTextField!
    @IBOutlet weak var nPhoneLabel: ThemeTextFieldLabel!
    @IBOutlet weak var nPhoneContainer: UIView!
    @IBOutlet weak var nAreaCodeField: ThemeTextField!
    @IBOutlet weak var nPhoneField: ThemeTextField!

    private var mode: Mode = .search {
        didSet {
            refreshView()
        }
    }
    private var results: Results<Client>?
    
    override func setup() {
        super.setup()
        
        segment.items = Mode.listSelections()
        
        fAreaCodeField.setupUI(insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
        fGoClientButton.labelButton.setTitle("Go directly to client list", for: .normal)
        fGoClientButton.labelButton.addTarget(self, action: #selector(goToFollowUp), for: .touchUpInside)
        fGoClientContainer.backgroundColor = .clear
        fGoClientContainer.fill(with: fGoClientButton)
        
        nAreaCodeField.setupUI(insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
        
        requiredFields.append(RequiredField(fieldLabel: nLastNameLabel, field: nLastnameField))
        requiredFields.append(RequiredField(fieldLabel: nFirstnameLabel, field: nFirstNameField))
        requiredOneFields.append(RequiredOneField(fieldLabel: nEmailLabel, field: nEmailField, fieldLabel2: nPhoneLabel, field2: nPhoneField))
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        segment.setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupRealm()
        refreshViewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openClientProfile), name: Notifications.OpenClientProfile, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        showTutorialIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.OpenClientProfile, object: nil)
    }
    
    @objc private func openClientProfile(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let clientId = userInfo["clientId"] as? ObjectId,
           let newClient: Client = teamData.objects(Client.self).filter("_id == %@", clientId).first {
            let vc = StoryboardManager.loadViewController(storyboard: "Client", viewControllerId: "ClientProfileViewController") as! ClientProfileViewController
            vc.client = newClient
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func segmentChanged(_ sender: PuiSegmentedControl) {
        mode = Mode(rawValue: sender.selectedIndex)!
    }
    
    @IBAction func civilityDropdownButtonPress(_ sender: UIButton) {
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y - stackView.frame.origin.y
        let dropdownMenu = DropdownMenu()
        dropdownMenu.configure(selections: CivilityStatus.listString(),
                               selected: tempClient?.civility,
                               targetFrame: targetFrame,
                               arrowOfset: nil,
                               showDimOverlay: false,
                               overUIWindow: false)
        dropdownMenu.delegate = self
        dropdownMenu.show(inView: view, withDelay: 100)
        sender.isSelected = true
    }
    
    @IBAction func countryDropdownButtonPress(_ sender: DropdownButton) {
        sender.isSelected = true
        let vc = CountryPickerViewController.create(selected: tempClient.address?.countryCode, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshView() {
        fieldsGroup.removeAll()
        switch mode {
        case .search:
            fieldsGroup.append(fLastNameField)
            fieldsGroup.append(fFirstNameField)
            fieldsGroup.append(fAreaCodeField)
            fieldsGroup.append(fPhoneField)
            fieldsGroup.append(fEmailField)
            fieldsGroup.append(fClientIDField)
        case .newClient:
            fieldsGroup.append(nLastnameField)
            fieldsGroup.append(nFirstNameField)
            fieldsGroup.append(nEmailField)
            fieldsGroup.append(nAreaCodeField)
            fieldsGroup.append(nPhoneField)
        }
        
        for view in stackView.subviews {
            if view.tag != mode.rawValue {
                view.isHidden = true
            } else {
                view.isHidden = false
            }
        }
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @objc private func goToFollowUp() {
        NotificationCenter.default.post(name: Notifications.SwitchToFollowUp, object: nil)
    }
    
    @IBAction func randomUserPressed(_ sender: Any) {
        guard let tempClient = tempClient else { return }
        
        if tempClient.lastName?.isEmpty ?? true {
            do {
                try realm.write {
                    tempClient.randomize()
                }
            } catch(let error) {
                print("searchPressed \(error.localizedDescription)")
            }
        } else {
            let newClient = Client(partition: tempClient._partition, tempClient: tempClient)
            newClient.creator = app.currentUser!.id
            do {
                try realm.write {
                    realm.delete(tempClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
            
            do {
                try teamUserData.write {
                    teamUserData.add(newClient)
                }
                setupRealm()
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        }
        
        refreshViewData()
    }
    
    @IBAction func searchPressed(_ sender: ThemeSubmitButton) {
        guard let savedSearch = savedSearch else { return }
        
        // perform search
        results = teamData.objects(Client.self)
        
        if !(savedSearch.lastName?.isEmpty ?? true) {
            results = results?.filter(("lastName BEGINSWITH[cd] '\(savedSearch.lastName!)'"))
        }
        
        if !(savedSearch.firstName?.isEmpty ?? true) {
            results = results?.filter(("firstName BEGINSWITH[cd] '\(savedSearch.firstName!)'"))
        }
        
        if !(savedSearch.phone?.area.isEmpty ?? true) {
            results = results?.filter(("phone.area == '\(savedSearch.phone?.area  ?? "")'"))
        }
        
        if !(savedSearch.phone?.phone.digits.isEmpty ?? true) {
            results = results?.filter(("phone.phone == '\(savedSearch.phone?.phone.digits ?? "")'"))
        }
        
        if !(savedSearch.email?.isEmpty ?? true) {
            results = results?.filter(("email CONTAINS[cd] '\(savedSearch.email!)'"))
        }
        
        if !(savedSearch.clientID?.isEmpty ?? true) {
            results = results?.filter(("clientID == '\(savedSearch.clientID!)'"))
        }
        
        results = results?.sorted(byKeyPath: "firstName")
        
        if results?.isEmpty ?? true {
            showErrorDialog(error: "No search results")
        } else {
            performSegue(withIdentifier: "goToResult", sender: self)
        }
    }
    
    @IBAction func clearSearch(_ sender: ThemeSecondaryButton) {
        do {
            try realm.write {
                savedSearch.clear()
            }
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
        refreshViewData()
    }
    
    @IBAction func importPressed(_ sender: Any) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            DispatchQueue.main.async { [weak self] in
                if let _ = error {
                    showErrorDialog(error: "Failed to request access to Contacts")
                    return
                }
                if granted {
                    self?.presentContactPicker()
                } else {
                    showErrorDialog(error: "Denied access to Contacts")
                }
            }
        }
    }
    
    private func presentContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        present(contactPicker, animated: true)
    }
    
    override func validateRequiredFields() -> Bool {
        let result = super.validateRequiredFields()
        
        if result {
            if let email = nEmailField.text, !email.isEmpty, !Validator.validate(string: email, validation: .email) {
                showErrorDialog(error: "Invalid email format")
                nEmailLabel.textColor = UIColor.fromRGBString(rgbString: (themeManager.themeData?.textFieldTheme.errorTextColor)!)
                return false
            } else {
                nEmailLabel.textColor = originalLabelColor
            }
        }
        
        return result
    }
    
    @IBAction func nextPressed(_ sender: ThemeSubmitButton) {
        if validateRequiredFields() {
            performSegue(withIdentifier: "goToStep1", sender: self)
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(SavedSearch.self).isEmpty {
            // Create a new SavedSearch
            savedSearch = SavedSearch(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(savedSearch)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            if realm.objects(SavedSearch.self).count > 1 {
                let deleteThese: [SavedSearch] = Array(realm.objects(SavedSearch.self).dropFirst())
                do {
                    try realm.write {
                        realm.delete(deleteThese)
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            }
            savedSearch = realm.objects(SavedSearch.self).first
        }
        
        if realm.objects(TempClient.self).isEmpty {
            // Create a new TempClient
            tempClient = TempClient(partition: UserManager.shared.userPartitionKey)
            
            do {
                try realm.write {
                    realm.add(tempClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            if realm.objects(TempClient.self).count > 1 {
                let deleteThese: [TempClient] = Array(realm.objects(TempClient.self).dropFirst())
                do {
                    try realm.write {
                        realm.delete(deleteThese)
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            }
            tempClient = realm.objects(TempClient.self).first
        }
        
        autoSelectCountry()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ClientSearchResultsViewController {
            viewController.results = results
        }
    }
    
    private func autoSelectCountry() {
        guard (tempClient?.address?.country?.isEmpty ?? true) || (tempClient?.address?.countryCode?.isEmpty ?? true) else { return }
        
        if let currentCountry = getCurrentCountry() {
            do {
                try realm.write {
                    if tempClient?.address == nil {
                        tempClient?.address = Address()
                    }
                    tempClient?.address?.country = currentCountry.englishName
                    tempClient?.address?.countryCode = currentCountry.countryCode
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
            refreshViewData()
        }
    }
    
    private func refreshViewData() {
        if let savedSearch = savedSearch {
            fLastNameField.text = savedSearch.lastName
            fFirstNameField.text = savedSearch.firstName
            fAreaCodeField.text = savedSearch.phone?.area.addPlusSignToAreaCode() ?? "+ "
            fPhoneField.text = savedSearch.phone?.phone
            fEmailField.text = savedSearch.email
            fClientIDField.text = savedSearch.clientID
        }
        
        if let tempClient = tempClient {
            nCivilityField.text = tempClient.civility
            nLastnameField.text = tempClient.lastName
            nFirstNameField.text = tempClient.firstName
            nCountryField.text = tempClient.address?.country
            nEmailField.text = tempClient.email
            nAreaCodeField.text = tempClient.phone?.area.addPlusSignToAreaCode() ?? "+ "
            nPhoneField.text = tempClient.phone?.phone
        }
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        
        tutorialManager?.showTutorial()
    }
}

extension ClientViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == fAreaCodeField || textField == nAreaCodeField || textField == fPhoneField || textField == nPhoneField {
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
        
        if textField == fAreaCodeField || textField == nAreaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.removePlusSignFromAreaCode()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        if textField == fLastNameField {
            do {
                try realm.write {
                    savedSearch.lastName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == fFirstNameField {
            do {
                try realm.write {
                    savedSearch.firstName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == fAreaCodeField {
            do {
                try realm.write {
                    savedSearch.phone?.area = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == fPhoneField {
            do {
                try realm.write {
                    savedSearch.phone?.phone = (textField.text ?? "").digits
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == fEmailField {
            do {
                try realm.write {
                    savedSearch.email = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == fClientIDField {
            do {
                try realm.write {
                    savedSearch.clientID = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        
        else if textField == nCivilityField {
            do {
                try realm.write {
                    tempClient.civility = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == nLastnameField {
            do {
                try realm.write {
                    tempClient.lastName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == nFirstNameField {
            do {
                try realm.write {
                    tempClient.firstName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == nEmailField {
            do {
                try realm.write {
                    tempClient.email = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == nAreaCodeField {
            do {
                try realm.write {
                    tempClient.phone?.area = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == nPhoneField {
            do {
                try realm.write {
                    tempClient.phone?.phone = (textField.text ?? "").digits
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        
        if textField == fAreaCodeField || textField == nAreaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.addPlusSignToAreaCode()
        }
    }
}

extension ClientViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        nCivilityField.text = selected
        nCivilityDropButton.isSelected = false
        
        do {
            try realm.write {
                tempClient.civility = selected
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        nCivilityDropButton.isSelected = false
    }
}

extension ClientViewController: CountryPickerViewControllerDelegate {
    func selected(selected: Country) {
        nCountryField.text = selected.englishName
        nCountryDropButton.isSelected = false
        
        do {
            try realm.write {
                tempClient.address?.country = selected.englishName
                tempClient.address?.countryCode = selected.countryCode
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
    
    func dismissed() {
        nCountryDropButton.isSelected = false
    }
}

extension ClientViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        do {
            try realm.write {
                tempClient.readFromContact(contact: contact)
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
        refreshViewData()
    }
}

extension ClientViewController: TutorialSupport {
    func screenName() -> TutorialName {
        switch mode {
        case .search:
            return TutorialName.clientSearch
        case .newClient:
            return TutorialName.clientNew
        }
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        switch mode {
        case .search:
            let step = TutorialStep(screenName: "\(TutorialName.clientSearch.rawValue) + 1",
                                    body: "Hi there!\nReady to start your tutorial?",
                                    pointingDirection: .up,
                                    pointPosition: .edge,
                                    targetFrame: nil,
                                    showDimOverlay: true,
                                    overUIWindow: true)
            tutorialSteps.append(step)
            
            guard let targetFrame1 = segment.globalFrame?.getOutlineFrame(thickness: 10.0) else { return [] }
            
            let step2 = TutorialStep(screenName: "\(TutorialName.clientSearch.rawValue) + 2",
                                    body: "Find your existing client or add new client by tabbing the top switch bar.",
                                    pointingDirection: .up,
                                    pointPosition: .edge,
                                    targetFrame: targetFrame1,
                                    showDimOverlay: true,
                                    overUIWindow: true)
            tutorialSteps.append(step2)
            
            guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
                  var targetFrame2 = tabBarController?.tabBar.getFrameForTabAt(index: 0) else { return [] }
            
            targetFrame2.origin.y = targetFrame2.origin.y + tabBarControllerFrame.origin.y
            
            let step3 = TutorialStep(screenName: "\(TutorialName.clientSearch.rawValue) + 3",
                                    body: "Find client and add new client here.",
                                    pointingDirection: .down,
                                    pointPosition: .edge,
                                    targetFrame: targetFrame2,
                                    showDimOverlay: true,
                                    overUIWindow: true)
            tutorialSteps.append(step3)
        case .newClient:
            break
        }
        
        return tutorialSteps
    }
}
