//
//  FollowUpSavedMailsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import RealmSwift
import PuiSegmentedControl

class FollowUpSavedMailsViewController: BaseViewController {
    private enum Mode: Int {
        case upcoming
        case history
        
        func name() -> String {
            switch self {
            case .upcoming:
                return "Upcoming"
            case .history:
                return "History"
            }
        }
        
        static func listSelections() -> [String] {
            return [Mode.upcoming.name(), Mode.history.name()]
        }
    }
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var segmentControl: ThemeSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var upcoming: Results<Mail>!
    private var history: Results<Mail>!
    private var notificationToken: NotificationToken?
    private var notificationToken2: NotificationToken?
    private var mode: Mode = .upcoming {
        didSet {
            refreshView()
        }
    }
    private var selectedMail: Mail?
    
    static func create() -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpSavedMailsViewController") as! FollowUpSavedMailsViewController
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        segmentControl.items = Mode.listSelections()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        segmentControl.setupUI(overrideFontSize: 12.0)
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
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
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
        notificationToken2?.invalidate()
    }
    
    @IBAction private func segmentChanged(_ sender: PuiSegmentedControl) {
        mode = Mode(rawValue: sender.selectedIndex)!
    }
    
    private func refreshView() {
        tableView.reloadData()
    }
    
    override func setupRealm() {
        super.setupRealm()

        let mails = teamUserData.objects(Mail.self).sorted(byKeyPath: "dueDate", ascending: true)
        
        upcoming = mails.filter("dueDate >= %@", Date().startOfDay())
        history = mails.filter("dueDate < %@", Date().startOfDay())
        
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
    
    @objc func goToEditSavedMail() {
        performSegue(withIdentifier: "goToEditSavedMail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FollowUpEditMailViewController {
            vc.mail = selectedMail
        } else if let vc = segue.destination as? FollowUpMailDetailsViewController {
            vc.mail = selectedMail
        }
    }
}

extension FollowUpSavedMailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .upcoming:
            return upcoming.count
        case .history:
            return history.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailSavedCell", for: indexPath) as? MailSavedCell else {
            return MailSavedCell()
        }
        switch mode {
        case .upcoming:
            cell.config(mail: upcoming[indexPath.row], upcoming: true)
            cell.editButton.addTarget(self, action: #selector(goToEditSavedMail), for: .touchUpInside)
        case .history:
            cell.config(mail: history[indexPath.row], upcoming: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch mode {
        case .upcoming:
            selectedMail = upcoming[indexPath.row]
        case .history:
            selectedMail = history[indexPath.row]
        }
        performSegue(withIdentifier: "goToMailDetails", sender: self)
    }
}
