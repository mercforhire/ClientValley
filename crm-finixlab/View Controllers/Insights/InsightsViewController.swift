//
//  InsightsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-15.
//

import UIKit
import RealmSwift

enum InsightSelections {
    case general
    case appointment
    case followUp
    case client
    
    func title() -> String {
        switch self {
        case .general:
            return "General"
        case .appointment:
            return "Appointment"
        case .followUp:
            return "Follow Up"
        case .client:
            return "Client"
        }
    }
    
    func dotColor() -> UIColor {
        guard let theme = ThemeManager.shared.themeData?.insightsScreen else { return UIColor.clear }
        
        switch self {
        case .general:
            return UIColor.clear
        case .appointment:
            return UIColor.fromRGBString(rgbString: theme.appoDotColor)!
        case .followUp:
            return UIColor.fromRGBString(rgbString: theme.followUpDotColor)!
        case .client:
            return UIColor.fromRGBString(rgbString: theme.clientDotColor)!
        }
    }
    
    static func from(title: String) -> InsightSelections? {
        switch title {
        case "General":
            return .general
        case "Appointment":
            return .appointment
        case "Follow Up":
            return .followUp
        case "Client":
            return .client
        default:
            return nil
        }
    }
    
    static func list() -> [InsightSelections] {
        return [.general, .appointment, .followUp, .client]
    }
    
    static func listString() -> [String] {
        return [InsightSelections.general.title(), InsightSelections.appointment.title(), InsightSelections.followUp.title(), InsightSelections.client.title()]
    }
    
    static func barTypeslist() -> [InsightSelections] {
        return [.appointment, .followUp, .client]
    }
    
    static func barTypeslistString() -> [String] {
        return [InsightSelections.appointment.title(), InsightSelections.followUp.title(), InsightSelections.client.title()]
    }
}

enum FollowUpTypes: String {
    case email
    case phone
    case message
    case mail
    
    func title() -> String {
        switch self {
        case .email:
            return "Email"
        case .phone:
            return "Phone"
        case .message:
            return "Message"
        case .mail:
            return "Mail"
        }
    }
    
    func dotColor() -> UIColor {
        guard let theme = ThemeManager.shared.themeData?.insightsScreen else { return UIColor.clear }
        
        switch self {
        case .email:
            return UIColor.fromRGBString(rgbString: theme.emailDotColor)!
        case .phone:
            return UIColor.fromRGBString(rgbString: theme.phoneDotColor)!
        case .message:
            return UIColor.fromRGBString(rgbString: theme.messageDotColor)!
        case .mail:
            return UIColor.fromRGBString(rgbString: theme.mailDotColor)!
        }
    }
    
    static func list() -> [FollowUpTypes] {
        return [.email, .phone, .message, .mail]
    }
    
    static func listString() -> [String] {
        return [FollowUpTypes.email.title(), FollowUpTypes.phone.title(), FollowUpTypes.message.title(), FollowUpTypes.mail.title()]
    }
}

struct BarDataModel {
    var name: String
    var color: UIColor
    var count: Int
}

struct InsightsBarsDataModel {
    var teamMember: TeamMember
    var maxCount: Int
    var bars: [BarDataModel]
}

class InsightsViewController: BaseViewController {
    
    private let barTypes: [InsightSelections] = [.appointment, .followUp, .client]
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoryField: ThemeTextField!
    @IBOutlet weak var dropdownButton: DropdownButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var insightsTableView: UITableView!
    
