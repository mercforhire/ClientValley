//
//  FollowUpViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-23.
//

import UIKit
import RealmSwift

class FollowUpViewController: BaseViewController {
    private let emailIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    private let phoneIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    private let messageIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    private let addressIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    private let listIcon = RoundIconWithLabel.fromNib()! as! RoundIconWithLabel
    
    @IBOutlet private var selectAll: ThemeBarButton!
    @IBOutlet private var generateButton: ThemeBarButton!
    @IBOutlet weak var iconsStackView: UIStackView!
    @IBOutlet weak var iconContainer1: UIView!
    @IBOutlet weak var iconContainer2: UIView!
    @IBOutlet weak var iconContainer3: UIView!
    @IBOutlet weak var iconContainer4: UIView!
    @IBOutlet weak var iconContainer5: UIView!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var savedMailButtonContainer: UIView!
    @IBOutlet weak var buttonFiller: UIView!
    private let savedMailButton = RightArrowButton.fromNib()! as! RightArrowButton
    @IBOutlet weak var tableView: UITableView!
    
    private var userSettings: UserSettings!
    private var sections: [Character] = []
    private var sectionsClients = [Character: [Client]]()
    private var starredClients: Results<Client>?
    private var selectableClients: Results<Client>?
    private var selected: [Client] = [] {
        didSet {
            if let selectableClients = selectableClients, selected.count == selectableClients.count {
                selectAll.title = "Unselect All"
            } else {
                selectAll.title = "Select All"
            }
            tableView.reloadData()
        }
    }
    private var selectedIcon: FollowUpType = .list {
        didSet {
            emailIcon.configureUI(type: FollowUpType.email, selected: selectedIcon == .email)
            phoneIcon.configureUI(type: FollowUpType.phone, selected: selectedIcon == .phone)
            messageIcon.configureUI(type: FollowUpType.message, selected: selectedIcon == .message)
            addressIcon.configureUI(type: FollowUpType.address, selected: selectedIcon == .address)
            listIcon.configureUI(type: FollowUpType.list, selected: selectedIcon == .list)
            
            savedMailButtonContainer.isHidden = selectedIcon != .address
            searchBarContainer.isHidden = selectedIcon != .list
            
            switch selectedIcon {
            case .email, .address, .message:
                navigationItem.leftBarButtonItems = [selectAll]
                navigationItem.rightBarButtonItems = [generateButton]
            default:
                navigationItem.leftBarButtonItems = []
                navigationItem.rightBarButtonItems = []
            }
            
            searchBar.text = ""
            
            selected = []
            tableView.scrollToTop(animated: true)
            refreshView()
        }
    }
    private var clickedClient: Client?
    private var delayTimer = DelayedSearchTimer()
    
    override func setup() {
        super.setup()
        
        iconContainer1.fill(with: emailIcon)
        iconContainer2.fill(with: phoneIcon)
        iconContainer3.fill(with: messageIcon)
        iconContainer4.fill(with: addressIcon)
        iconContainer5.fill(with: listIcon)
        
        iconContainer1.backgroundColor = .clear
        iconContainer2.backgroundColor = .clear
        iconContainer3.backgroundColor = .clear
        iconContainer4.backgroundColor = .clear
        iconContainer5.backgroundColor = .clear
        
        savedMailButtonContainer.isHidden = true
        
        emailIcon.configureUI(type: FollowUpType.email, selected: selectedIcon == .email)
        phoneIcon.configureUI(type: FollowUpType.phone, selected: selectedIcon == .phone)
        messageIcon.configureUI(type: FollowUpType.message, selected: selectedIcon == .message)
        addressIcon.configureUI(type: FollowUpType.address, selected: selectedIcon == .address)
        listIcon.configureUI(type: FollowUpType.list, selected: selectedIcon == .list)
        navigationItem.leftBarButtonItems = []
        navigationItem.rightBarButtonItems = []
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(emailIconTapped))
        emailIcon.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(phoneIconTapped))
        phoneIcon.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(messageIconTapped))
        messageIcon.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(addressIconTapped))
        addressIcon.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(listIconTapped))
        listIcon.addGestureRecognizer(tap5)
        
        delayTimer.delegate = self
        
        savedMailButton.labelButton.setTitle("Saved mail", for: .normal)
        buttonFiller.backgroundColor = .clear
        buttonFiller.fill(with: savedMailButton)
        
        savedMailButton.labelButton.addTarget(self, action: #selector(savedMailPressed), for: .touchUpInside)
        savedMailButton.rightArrow.addTarget(self, action: #selector(savedMailPressed), for: .touchUpInside)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let sectionIndexTheme = themeManager.themeData?.countryPickerTheme.sectionIndex else { return }
        
        tableView.sectionIndexColor = UIColor.fromRGBString(rgbString: sectionIndexTheme.textColor)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        showTutorialIfNeeded()
    }
    
    private func refreshView() {
        var clients = teamData.objects(Client.self)
        
        if let searchText = searchBar.text?.trim(), !searchText.isEmpty {
            clients = clients.filter(("firstName BEGINSWITH[cd] '\(searchText)' OR lastName BEGINSWITH[cd] '\(searchText)'"))
        }
        
        switch selectedIcon {
        case .email:
            clients = clients
                .filter("contactMethod.byEmail == true")
                .filter("email != %@", "")
        case .phone:
            clients = clients
                .filter("contactMethod.byPhone == true")
                .filter("phone.phone != %@", "")
        case .message:
            clients = clients
                .filter("contactMethod.byMessage == true")
                .filter("phone.phone != %@", "")
        case .address:
            clients = clients
                .filter("contactMethod.byMail == true")
                .filter("address.address != %@", "")
        default:
            break
        }
        
        selectableClients = clients
        
        starredClients = clients.filter("_id IN %@", userSettings.starredClients)
        
        sections = Client.sections(clients: clients)
        
        if !(starredClients?.isEmpty ?? true) {
            sections.insert("★", at: 0)
        }
        
        for section in sections {
            if section == "★" {
                self.sectionsClients[section] = starredClients?.sorted(byKeyPath: "firstName").map({ $0 })
            } else {
                let sectionClients = clients.filter({ $0.prefix == section }).removeDuplicates()
                self.sectionsClients[section] = sectionClients
            }
        }
        
        tableView.reloadData()
    }
    
    override func setupRealm() {
        super.setupRealm()

        if realm.objects(UserSettings.self).isEmpty {
            userSettings = UserSettings(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(userSettings)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            userSettings = realm.objects(UserSettings.self).first
        }
        
        selected = []
    }
    
    @objc private func emailIconTapped() {
        selectedIcon = .email
    }
    
    @objc private func phoneIconTapped() {
        selectedIcon = .phone
    }
    
    @objc private func messageIconTapped() {
        selectedIcon = .message
    }
    
    @objc private func addressIconTapped() {
        selectedIcon = .address
    }
    
    @objc private func listIconTapped() {
        selectedIcon = .list
    }
    
    @IBAction func selectAllPress(_ sender: Any) {
        guard let selectableClients = selectableClients else {
            return
        }
        
        if selected.count == selectableClients.count {
            selected = []
        } else {
            selected = Array(selectableClients)
        }
    }
    
    @IBAction func generatePressed(_ sender: Any) {
        switch selectedIcon {
        case .email:
            performSegue(withIdentifier: "goToEmail", sender: self)
        case .message:
            performSegue(withIdentifier: "goToMessage", sender: self)
        case .address:
            performSegue(withIdentifier: "goToMail", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FollowUpEmailViewController {
            vc.preSelected = selected
            vc.clients = selectableClients
        } else if let vc = segue.destination as? FollowUpMessageViewController {
            vc.preSelected = selected
            vc.clients = selectableClients
        } else if let vc = segue.destination as? FollowUpMailViewController {
            vc.preSelected = selected
            vc.clients = selectableClients
        } else if let vc = segue.destination as? ClientProfileViewController {
            vc.client = clickedClient
        }
    }
    
    @objc private func savedMailPressed() {
        let vc = FollowUpSavedMailsViewController.create()
        present(vc, animated: true, completion: nil)
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        
        tutorialManager?.showTutorial()
    }
}

extension FollowUpViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        refreshView()
    }
}

extension FollowUpViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.inputAccessoryView = simpleInputToolbar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delayTimer.textDidGetEntered(text: searchText)
    }
}

