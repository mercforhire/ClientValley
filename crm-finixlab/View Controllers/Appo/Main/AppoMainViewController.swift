//
//  AppoMainViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-30.
//

import UIKit
import RealmSwift
import PuiSegmentedControl

enum AppoMode: Int {
    case appo
    case history
    
    func name() -> String {
        switch self {
        case .appo:
            return "Appointment"
        case .history:
            return "History"
        }
    }
    
    func name2() -> String {
        switch self {
        case .appo:
            return "UPCOMING APPOINTMENTS"
        case .history:
            return "PAST APPOINTMENTS"
        }
    }
    
    static func listSelections() -> [String] {
        return [AppoMode.appo.name(), AppoMode.history.name()]
    }
}

class AppoMainViewController: BaseViewController {
    @IBOutlet weak var segmentControl: ThemeSegmentedControl!
    @IBOutlet weak var listTitleLabel: ThemeImportantLabel!
    @IBOutlet weak var buttonSection: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    private let addAppoButton = RightArrowButton.fromNib()! as! RightArrowButton
    @IBOutlet weak var tableView: UITableView!
    
    private var upcoming: Results<Appo>!
    private var history: Results<Appo>!
    
    var sections: [String]?
    var appos: [String: [Appo]]?
    var selected: Appo?
    
    private var notificationToken: NotificationToken?
    private var notificationToken2: NotificationToken?
    private var mode: AppoMode = .appo {
        didSet {
            refreshView()
        }
    }
    
    override func setup() {
        super.setup()
        
        segmentControl.setupUI()
        segmentControl.items = AppoMode.listSelections()
        UIView.performWithoutAnimation {
            self.addAppoButton.labelButton.setTitle("Add appointment", for: .normal)
            self.addAppoButton.layoutIfNeeded()
        }
        buttonContainer.backgroundColor = .clear
        buttonContainer.fill(with: addAppoButton)
        addAppoButton.labelButton.addTarget(self, action: #selector(addAppoButtonPressed), for: .touchUpInside)
        addAppoButton.rightArrow.addTarget(self, action: #selector(addAppoButtonPressed), for: .touchUpInside)
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
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
        notificationToken2?.invalidate()
    }
    
    @IBAction private func segmentChanged(_ sender: PuiSegmentedControl) {
        mode = AppoMode(rawValue: sender.selectedIndex)!
    }
    
    @objc func addAppoButtonPressed() {
        performSegue(withIdentifier: "goToNewAppo", sender: self)
    }
    
    private func refreshView() {
        var allApps: Results<Appo>!
        
        switch mode {
        case .appo:
            allApps = upcoming
            buttonSection.isHidden = false
        case .history:
            allApps = history
            buttonSection.isHidden = true
        }
        tableView.updateHeaderViewHeight()
        
        listTitleLabel.text = mode.name2()
        
        self.sections = []
        self.appos = [:]
        for appo in allApps {
            guard let key = DateUtil.convert(input: appo.startTime, outputFormat: .format9) else { continue }
            
            if !self.sections!.contains(key) {
                self.sections!.append(key)
            }
            
            if self.appos![key] == nil {
                self.appos![key] = []
            }
            
            self.appos![key]?.append(appo)
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AppoDetailsViewController {
            vc.appo = selected
        }
    }
    
    override func setupRealm() {
        super.setupRealm()

        let appos = teamUserData.objects(Appo.self).sorted(byKeyPath: "startTime", ascending: true)
        
        upcoming = appos.filter("endTime >= %@", Date())
        history = appos.filter("endTime < %@", Date())
        
        notificationToken = upcoming.observe({ [weak self] changes in
            switch changes {
            case .update:
                self?.refreshView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
        
        notificationToken2 = history.observe({ [weak self] changes in
            switch changes {
            case .update:
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

extension AppoMainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections?[section] ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let appos = appos, let sections = sections else { return 0 }
        
        return appos[sections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "AppListHeaderCell") as! AppListHeaderCell
        headerCell.timeLabel.text = sections?[section]
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppListCell", for: indexPath) as? AppListCell,
              let appos = appos,
              let sections = sections,
              let appo = appos[sections[indexPath.section]]?[indexPath.row] else {
            return AppListCell()
        }
        let client: Client? = teamData.objects(Client.self).filter("_id == %@", appo.clientId).first
        cell.config(appo: appo, client: client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appos = appos, let sections = sections else { return }
        
        let selected = appos[sections[indexPath.section]]
        self.selected = selected?[indexPath.row]
        performSegue(withIdentifier: "goToAppoDetails", sender: self)
    }
}


extension AppoMainViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.appoMain
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
              var targetFrame1 = tabBarController?.tabBar.getFrameForTabAt(index: 2) else { return [] }
        
        targetFrame1.origin.y = targetFrame1.origin.y + tabBarControllerFrame.origin.y
        
        let step1 = TutorialStep(screenName: "\(TutorialName.appoMain.rawValue) + 1",
                                body: "Find all the appointment information here.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: targetFrame1,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step1)
        
        guard let targetFrame2 = segmentControl.globalFrame?.getOutlineFrame(thickness: 10.0) else { return [] }
        
        let step2 = TutorialStep(screenName: "\(TutorialName.appoMain.rawValue) + 2",
                                body: "Check past or upcoming appointments information by tabbing the switch bar.",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: targetFrame2,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step2)
        
        return tutorialSteps
    }
}
