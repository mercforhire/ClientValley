//
//  AccountTeamMembersViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-08.
//

import UIKit
import RealmSwift

class AccountTeamMembersViewController: BaseViewController {
    enum Sections: Int {
        case leader
        case managers
        case members
        case count
        
        func title() -> String {
            switch self {
            case .leader:
                return "Team Leader"
            case .managers:
                return "Team Manager"
            case .members:
                return "Team Member"
            default:
                return ""
            }
        }
    }
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var team: Team!
    private var leader: Results<TeamMember>?
    private var managers: Results<TeamMember>?
    private var members: Results<TeamMember>?
    private var selected: TeamMember?
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshViewData()
        refreshView()
    }
    
    func refreshView() {
        tableView.reloadData()
    }
    
    func refreshViewData() {
        guard let team = UserManager.shared.currentTeam else {
            backPressed(backButton)
            return
        }
        self.team = team
        
        leader = publicRealm.objects(TeamMember.self).filter("(userId IN %@)", [team.leader])
        managers = publicRealm.objects(TeamMember.self).filter("(userId IN %@)", team.managers)
        members = publicRealm.objects(TeamMember.self).filter("(userId IN %@)", team.members)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AccountMemberDetailsViewController {
            vc.teamId = team._id.stringValue
            vc.member = selected
        }
    }
}

extension AccountTeamMembersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .leader:
            return leader?.count ?? 0
        case .managers:
            return managers?.count ?? 0
        case .members:
            return members?.count ?? 0
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let theme = themeManager.themeData?.followUpTableTheme else { return }
        
        view.tintColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.backgroundColor)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = theme.sectionHeader.font.toFont()
        header.textLabel?.textColor = UIColor.fromRGBString(rgbString: theme.sectionHeader.textColor)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Sections(rawValue: section)?.title()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Sections(rawValue: section) {
        case .leader:
            return leader?.isEmpty ?? true ? 0 : 35
        case .managers:
            return managers?.isEmpty ?? true ? 0 : 35
        case .members:
            return members?.isEmpty ?? true ? 0 : 35
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamMateCell", for: indexPath) as? TeamMateCell else {
            return TeamMateCell()
        }
        var member: TeamMember?
        switch Sections(rawValue: indexPath.section) {
        case .leader:
            member = leader?[indexPath.row]
        case .managers:
            member = managers?[indexPath.row]
        case .members:
            member = members?[indexPath.row]
        default:
            break
        }
        guard let member = member else { return cell }
        
        cell.config(teamMember: member)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var member: TeamMember?
        switch Sections(rawValue: indexPath.section) {
        case .leader:
            member = leader?[indexPath.row]
        case .managers:
            member = managers?[indexPath.row]
        case .members:
            member = members?[indexPath.row]
        default:
            break
        }
        guard let member = member else { return }
        
        selected = member
        performSegue(withIdentifier: "goToMemberDetails", sender: self)
    }
}
