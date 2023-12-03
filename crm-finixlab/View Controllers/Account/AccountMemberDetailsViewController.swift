//
//  AccountMemberDetailsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-08.
//

import UIKit
import RealmSwift

class AccountMemberDetailsViewController: BaseScrollingViewController {
    var teamId: String!
    var member: TeamMember!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleField: ThemeTextField!
    @IBOutlet weak var dropdownButton: DropdownButton!
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var emaiLabel: UILabel!
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var deleteButton: ThemeDeleteButton!
    
    private var team: Team?
    private var role: TeamRole?
    
    override func setup() {
        super.setup()
        stackview.roundCorners()
        roleField.setupUI(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        title = member.fullName
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme,
              let theme2 = themeManager.themeData?.secondaryButtonTheme,
              let theme3 = themeManager.themeData?.memberScreen else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        stackview.backgroundColor = UIColor.fromRGBString(rgbString: theme3.cardBackgroundColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        refreshViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }

    @IBAction func teamRoleDropdownButtonPress(_ sender: UIButton) {
        guard let role = role,
              let currentRole = role.roleEnum, currentRole != .leader else {
            return
        }
        
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y
        let dropdownMenu = DropdownMenu()
        dropdownMenu.configure(selections: TeamRoles.menulistString(),
                               selected: currentRole.title(),
                               targetFrame: targetFrame,
                               arrowOfset: nil,
                               showDimOverlay: false,
                               overUIWindow: true)
        dropdownMenu.delegate = self
        dropdownMenu.show(inView: view, withDelay: 100)
        sender.isSelected = true
    }
    
    @IBAction func deletePress(_ sender: ThemeDeleteButton) {
        let leaveTeamDialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to remove this member from this team?", secondary: "Cancel", primary: "Yes")
        leaveTeamDialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        leaveTeamDialog.delegate = self
        leaveTeamDialog.show(inView: view, withDelay: 100)
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1 {
            guard let team = team, let role = role else { return }
            
            FullScreenSpinner().show()
            UserManager.shared.removeTeamMember(team: team, memberUserId: role.userId) { [weak self] error in
                FullScreenSpinner().hide()
                
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func refreshView() {
        guard let role = role, let team = team else { return }
        
        switch role.roleEnum {
        case .leader:
            deleteButton.isHidden = true
        case .manager:
            deleteButton.isHidden = !team.canRemoveManager(userId: app.currentUser!.id)
        case .member:
            deleteButton.isHidden = !team.canRemoveMember(userId: app.currentUser!.id)
        default:
            break
        }
        
        let config = AvatarImageConfiguration(image: member.avatarImage,
                                              name: member.avatar == nil ? member.initials : nil)
        avatar.config(configuration: config)
        nameLabel.text = member.fullName
        emaiLabel.text = member.email
        phoneNumber.text = member.phone?.getNumberString()
        
        if team.canRemoveManager(userId: app.currentUser!.id) {
            dropdownButton.isEnabled = true
        } else {
            dropdownButton.isEnabled = false
        }
        
        roleField.text = role.roleEnum?.title()
    }
    
    private func refreshViewData() {
        team = UserManager.shared.myTeams.first(where: { subject in
            return subject._id.stringValue == self.teamId
        })
        
        if team == nil {
            showErrorDialog(error: "Fatal error: Team not found")
            navigationController?.popViewController(animated: true)
            return
        }
        
        role = team!.roles.first(where: { subject in
            return subject.userId == member.userId
        })
        
        if role == nil {
            showErrorDialog(error: "Fatal error: User not in team")
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        guard teamRealm != nil else {
            backPressed(backButton)
            return
        }
    }
}

extension AccountMemberDetailsViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        dropdownButton.isSelected = false
        
        guard let team = team,
              let role = role,
              let currentRole = role.roleEnum,
              currentRole.title() != selected else { return }
        
        // demote
        if currentRole == .manager, selected == TeamRoles.member.title() {
            FullScreenSpinner().show()
            UserManager.shared.demoteTeamManager(team: team, memberUserId: role.userId) { [weak self] error in
                FullScreenSpinner().hide()
                
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self?.refreshViewData()
                    self?.refreshView()
                }
            }
        }
        // promote
        else if currentRole == .member, selected == TeamRoles.manager.title() {
            FullScreenSpinner().show()
            UserManager.shared.promoteTeamMember(team: team, memberUserId: role.userId) { [weak self] error in
                FullScreenSpinner().hide()
                
                if let error = error {
                    showErrorDialog(error: error.localizedDescription)
                } else {
                    self?.refreshViewData()
                    self?.refreshView()
                }
            }
        }
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        dropdownButton.isSelected = false
    }
}