extension FollowUpViewController: UITableViewDataSource, UITableViewDelegate {
    var isSearching: Bool {
        if let searchText = searchBar.text?.trim(), !searchText.isEmpty {
            return true
        }
        
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching && sections.count == 0 {
            return 1
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching && sections.count == 0 {
            return 1
        }
        
        let character = sections[section]
        return sectionsClients[character]!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if isSearching && sections.count == 0 {
            return
        }
        
        guard let theme = themeManager.themeData?.followUpTableTheme else { return }
        
        view.tintColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.backgroundColor)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = theme.sectionHeader.font.toFont()
        header.textLabel?.textColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.textColor)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching && sections.count == 0 {
            return nil
        }
        
        if sections[section] == "★" {
            return "Starred ★"
        }
        
        return String(sections[section])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching && sections.count == 0 {
            return 0.0
        }
        
        return 35.0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { String($0) }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sections.firstIndex(of: Character(title))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching && sections.count == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUpEmptyClientCell", for: indexPath) as? FollowUpEmptyClientCell else {
                return FollowUpEmptyClientCell()
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUpClientCell", for: indexPath) as? FollowUpClientCell else {
            return FollowUpClientCell()
        }
        
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        var checked: Bool?
        if selectedIcon.showCheckmarks() {
            checked = selected.contains(client)
        }
        cell.config(checked: checked, client: client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching && sections.count == 0 {
            return
        }
        
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        
        switch selectedIcon {
        case .phone:
            if let _ = client.phone {
                showCallActionSheet(client: client)
            }
        case .email, .message, .address:
            if selectedIcon == .message, client.phone?.getFormattedString() == nil {
                showErrorDialog(error: "Invalid or missing phone number for \(client.fullName)")
                return
            }
            
            if selected.contains(client) {
                selected.removeAll { subject in
                    return subject == client
                }
            } else {
                selected.append(client)
            }
        case .list:
            clickedClient = client
            performSegue(withIdentifier: "goToClientProfile", sender: self)
        }
    }
}

extension FollowUpViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.followUpMain
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
              var targetFrame1 = tabBarController?.tabBar.getFrameForTabAt(index: 1) else { return [] }
        
        targetFrame1.origin.y = targetFrame1.origin.y + tabBarControllerFrame.origin.y
        
        let step1 = TutorialStep(screenName: "\(TutorialName.followUpMain.rawValue) + 1",
                                body: "Follow up with your client here.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: targetFrame1,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step1)
        
        guard let targetFrame2 = iconsStackView.globalFrame?.getOutlineFrame(thickness: 10.0) else { return [] }
        
        let step2 = TutorialStep(screenName: "\(TutorialName.followUpMain.rawValue) + 2",
                                body: "Check your client list, and  follow up by sending emails, messages, mails, or making phone calls.",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: targetFrame2,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step2)
        
        return tutorialSteps
    }
}
