//
//  AccountViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-28.
//

import UIKit
import RealmSwift

class AccountViewController: BaseViewController {
    enum Sections: Int {
        case team
        case account
        case settings
        case count
        
        func title() -> String {
            switch self {
            case .team:
                return "My team"
            case .account:
                return "Account"
            case .settings:
                return "Settings"
            default:
                return ""
            }
        }
    }
    
    enum TeamRows: Int {
        case teamMembers
        case insights
        case inviteMembers
        case count
        
        func title() -> String {
            switch self {
            case .teamMembers:
                return "Team members"
            case .insights:
                return "Insights"
            case .inviteMembers:
                return "Invite members"
            default:
                return ""
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .teamMembers:
                return UIImage(named: "Team_Team Members")!
            case .insights:
                return UIImage(named: "Team_Insight")!
            case .inviteMembers:
                return UIImage(named: "Team_Invite Members")!
            default:
                return UIImage(systemName: "arrowshape.turn.up.left.fill")!
            }
        }
    }
    
    enum AccountRows: Int {
        case plan
        case code
        case product
        case count
        
        func title() -> String {
            switch self {
            case .plan:
                return "My Plan"
            case .code:
                return "Promo Code"
            case .product:
                return "Our Product"
            default:
                return ""
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .plan:
                return UIImage(named: "Team_My Plan")!
            case .code:
                return UIImage(named: "Team_Promo Code")!
            case .product:
                return UIImage(named: "Team_Our Product")!
            default:
                return UIImage(systemName: "arrowshape.turn.up.left.fill")!
            }
        }
    }
    
    enum SettingsRows: Int {
        case resetTutorials
        case faq
        case privacy
        case contact
        case logOut
        case count
        
        func title() -> String {
            switch self {
            case .resetTutorials:
                return "Reset Tutorials"
            case .faq:
                return "FAQ"
            case .privacy:
                return "Privacy Policy"
            case .contact:
                return "Contact Us"
            case .logOut:
                return "Log out"
            default:
                return ""
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .resetTutorials:
                return UIImage(systemName: "questionmark.video")!
            case .faq:
                return UIImage(named: "Team_FAQ")!
            case .privacy:
                return UIImage(named: "Team_Privacy Policy")!
            case .contact:
                return UIImage(named: "Team_Contact Us")!
            case .logOut:
                return UIImage(named: "Team_Logout")!
            default:
                return UIImage(systemName: "arrowshape.turn.up.left.fill")!
            }
        }
    }

    @IBOutlet weak var teamsButton: UIButton!
    @IBOutlet weak var editTeamButton: UIButton!
    @IBOutlet weak var leaveTeamButton: UIButton!
    @IBOutlet weak var profileContainer: UIStackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: ThemeImportantLabel!
    @IBOutlet weak var emailLabel: ThemeImportantLabel!
    @IBOutlet weak var tableView: UITableView!
    private var teamsPickerSheet: DashboardTeamPicker!
    
    private let userManager = UserManager.shared
    private var userData: UserData!
    private var notificationToken: NotificationToken?
    private var invitation: TeamInvitation?
    private var leaveTeamDialog: Dialog?
    private var invitationDialog: Dialog?
    
    private var profileContainerTheme = ThemeManager.shared.themeData!.mailRecipientCellTheme
    private var accountScreenTheme = ThemeManager.shared.themeData!.accountScreen
    
