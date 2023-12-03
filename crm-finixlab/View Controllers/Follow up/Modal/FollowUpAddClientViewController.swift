//
//  FollowUpAddClientViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import UIKit
import RealmSwift

protocol FollowUpAddClientViewControllerDelegate: class {
    func addedClients(clients: [Client])
}

class FollowUpAddClientViewController: BaseViewController {
    var allClients: Results<Client>!
    var excludedClients: [Client] = []
    weak var delegate: FollowUpAddClientViewControllerDelegate?
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var addButton: ThemeBarButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var userSettings: UserSettings!
    
    private var filteredClients: Results<Client>!
    private var sections: [Character] = []
    private var sectionsClients = [Character: [Client]]()
    private var starredClients: Results<Client>?
    private var selected: [Client] = []
    private var delayTimer = DelayedSearchTimer()
    
    static func create(allClients: Results<Client>, excludedClients: [Client] = [], delegate: FollowUpAddClientViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpAddClientViewController") as! FollowUpAddClientViewController
        vc.allClients = allClients
        vc.excludedClients = excludedClients
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        delayTimer.delegate = self
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        addButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        guard let sectionIndexTheme = themeManager.themeData?.countryPickerTheme.sectionIndex else { return }
        
        tableView.sectionIndexColor = UIColor.fromRGBString(rgbString: sectionIndexTheme.textColor)
        tableView.reloadData()
        
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
    
    @IBAction private func addButtonPress(_ sender: UIBarButtonItem) {
        delegate?.addedClients(clients: selected)
        backPressed(backButton)
    }
    
    private func refreshView() {
        var clients: Results<Client> = allClients!
    
        if !excludedClients.isEmpty {
            clients = clients.filter("NOT (_id IN %@)", excludedClients.map({ $0._id }))
        }
        
        if let searchText = searchBar.text?.trim(), !searchText.isEmpty {
            clients = clients.filter(("firstName BEGINSWITH[cd] '\(searchText)' OR lastName BEGINSWITH[cd] '\(searchText)'"))
        }
        
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
}

extension FollowUpAddClientViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        refreshView()
    }
}

extension FollowUpAddClientViewController: UISearchBarDelegate {
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

extension FollowUpAddClientViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.config(checked: selected.contains(client), client: client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        
        if selected.contains(client) {
            selected.removeAll { subject in
                return subject == client
            }
        } else {
            selected.append(client)
        }
        tableView.reloadData()
    }
}
