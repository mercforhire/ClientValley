//
//  PerformanceViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-20.
//

import UIKit
import Cosmos
import PuiSegmentedControl

enum PerfDataSelections: Int {
    case my = 1
    case team = 2
    
    func name() -> String {
        switch self {
        case .my:
            return "My Performance"
        case .team:
            return "Team Performance"
        }
    }
    
    static func listSelections() -> [String] {
        return [PerfDataSelections.my.name(), PerfDataSelections.team.name()]
    }
}

class PerformanceViewController: BaseViewController {
    @IBOutlet weak var segment: ThemeSegmentedControl!
    
    @IBOutlet weak var outterCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var totalClientsLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet var blueLabels: [UILabel]!
    @IBOutlet var blackLabels: [UILabel]!
    @IBOutlet var cyanViews: [UIView]!
    @IBOutlet var dividerViews: [UIView]!
    @IBOutlet var roundButtons: [UIButton]!
    
    @IBOutlet weak var thisMonth: UILabel!
    @IBOutlet weak var thisQuarter: UILabel!
    @IBOutlet weak var thisYear: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var myTotalAppo: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var appoThisMonth: UILabel!
    @IBOutlet weak var upcomingBirthday: UILabel!
    @IBOutlet weak var topClients: UILabel!
    @IBOutlet weak var totalExpense: UILabel!
    
    @IBOutlet weak var teamTotalAppo: UILabel!
    @IBOutlet weak var teamAppoThisMonth: UILabel!
    
    private var mode: PerfDataSelections = .my {
        didSet {
            refreshView()
            
            if oldValue != mode {
                refreshViewData()
            }
        }
    }
    private var manager: PerformanceManager?
    private var timeframe: Timeframes?
    private var showAllAppos: Bool?
    
    override func setup() {
        super.setup()
        
        for view in cyanViews {
            view.roundCorners()
        }
        
        for view in roundButtons {
            view.backgroundColor = .white
            view.roundCorners(style: .completely)
            view.isUserInteractionEnabled = false
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        segment.setupUI(overrideFontSize: 14.0)
        
        guard let theme = themeManager.themeData?.performanceScreen else { return }
        
        innerCircle.layer.applySketchShadow(color: UIColor.fromRGBString(rgbString: theme.blackTextColor)!,
                                            alpha: 0.25, x: 0, y: 2,
                                            blur: 12,
                                            spread: 0)
        
        for view in cyanViews {
            view.backgroundColor = UIColor.fromRGBString(rgbString: theme.cyanViewBackgroundColor)
        }
        
        for label in blueLabels {
            label.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)
        }
        
        for label in blackLabels {
            label.textColor = UIColor.fromRGBString(rgbString: theme.blackTextColor)
        }
        
        for divider in dividerViews {
            divider.backgroundColor = UIColor.fromRGBString(rgbString: theme.dividerColor)
        }
        
        outterCircle.roundCorners(style: .completely)
        outterCircle.backgroundColor = .clear
        outterCircle.addBorder(color: UIColor.fromRGBString(rgbString: theme.bigCircleBorderColor)!)
        
        innerCircle.roundCorners(style: .completely)
        innerCircle.backgroundColor = UIColor.fromRGBString(rgbString: theme.bigCircleBackgroundColor)!
        
        totalClientsLabel.textColor = UIColor.fromRGBString(rgbString: theme.bigCyanTextColor)!
        
        thisMonth.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        thisQuarter.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        thisYear.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        email.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        phoneNumber.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        address.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        myTotalAppo.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        appoThisMonth.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        upcomingBirthday.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        topClients.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        totalExpense.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        teamTotalAppo.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
        teamAppoThisMonth.textColor = UIColor.fromRGBString(rgbString: theme.blueTextColor)!
    }
    
    private func refreshView() {
        for view in stackView.subviews {
            if view.tag != 0, view.tag != mode.rawValue {
                view.isHidden = true
            } else {
                view.isHidden = false
            }
        }
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshViewData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        showTutorialIfNeeded()
    }

    @IBAction private func segmentChanged(_ sender: PuiSegmentedControl) {
        // this gets called on start
        mode = PerfDataSelections(rawValue: sender.selectedIndex + 1)!
    }
    
