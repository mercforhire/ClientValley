//
//  FollowUpEditMailViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import GrowingTextView
import RealmSwift

class FollowUpEditMailViewController: BaseScrollingViewController {
    var mail: Mail!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var titleTextView: ThemeGrowingTextView!
    @IBOutlet weak var dateField: ThemeTextField!
    @IBOutlet weak var dateDropdownButton: DropdownButton!
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var recipientsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: GrowingTextView!
    
    private var mailableClients: Results<Client>!
    
    private var to: [Client] = [] {
        didSet {
            refreshRecipientsTableView()
        }
    }
    private var date: Date! {
        didSet {
            dateField.text = DateUtil.convert(input: date, outputFormat: .format5)
        }
    }
    
    override func setup() {
        super.setup()
        
        recipientsTableView.roundCorners()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
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
    
    private func refreshView() {
        titleTextView.text = mail.title
        bodyTextView.text = mail.body
        date = mail.dueDate ?? Date().getPastOrFutureDate(day: 1)
        to = teamData.objects(Client.self).filter("_id IN %@", mail.recipients).sorted(byKeyPath: "firstName").map({ $0 })
    }
    
    private func refreshRecipientsTableView() {
        recipientsTableView.reloadData()
        if recipientsTableViewHeight.constant != MailRecipientCell.CellHeight * CGFloat(to.count + 1) {
            recipientsTableViewHeight.constant = MailRecipientCell.CellHeight * CGFloat(to.count + 1)
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
        }
    }
    
    @IBAction func randomPressed(_ sender: Any) {
        NotificationManager.shared.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                NotificationManager.shared.scheduleMailingNotification(mail: self.mail,
                                                                       overrideDate: Date().getPastOrFutureDate(minute: 1),
                                                                       overridePrevious: true)
                { success in
                    success ? showErrorDialog(error: "A test notification created for the next minute!") : nil
                }
            } else {
                showErrorDialog(error: "Notification not enabled, unable to set a test notification!")
            }
        }
    }
    
    @IBAction func deletePress(_ sender: Any) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to delete this mail?", secondary: "Cancel", primary: "Yes")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1 {
            followUpManager?.deleteFollowUp(mail: mail)
            do {
                try teamUserData.write {
                    teamUserData.delete(mail)
                }
                backPressed(backButton)
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func savePress(_ sender: Any) {
        do {
            try teamUserData.write {
                mail.title = titleTextView.text ?? ""
                mail.body = bodyTextView.text
                let list: List<ObjectId> = List()
                list.append(objectsIn: to.map({ $0._id }))
                mail.recipients = list
                mail.dueDate = date
                
            }
        } catch(let error) {
            print("\(error.localizedDescription)")
        }
        followUpManager?.recordFollowUp(mail: mail)
        NotificationManager.shared.scheduleMailingNotification(mail: mail, overridePrevious: true) { success in
            
        }
        backPressed(backButton)
    }
    
    @IBAction func dateDropdownPress(_ sender: UIButton) {
        sender.isSelected = true
        let datePickerDialog = DatePickerDialog()
        datePickerDialog.configure(selected: date ?? Date().getPastOrFutureDate(day: 1),
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
        let vc = FollowUpAddClientViewController.create(allClients: mailableClients, excludedClients: to, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    override func setupRealm() {
        super.setupRealm()
        mailableClients = teamData.objects(Client.self).filter("contactMethod.byMail == true")
    }
}

extension FollowUpEditMailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return to.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < to.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailRecipientCell", for: indexPath) as? MailRecipientCell else {
                return MailRecipientCell()
            }
            let client = to[indexPath.row]
            cell.config(client: client)
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

extension FollowUpEditMailViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        self.date = date.startOfDay()
        dateDropdownButton.isSelected = false
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        dateDropdownButton.isSelected = false
    }
}


extension FollowUpEditMailViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
}

extension FollowUpEditMailViewController: FollowUpAddClientViewControllerDelegate {
    func addedClients(clients: [Client]) {
        to.append(contentsOf: clients)
    }
}
