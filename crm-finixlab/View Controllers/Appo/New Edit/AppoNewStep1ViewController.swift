//
//  AppoMainViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-01.
//

import UIKit
import RealmSwift

class AppoNewStep1ViewController: BaseViewController {
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var nextButton: ThemeBarButton!
    @IBOutlet weak var buttonFiller: UIView!
    private let newClientButton = RightArrowButton.fromNib()! as! RightArrowButton
    @IBOutlet weak var tableView: UITableView!
    
    private var userSettings: UserSettings!
    private var sections: [Character] = []
    private var sectionsClients = [Character: [Client]]()
    private var starredClients: Results<Client>?
    private var selected: Client? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        UIView.performWithoutAnimation {
            self.newClientButton.labelButton.setTitle("Add new client", for: .normal)
            self.newClientButton.layoutIfNeeded()
        }
        
        buttonFiller.backgroundColor = .clear
        buttonFiller.fill(with: newClientButton)
        
        newClientButton.labelButton.addTarget(self, action: #selector(newClientPressed), for: .touchUpInside)
        newClientButton.rightArrow.addTarget(self, action: #selector(newClientPressed), for: .touchUpInside)
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
    
    @IBAction func randomPressed(_ sender: Any) {
        if let ranChar = sections.randomElement(), let ranClient = sectionsClients[ranChar]?.randomElement() {
            selected = ranClient
        }
    }
    
    private func refreshView() {
        let clients = teamData.objects(Client.self)
        
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
    }
    
    @objc func newClientPressed() {
        performSegue(withIdentifier: "goToNewClient", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToStep2",
           let vc = segue.destination as? AppoNewOrEditViewController,
           let client = selected {
            vc.mode = .newAppo(client)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToStep2", selected == nil {
            showErrorDialog(error: "Must select a client")
            return false
        }
        return true
    }
}

extension AppoNewStep1ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let character = sections[section]
        return sectionsClients[character]!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let theme = themeManager.themeData?.followUpTableTheme else { return }
        
        view.tintColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.backgroundColor)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = theme.sectionHeader.font.toFont()
        header.textLabel?.textColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.textColor)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section] == "★" {
            return "Starred ★"
        }
        
        return String(sections[section])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { String($0) }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sections.firstIndex(of: Character(title))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUpClientCell", for: indexPath) as? FollowUpClientCell else {
            return FollowUpClientCell()
        }
        
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        let checked: Bool = selected == client
        cell.config(checked: checked, client: client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        if selected == client {
            selected = nil
        } else {
            selected = client
        }
    }
}
