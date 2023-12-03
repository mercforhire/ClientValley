//
//  FollowUpMailViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import GrowingTextView
import RealmSwift

class FollowUpMailViewController: BaseScrollingViewController {
    var clients: Results<Client>?
    var preSelected: [Client] = []
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var randomButton: ThemeBarButton!
    @IBOutlet weak var titleTextView: ThemeGrowingTextView!
    @IBOutlet weak var dateField: ThemeTextField!
    @IBOutlet weak var dateDropdownButton: DropdownButton!
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var recipientsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: ThemeGrowingTextView!
    
    private var draftMail: DraftMail!
    private var notificationToken: NotificationToken?
    private var to: [Client] = [] {
        didSet {
            refreshView()
        }
    }
    
    override func setup() {
        super.setup()
        
        recipientsTableView.roundCorners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        to.append(contentsOf: preSelected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    @IBAction func randomPressed(_ sender: Any) {
        do {
            try realm.write {
                draftMail.title = Lorem.sentence
                draftMail.dueDate = Date().getPastOrFutureDate(day: Int.random(in: -50...50))
                draftMail.body = Lorem.paragraphs(1...3)
            }
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
    }
    
    @IBAction func savePress(_ sender: Any) {
        if validate() {
            let newMail = Mail(partition: UserManager.shared.teamAndUserPartitionKey, draftMail: draftMail, creator: app.currentUser!.id)
            let list: List<ObjectId> = List()
            list.append(objectsIn: to.map({ $0._id }))
            newMail.recipients = list
            do {
                try teamUserData.write {
                    teamUserData.add(newMail)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
            followUpManager?.recordFollowUp(mail: newMail)
            backPressed(backButton)
        }
    }
    
    @IBAction func dateDropdownPress(_ sender: UIButton) {
        sender.isSelected = true
        let datePickerDialog = DatePickerDialog()
        datePickerDialog.configure(selected: draftMail.dueDate ?? Date().getPastOrFutureDate(day: 1),
                                   showDimOverlay: true,
                                   overUIWindow: true)
        datePickerDialog.delegate = self
        datePickerDialog.show(inView: view, withDelay: 100)
    }
    
    @objc func deleteRecipient(_ sender: UIButton) {
        guard sender.tag < to.count else {
            return
        }
        
        to.remove(at: sender.tag)
    }
    
    @objc func addRecipient(_ sender: UIButton) {
        guard let mailableClients = clients else { return }
        
        let vc = FollowUpAddClientViewController.create(allClients: mailableClients, excludedClients: to, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    private func validate() -> Bool {
        if to.isEmpty {
            showErrorDialog(error: "No recipients selected.")
            return false
        }
        
        if draftMail.title.isEmpty {
            showErrorDialog(error: "No mail title.")
            return false
        }
        
        if draftMail.body.isEmpty {
            showErrorDialog(error: "No mail message.")
            return false
        }
        
        if draftMail.dueDate == nil {
            showErrorDialog(error: "No due data.")
            return false
        }
        
        return true
    }
    
    private func refreshView() {
        recipientsTableView.reloadData()
        titleTextView.text = draftMail.title
        bodyTextView.text = draftMail.body
        
        if let date = draftMail.dueDate {
            dateField.text = DateUtil.convert(input: date, outputFormat: .format5)
        }
        
        recipientsTableViewHeight.constant = MailRecipientCell.CellHeight * CGFloat(to.count + (clients != nil ? 1 : 0))
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(DraftMail.self).isEmpty {
            draftMail = DraftMail(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(draftMail)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            draftMail = realm.objects(DraftMail.self).first
        }
        
        notificationToken = draftMail.observe({ [weak self] changes in
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
}

extension FollowUpMailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if clients != nil {
            return to.count + 1
        }
        return to.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < to.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailRecipientCell", for: indexPath) as? MailRecipientCell else {
                return MailRecipientCell()
            }
            let client = to[indexPath.row]
            cell.config(client: client)
            cell.deleteButton.isHidden = clients == nil
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deleteRecipient), for: .touchUpInside)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailAddRecipientCell", for: indexPath) as? MailAddRecipientCell else {
                return MailAddRecipientCell()
            }
            cell.plusButton.addTarget(self, action: #selector(addRecipient), for: .touchUpInside)
            return cell
        }
    }
}

extension FollowUpMailViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        do {
            try realm.write {
                draftMail.dueDate = date.startOfDay()
            }
        } catch(let error) {
            print("\(error.localizedDescription)")
        }
        dateDropdownButton.isSelected = false
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        dateDropdownButton.isSelected = false
    }
}

extension FollowUpMailViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView {
            do {
                try realm.write(withoutNotifying: [notificationToken!], {
                    draftMail.title = titleTextView.text ?? ""
                })
            } catch(let error) {
                print(error.localizedDescription)
            }
        } else if textView == bodyTextView {
            do {
                try realm.write(withoutNotifying: [notificationToken!], {
                    draftMail.body = textView.text
                })
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
    }
}

extension FollowUpMailViewController: FollowUpAddClientViewControllerDelegate {
    func addedClients(clients: [Client]) {
        to.append(contentsOf: clients)
    }
}