    private func refreshViewData() {
        if UserManager.shared.currentTeam == nil {
            segment.items = [PerfDataSelections.my.name()]
        } else {
            segment.items = PerfDataSelections.listSelections()
        }
        
        manager = PerformanceManager(teamRealm: teamData, teamUserRealm: teamUserData)
        manager?.calculate()
        
        totalClientsLabel.text = mode == .my ? "\(manager?.myTotalClients.count ?? 0)" : "\(manager?.teamTotalClients.count ?? 0)"
        thisMonth.text = mode == .my ? "\(manager?.myNewClientsMonthCount ?? 0)" : "\(manager?.teamNewClientsMonthCount ?? 0)"
        thisQuarter.text = mode == .my ? "\(manager?.myNewClientsQuarterCount ?? 0)" : "\(manager?.teamNewClientsQuarterCount ?? 0)"
        thisYear.text = mode == .my ? "\(manager?.myNewClientsYearCount ?? 0)" : "\(manager?.teamNewClientsYearCount ?? 0)"
        email.text = mode == .my ? "\(manager?.myEmailsCount ?? 0)" : "\(manager?.teamEmailsCount ?? 0)"
        phoneNumber.text = mode == .my ? "\(manager?.myNumbersCount ?? 0)" : "\(manager?.teamNumbersCount ?? 0)"
        address.text = mode == .my ? "\(manager?.myAddressCount ?? 0)" : "\(manager?.teamAddressCount ?? 0)"
        myTotalAppo.text = mode == .my ? "\(manager?.myTotalAppos ?? 0)" : "\(manager?.teamTotalAppos ?? 0)"
        rating.rating = Double(manager?.myOverallClientsRating ?? 0.0)
        appoThisMonth.text = mode == .my ? "\(manager?.myThisMonthAppos ?? 0)" : "\(manager?.teamThisMonthAppos ?? 0)"
        upcomingBirthday.text = "\(manager?.myUpcomingBirthdays.count ?? 0)"
        topClients.text = "\(min(manager?.clientsAndAppos.count ?? 0, 20))"
        totalExpense.text = manager?.myClientExpenses.currency() ?? "$--"
        teamTotalAppo.text = "\(manager?.teamTotalAppos ?? 0)"
        teamAppoThisMonth.text = "\(manager?.teamThisMonthAppos ?? 0)"
    }
    
    @IBAction func thisMonthTap(_ sender: Any) {
        timeframe = .month
        performSegue(withIdentifier: "goToNewClients", sender: self)
    }
    
    @IBAction func thisQuarterTap(_ sender: Any) {
        timeframe = .quarter
        performSegue(withIdentifier: "goToNewClients", sender: self)
    }
    
    @IBAction func thisYearTap(_ sender: Any) {
        timeframe = .year
        performSegue(withIdentifier: "goToNewClients", sender: self)
    }
    
    @IBAction func totalAppoTap(_ sender: Any) {
        if mode == .my {
            showAllAppos = true
            performSegue(withIdentifier: "goToAppos", sender: self)
        }
    }
    
    @IBAction func appoThisMonthTap(_ sender: Any) {
        if mode == .my {
            showAllAppos = false
            performSegue(withIdentifier: "goToAppos", sender: self)
        }
    }
    
    @IBAction func birthdaysTap(_ sender: Any) {
        if let clients = manager?.myUpcomingBirthdays, clients.isEmpty {
            showErrorDialog(error: "Not enough data to show.")
        } else {
            performSegue(withIdentifier: "showBirthdays", sender: self)
        }
    }
    
    @IBAction func topApposTap(_ sender: Any) {
        if let clientsAndAppos = manager?.clientsAndAppos, clientsAndAppos.isEmpty {
            showErrorDialog(error: "Not enough data to show.")
        } else {
            performSegue(withIdentifier: "goToTopClients", sender: self)
        }
    }
    
    @IBAction func totalExpenseTap(_ sender: Any) {
        if let clientsAndAppos = manager?.clientsAndAppos, clientsAndAppos.isEmpty || manager?.myClientExpenses == 0 {
            showErrorDialog(error: "Not enough data to show.")
        } else {
            performSegue(withIdentifier: "goToTotalExpense", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PerformanceExpenseViewController {
            vc.clientsAndAppos = manager?.clientsAndAppos
        } else if let vc = segue.destination as? PerformanceNewClientsViewController {
            vc.mode1 = timeframe
            vc.mode2 = mode
        } else if let vc = segue.destination as? PerformanceApposViewController {
            vc.showAllAppos = showAllAppos
        } else if let vc = segue.destination as? PerformanceBirthdaysViewController {
            vc.clients = manager?.myUpcomingBirthdays
        } else if let vc = segue.destination as? PerformanceTopClientsViewController {
            vc.clientsAndAppos = manager?.clientsAndAppos
        }
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        
        tutorialManager?.showTutorial()
    }
}

extension PerformanceViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.perfMain
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
              var targetFrame1 = tabBarController?.tabBar.getFrameForTabAt(index: 3) else { return [] }
        
        targetFrame1.origin.y = targetFrame1.origin.y + tabBarControllerFrame.origin.y
        
        let step1 = TutorialStep(screenName: "\(TutorialName.perfMain.rawValue) + 1",
                                body: "Check your team performace here.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: targetFrame1,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step1)
        
        if UserManager.shared.currentTeam != nil {
            guard let targetFrame2 = segment.globalFrame?.getOutlineFrame(thickness: 10.0) else { return [] }
            
            let step2 = TutorialStep(screenName: "\(TutorialName.perfMain.rawValue) + 2",
                                    body: "Check your’s or the team’s performance by tabbing the switch bar.",
                                    pointingDirection: .up,
                                    pointPosition: .edge,
                                    targetFrame: targetFrame2,
                                    showDimOverlay: true,
                                    overUIWindow: true)
            tutorialSteps.append(step2)
        }
        
        return tutorialSteps
    }
}