    private var theme = ThemeManager.shared.themeData!.insightsScreen
    private var selection: InsightSelections = .general {
        didSet {
            categoryField.text = selection.title()
            
            switch selection {
            case .general, .followUp:
                categoryCollectionView.reloadData()
                categoryCollectionView.isHidden = false
            default:
                categoryCollectionView.isHidden = true
            }
            
            switch selection {
            case .general:
                membersData = followUpManager?.generateGeneralFollowUpData(month: selectedMonth, members: members)
            case .followUp:
                membersData = followUpManager?.generateFollowUpDetailsData(month: selectedMonth, members: members)
            case .appointment:
                membersData = followUpManager?.generateAppoFollowUpData(month: selectedMonth, members: members)
            case .client:
                membersData = followUpManager?.generateClientFollowUpData(month: selectedMonth, members: members)
            }
        }
    }
    private var selectedMonth = Date() {
        didSet {
            UIView.performWithoutAnimation {
                self.dateButton.setTitle(DateUtil.convert(input: selectedMonth, outputFormat: .format14), for: .normal)
                self.dateButton.layoutIfNeeded()
            }
            
        }
    }
    private var team: Team!
    private var members: [TeamMember]!
    private var membersData: [InsightsBarsDataModel]! {
        didSet {
            insightsTableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        categoryField.setupUI(overrideSize: 15, insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        selectedMonth = { self.selectedMonth }()
    }
    
    override func setupTheme() {
        super.setupTheme()
        dateButton.backgroundColor = UIColor.fromRGBString(rgbString: theme.buttonBackgroundColor)
        dateButton.roundCorners()
        dateButton.titleLabel?.textColor = UIColor.fromRGBString(rgbString: theme.buttonForegroundColor)
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
    
    func refreshView() {
        selection = { self.selection }()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        guard let team = UserManager.shared.currentTeam else {
            backPressed(backButton)
            return
        }
        self.team = team
        members = []
        members.append(contentsOf: Array(publicRealm.objects(TeamMember.self).filter("(userId IN %@)", [team.leader])))
        members.append(contentsOf: Array(publicRealm.objects(TeamMember.self).filter("(userId IN %@)", team.managers)))
        members.append(contentsOf: Array(publicRealm.objects(TeamMember.self).filter("(userId IN %@)", team.members)))
    }
    
    @IBAction func datePressed(_ sender: UIButton) {
        let datePickerDialog = DatePickerDialog()
        datePickerDialog.configure(mode: .month,
                                   selected: selectedMonth,
                                   showDimOverlay: true,
                                   overUIWindow: true)
        datePickerDialog.delegate = self
        datePickerDialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func dropdownButtonPress(_ sender: UIButton) {
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y
        let dropdownMenu = DropdownMenu()
        dropdownMenu.configure(selections: InsightSelections.listString(),
                               selected: selection.title(),
                               targetFrame: targetFrame,
                               arrowOfset: nil,
                               showDimOverlay: false,
                               overUIWindow: true)
        dropdownMenu.delegate = self
        dropdownMenu.show(inView: view, withDelay: 100)
        sender.isSelected = true
    }
}

extension InsightsViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        selection = InsightSelections.from(title: selected) ?? .general
        dropdownButton.isSelected = false
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        dropdownButton.isSelected = false
    }
}

extension InsightsViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        selectedMonth = date.startOfMonth()
        refreshView()
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        
    }
}

extension InsightsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selection {
        case .general:
            return InsightSelections.barTypeslistString().count
        case .followUp:
            return FollowUpTypes.listString().count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        switch selection {
        case .general:
            cell.config(selection: InsightSelections.barTypeslist()[indexPath.row])
        case .followUp:
            cell.config(selection: FollowUpTypes.list()[indexPath.row])
        default:
            break
        }
        return cell
    }
}

extension InsightsViewController: UITableViewDataSource, UITableViewDelegate {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data: InsightsBarsDataModel = membersData[indexPath.row]
        switch selection {
        case .general:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsightsBarsTableViewCell", for: indexPath) as? InsightsBarsTableViewCell else {
                return InsightsBarsTableViewCell()
            }
            cell.config(data: data)
            return cell
        case .followUp:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsightsBarsTableViewCell", for: indexPath) as? InsightsBarsTableViewCell else {
                return InsightsBarsTableViewCell()
            }
            cell.config(data: data)
            return cell
        case .appointment:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsightsSingleBarTableViewCell", for: indexPath) as? InsightsSingleBarTableViewCell else {
                return InsightsSingleBarTableViewCell()
            }
            cell.config(data: data)
            return cell
        case .client:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsightsSingleBarTableViewCell", for: indexPath) as? InsightsSingleBarTableViewCell else {
                return InsightsSingleBarTableViewCell()
            }
            cell.config(data: data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