    override func setup() {
        super.setup()
        
        profileContainer.roundCorners()
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        profileContainerTheme = ThemeManager.shared.themeData!.mailRecipientCellTheme
        accountScreenTheme = ThemeManager.shared.themeData!.accountScreen
        
        profileContainer.backgroundColor = UIColor.fromRGBString(rgbString: profileContainerTheme.backgroundColor)
        editButton.tintColor = UIColor.fromRGBString(rgbString: profileContainerTheme.textColor)
        nameLabel.setupUI(overrideFontSize: 18.0)
        nameLabel.textColor = UIColor.fromRGBString(rgbString: profileContainerTheme.textColor)
        emailLabel.setupUI(overrideFontSize: 12.0)
        emailLabel.textColor = UIColor.fromRGBString(rgbString: profileContainerTheme.textColor)
        
        teamsButton.backgroundColor = UIColor.fromRGBString(rgbString: accountScreenTheme.teamButtonBackgroundColor)
        teamsButton.roundCorners()
        teamsButton.semanticContentAttribute = .forceRightToLeft
        teamsButton.titleLabel?.textColor = UIColor.fromRGBString(rgbString: accountScreenTheme.teamButtonForegroundColor)
        
        editTeamButton.tintColor = UIColor.fromRGBString(rgbString: profileContainerTheme.textColor)
        leaveTeamButton.tintColor = UIColor.fromRGBString(rgbString: profileContainerTheme.textColor)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTeamInvitation),
                                               name: Notifications.TeamInvitationArrived,
                                               object: nil)
        
        userManager.refreshAccountData(realm: realm) { [weak self] success in
            if success {
                self?.refreshView()
                
                self?.followUpManager?.generateMissingAppoSchedules()
                self?.followUpManager?.generateMissingMailFollowUps()
                self?.userManager.checkForInvitations()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        showTutorialIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.TeamInvitationArrived, object: nil)
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    @IBAction func teamsPressed(_ sender: UIButton) {
        guard let window = UIViewController.window else { return }
        
        // we only use teamsPickerSheet once per showing to avoid the need to reset these views
        teamsPickerSheet = DashboardTeamPicker(selectedTeamId: userManager.currentTeam?._id.stringValue, teams: userManager.myTeams)
        teamsPickerSheet.delegate = self
        
        let baseActionSheet = ActionSheet()
        baseActionSheet.content = teamsPickerSheet.teamsPickerSheet

        // add some delay to allow the view to load before it's animated on to the screen
        baseActionSheet.show(inView: window, withDelay: 50)
    }
    
    @IBAction func editTeamPressed(_ sender: UIButton) {
        guard userManager.currentTeam?.leader == app.currentUser?.id else {
            showErrorDialog(error: "Can only edit your own team.")
            return
        }
        
        let vc = AccountEditTeamViewController.create(mode: .edit, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func leaveTeamPressed(_ sender: Any) {
        leaveTeamDialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to leave this team?", secondary: "Cancel", primary: "Yes")
        leaveTeamDialog?.configure(config: config, showDimOverlay: true, overUIWindow: true)
        leaveTeamDialog?.delegate = self
        leaveTeamDialog?.show(inView: view, withDelay: 100)
    }
    
    @IBAction func editPressed(_ sender: Any) {
        let vc = AccountEditViewController.create()
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshView() {
        refreshTeamButton()
        
        let config = AvatarImageConfiguration(image: userData.avatarImage,
                                              name: userData.initials)
        avatar.config(configuration: config)

        nameLabel.text = userData.fullName
        emailLabel.text = userManager.email
    }
    
    private func refreshTeamButton() {
        if let currentTeam = userManager.currentTeam {
            UIView.performWithoutAnimation {
                self.teamsButton.setTitle(currentTeam.name + "   ", for: .normal)
                self.teamsButton.layoutIfNeeded()
            }
            
            if currentTeam.leader == app.currentUser?.id {
                self.editTeamButton.isHidden = false
                self.leaveTeamButton.isHidden = true
            } else {
                self.editTeamButton.isHidden = true
                self.leaveTeamButton.isHidden = false
            }
        } else {
            UIView.performWithoutAnimation {
                self.teamsButton.setTitle("No team selected" + "   ", for: .normal)
                self.teamsButton.layoutIfNeeded()
                self.editTeamButton.isHidden = true
                self.leaveTeamButton.isHidden = true
            }
        }
        
        tableView.reloadData()
    }
    
    private func showFeedbackScreen() {
        let vc = AccountFeedbackViewController.create()
        present(vc, animated: true, completion: nil)
    }
    
    @objc func handleTeamInvitation(_ notification: Notification) {
        guard let invitation = realm.objects(TeamInvitation.self).first else {
            showErrorDialog(error: "Error: Team invitation not found, report this as a bug.")
            return
        }
        self.invitation = invitation
        invitationDialog = Dialog()
        let config = DialogConfig(title: "Team Invitation",
                                  body: "\(invitation.leader)’s Team wants to add you as a team member.",
                                  secondary: "Decline",
                                  primary: "Join team")
        invitationDialog?.configure(config: config, showDimOverlay: true, overUIWindow: true)
        invitationDialog?.delegate = self
        invitationDialog?.show(inView: view, withDelay: 100)
        userManager.handlingInvitation = true
        
    }
    
    override func dismissedDialog(dialog: Dialog) {
        if dialog == invitationDialog {
            userManager.ignoreTeamInvitation()
        }
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if dialog == leaveTeamDialog {
            guard let currentTeam = userManager.currentTeam else { return }
            
            if index == 1 {
                FullScreenSpinner().show()
                userManager.leaveTeam(team: currentTeam) { [weak self] error in
                    FullScreenSpinner().hide()
                    
                    if let error = error {
                        showErrorDialog(error: error.localizedDescription)
                    }
                    
                    self?.refreshTeamButton()
                }
            }
        } else if dialog == invitationDialog {
            guard let invitation = invitation else { return }
            
            FullScreenSpinner().show()
            if index == 0 {
                userManager.declineTeamInvitation(invitation: invitation) { [weak self] error in
                    FullScreenSpinner().hide()
                    
                    if let error = error {
                        showErrorDialog(error: error.localizedDescription)
                    }
                    
                    self?.refreshTeamButton()
                }
            } else if index == 1 {
                userManager.acceptTeamInvitation(invitation: invitation) { [weak self] error in
                    FullScreenSpinner().hide()
                    
                    if let error = error {
                        showErrorDialog(error: error.localizedDescription)
                    }
                    
                    self?.refreshTeamButton()
                }
            }
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        userData = userManager.userData
        
        notificationToken = userData.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.refreshView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        
        tutorialManager?.showTutorial()
    }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .team:
            return TeamRows.count.rawValue
        case .account:
            return AccountRows.count.rawValue
        case .settings:
            return SettingsRows.count.rawValue
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let theme = themeManager.themeData?.importantLabelTheme else { return }
        
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = theme.font.toFont(overrideSize: 15)
        header.textLabel?.textColor = UIColor.fromRGBString(rgbString: accountScreenTheme.sectionHeaderColor)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections(rawValue: section)?.title()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as? AccountTableViewCell else {
            return AccountTableViewCell()
        }
        
        switch Sections(rawValue: indexPath.section) {
        case .team:
            cell.icon.image = TeamRows(rawValue: indexPath.row)?.icon()
            cell.label.text = TeamRows(rawValue: indexPath.row)?.title()
            cell.enabled = UserManager.shared.currentTeam != nil
            return cell
        case .account:
            cell.icon.image = AccountRows(rawValue: indexPath.row)?.icon()
            cell.label.text = AccountRows(rawValue: indexPath.row)?.title()
            cell.enabled = false
            return cell
        case .settings:
            cell.icon.image = SettingsRows(rawValue: indexPath.row)?.icon()
            cell.label.text = SettingsRows(rawValue: indexPath.row)?.title()
            cell.enabled = true
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .team:
            guard UserManager.shared.currentTeam != nil else { return }
            
            switch TeamRows(rawValue: indexPath.row) {
            case .insights:
                performSegue(withIdentifier: "goToInsights", sender: self)
            case .teamMembers:
                performSegue(withIdentifier: "goToTeam", sender: self)
            case .inviteMembers:
                if let team = UserManager.shared.currentTeam {
                    if let myUserId = app.currentUser?.id , team.leader == myUserId || team.managers.contains(myUserId) {
                        performSegue(withIdentifier: "goToInvite", sender: self)
                    } else {
                        showErrorDialog(error: "Can only invite if you are the team leader or team manager.")
                    }
                }
            default:
                break
            }
        case .settings:
            switch SettingsRows(rawValue: indexPath.row) {
            case .resetTutorials:
                TutorialManager.resetAllTutorials()
                showErrorDialog(error: "Tutorials will show again.")
            case .faq:
                openURLInBrowser(url: URL(string: "http://finixlab-inc.com/product/clientvalley/faq.html")!)
            case .privacy:
                openURLInBrowser(url: URL(string: "http://finixlab-inc.com/product/clientvalley/about.html")!)
            case .contact:
                showFeedbackScreen()
            case .logOut:
                UserManager.shared.logOut {
                    StoryboardManager.load(storyboard: "Login", animated: true, completion: nil)
                }
            default:
                break
            }
        default:
            break
        }
    }
}

extension AccountViewController: TeamPickerViewDelegate {
    func didSelectRowAt(pickerSheet: PickerSheet, tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            userManager.changeTeam(team: nil)
            refreshTeamButton()
        } else if (indexPath.row - 1) < userManager.myTeams.count {
            userManager.changeTeam(team: userManager.myTeams[indexPath.row - 1])
            refreshTeamButton()
        } else {
            let vc = AccountEditTeamViewController.create(mode: .new, delegate: self)
            present(vc, animated: true, completion: nil)
        }
    }
}

extension AccountViewController: AccountEditTeamViewControllerDelegate {
    func teamModified() {
        userManager.refreshAccountData(realm: realm) { [weak self] success in
            if success {
                self?.refreshView()
            }
        }
    }
}

extension AccountViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.accountMain
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
              var targetFrame1 = tabBarController?.tabBar.getFrameForTabAt(index: 1) else { return [] }
        
        targetFrame1.origin.y = targetFrame1.origin.y + tabBarControllerFrame.origin.y
        
        let step1 = TutorialStep(screenName: "\(TutorialName.followUpMain.rawValue) + 1",
                                body: "Get all the team and your account information here.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: targetFrame1,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step1)
        
        guard let targetFrame2 = teamsButton.globalFrame?.getOutlineFrame(thickness: 10.0) else { return [] }
        
        let step2 = TutorialStep(screenName: "\(TutorialName.followUpMain.rawValue) + 2",
                                body: "Switch team and manage different account by tabbing here.",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: targetFrame2,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step2)
        
        return tutorialSteps
    }
}
