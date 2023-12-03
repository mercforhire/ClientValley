//
//  FollowUpEmailViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import UIKit
import GrowingTextView
import RealmSwift

class FollowUpEmailViewController: BaseScrollingViewController {
    var clients: Results<Client>?
    var preSelected: [Client] = []
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var randomButton: ThemeBarButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var sendButton: ThemeBarButton!
    @IBOutlet weak var buttonContainer: UIView!
    private let chooseButton = RightArrowButton.fromNib()! as! RightArrowButton
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var recipientsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var subjectTextView: GrowingTextView!
    @IBOutlet weak var bodyTextView: GrowingTextView!
    
    private var draftEmail: DraftEmail!
    private var notificationToken: NotificationToken?
    private var to: [Client] = [] {
        didSet {
            refreshView()
        }
    }
    
    override func setup() {
        super.setup()
  
        chooseButton.labelButton.setTitle("Choose email template", for: .normal)
        chooseButton.labelButton.addTarget(self, action: #selector(openTemplates), for: .touchUpInside)
        buttonContainer.backgroundColor = .clear
        buttonContainer.fill(with: chooseButton)
        
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
                draftEmail.randomize()
            }
        } catch(let error) {
            print("subjectTextView: \(error.localizedDescription)")
        }
    }
    
    @objc func openTemplates() {
        let vc = FollowUpTemplatesViewController.create(mode: .email, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteRecipient(_ sender: UIButton) {
        guard sender.tag < to.count else {
            return
        }
        
        to.remove(at: sender.tag)
    }
    
    @objc private func addRecipients(_ sender: UIButton) {
        guard let emailableClients = clients else { return }
        
        let vc = FollowUpAddClientViewController.create(allClients: emailableClients, excludedClients: to, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshView() {
        recipientsTableView.reloadData()
        subjectTextView.text = draftEmail.subject
        bodyTextView.text = draftEmail.body
        
        recipientsTableViewHeight.constant = MailRecipientCell.CellHeight * CGFloat(to.count + (clients != nil ? 1 : 0))
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @IBAction private func sendPressed(_ sender: Any) {
        if validate() {
            var emails: [String] = []
            for client in to {
                if let email = client.email {
                    emails.append(email)
                }
            }
            var toRecipients: [String] = []
            if let myEmail = UserManager.shared.email {
                toRecipients.append(myEmail)
            }
            let vc = composer.configuredEmailComposeViewController(toRecipients: toRecipients, ccRecipients: [], bccRecipients: emails, subject: draftEmail.subject, message: draftEmail.body)

            if composer.canSendEmail(), vc != nil {
                present(vc, animated: true)
                followUpManager?.recordFollowUp(with: to, type: .email)
            } else {
                showErrorDialog(error: "Can't send email on this device.")
            }
        }
    }
    
    private func validate() -> Bool {
        if to.isEmpty {
            showErrorDialog(error: "No recipients selected.")
            return false
        }
        
        if draftEmail.subject.isEmpty {
            showErrorDialog(error: "No subject.")
            return false
        }
        
        if draftEmail.body.isEmpty {
            showErrorDialog(error: "No message content.")
            return false
        }
        
        return true
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(DraftEmail.self).isEmpty {
            draftEmail = DraftEmail(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(draftEmail)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            draftEmail = realm.objects(DraftEmail.self).first
        }
        
        notificationToken = draftEmail.observe({ [weak self] changes in
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

extension FollowUpEmailViewController: UITableViewDataSource, UITableViewDelegate {
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
            cell.plusButton.addTarget(self, action: #selector(addRecipients), for: .touchUpInside)
            return cell
        }
    }
}

extension FollowUpEmailViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == subjectTextView {
            do {
                try realm.write(withoutNotifying: [notificationToken!], {
                    draftEmail.subject = textView.text
                })
            } catch(let error) {
                print(error.localizedDescription)
            }
        } else if textView == bodyTextView {
            do {
                try realm.write(withoutNotifying: [notificationToken!], {
                    draftEmail.body = textView.text
                })
            } catch(let error) {
                print(error.localizedDescription)
            }
        }
    }
}

extension FollowUpEmailViewController: FollowUpAddClientViewControllerDelegate {
    func addedClients(clients: [Client]) {
        to.append(contentsOf: clients)
    }
}

extension FollowUpEmailViewController: FollowUpTemplatesViewControllerDelegate {
    func emailTemplateChoosen(template: TemplateEmail) {
        do {
            try realm.write {
                draftEmail.subject = template.subject
                draftEmail.body = template.body
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func messageTemplateChoosen(template: TemplateMessage) {
        fatalError()
    }
}
