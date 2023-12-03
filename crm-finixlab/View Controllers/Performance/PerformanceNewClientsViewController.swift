//
//  PerformanceNewClientsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-20.
//

import UIKit
import RealmSwift
import PuiSegmentedControl

enum Timeframes: Int {
    case month
    case quarter
    case year
    
    func name() -> String {
        switch self {
        case .month:
            return "This Month"
        case .quarter:
            return "This Quarter"
        case .year:
            return "This Year"
        }
    }
    
    static func listSelections() -> [String] {
        return [Timeframes.month.name(), Timeframes.quarter.name(), Timeframes.year.name()]
    }
}

class PerformanceNewClientsViewController: BaseViewController {
    var mode1: Timeframes!
    var mode2: PerfDataSelections!
    
    @IBOutlet weak var segment: ThemeSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var userSettings: UserSettings!
    private var sections: [Character] = []
    private var sectionsClients = [Character: [Client]]()
    private var starredClients: Results<Client>?
    private var clickedClient: Client?
    
    
    override func setup() {
        super.setup()
        
        segment.items = Timeframes.listSelections()
        segment.selectedIndex = mode1.rawValue
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        segment.setupUI(overrideFontSize: 13.0)
        
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
    }
    
    private func refreshView() {
        var clients = teamData.objects(Client.self)
        
        switch mode2 {
        case .my:
            clients = clients.filter("creator == %@", app.currentUser!.id)
        default:
            break
        }
        
        switch mode1 {
        case .month:
            clients = clients.filter("addedDate BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        case .quarter:
            clients = clients.filter("addedDate BETWEEN {%@, %@}", Date().startOfQuarter(), Date().endOfQuarter())
        case .year:
            clients = clients.filter("addedDate BETWEEN {%@, %@}", Date().startOfYear(), Date().endOfYear())
        default:
            fatalError()
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
    
    @IBAction private func segmentChanged(_ sender: PuiSegmentedControl) {
        // this gets called on start
        mode1 = Timeframes(rawValue: sender.selectedIndex)!
        refreshView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClientProfileViewController {
            vc.client = clickedClient
        }
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

extension PerformanceNewClientsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if sections.count == 0 {
            return 1
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.count == 0 {
            return 1
        }
        
        let character = sections[section]
        return sectionsClients[character]!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if sections.count == 0 {
            return
        }
        
        guard let theme = themeManager.themeData?.followUpTableTheme else { return }
        
        view.tintColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.backgroundColor)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = theme.sectionHeader.font.toFont()
        header.textLabel?.textColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.textColor)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections.count == 0 {
            return nil
        }
        
        if sections[section] == "★" {
            return "Starred ★"
        }
        
        return String(sections[section])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections.count == 0 {
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
        if sections.count == 0 {
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
        cell.config(client: client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections.count == 0 {
            return
        }
        
        let character = sections[indexPath.section]
        let client = sectionsClients[character]![indexPath.row]
        clickedClient = client
        performSegue(withIdentifier: "goToClientProfile", sender: self)
    }
}
