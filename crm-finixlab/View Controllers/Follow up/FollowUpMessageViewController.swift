//
//  FollowUpMessageViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-25.
//

import UIKit
import GrowingTextView
import RealmSwift

class FollowUpMessageViewController: BaseScrollingViewController {
    var clients: Results<Client>?
    var preSelected: [Client] = []
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var randomButton: ThemeBarButton!
    @IBOutlet weak var sendButton: ThemeBarButton!
    @IBOutlet weak var buttonContainer: UIView!
    private let chooseButton = RightArrowButton.fromNib()! as! RightArrowButton
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var recipientsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: GrowingTextView!
    
    private var draftMessage: DraftMessage!
    private var notificationToken: NotificationToken?
    private var to: [Client] = [] {
        didSet {
            refreshView()
        }
    }
    
    override func setup() {
        super.setup()
        
        chooseButton.labelButton.setTitle("Choose message template", for: .normal)
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
                draftMessage.randomize()
            }
        } catch(let error) {
            print("subjectTextView: \(error.localizedDescription)")
        }
    }
    
    @objc func openTemplates() {
        let vc = FollowUpTemplatesViewController.create(mode: .message, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteRecipient(_ sender: UIButton) {
        guard sender.tag < to.count else {
            return
        }
        
        to.remove(at: sender.tag)
    }
    
    @objc private func addRecipients(_ sender: Any) {
        guard let messagableClients = clients else { return }
        
        let vc = FollowUpAddClientViewController.create(allClients: messagableClients, excludedClients: to, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func sendPressed(_ sender: Any) {
        if validate() {
            var phoneNumbers: [String] = []
            var clientsToMessage: [Client] = []
            for client in to {
                if let phoneNumber = client.phone?.getNumberString() {
                    phoneNumbers.append(phoneNumber)
                    clientsToMessage.append(client)
                }
            }
            
            if phoneNumbers.count == 1 {
                sendMessageTo(numbers: [phoneNumbers.first!], clients: [clientsToMessage.first!])
                return
            }
            
            let ac = UIAlertController(title: nil, message: "Sending method", preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "All at once", style: .default) { [weak self] action in
                self?.sendMessageTo(numbers: phoneNumbers, clients: clientsToMessage)
            }
            ac.addAction(action1)
            
            let action2 = UIAlertAction(title: "One number at a time", style: .default) { [weak self] action in
                self?.sendOneAtATime(numbers: phoneNumbers, clients: clientsToMessage)
            }
            ac.addAction(action2)
            
            let action3 = UIAlertAction(title: "Cancel", style: .cancel)
            ac.addAction(action3)
            present(ac, animated: true)
        }
    }
    
    private func validate() -> Bool {
        if to.isEmpty {
            showErrorDialog(error: "No recipients selected.")
            return false
        }
        
        if draftMessage.body.isEmpty {
            showErrorDialog(error: "No message content.")
            return false
        }
        
        return true
    }
    
    private var numbersToSend: [String] = []
    private var clientsToSend: [Client] = []
    private var sendingNumberIndex: Int = 0
    
    private func sendOneAtATime(numbers: [String], clients: [Client]) {
        sendingNumberIndex = 0
        numbersToSend = numbers
        clientsToSend = clients
        batchSendingMessages()
    }
    
    private func batchSendingMessages() {
        guard sendingNumberIndex < numbersToSend.count,
              numbersToSend.count == clientsToSend.count else {
            return
        }

        if sendingNumberIndex == 0 {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(sendNextNumber),
                                                   name: Notifications.MailComposeDismissed,
                                                   object: nil)
        } else if sendingNumberIndex == (numbersToSend.count - 1) {
            NotificationCenter.default.removeObserver(self,
                                                      name: Notifications.MailComposeDismissed,
                                                      object: nil)
        }
        sendMessageTo(numbers: [numbersToSend[sendingNumberIndex]], clients: [clientsToSend[sendingNumberIndex]])
    }
    
    @objc private func sendNextNumber() {
        sendingNumberIndex = sendingNumberIndex + 1
        batchSendingMessages()
    }
    
    private func sendMessageTo(numbers: [String], clients: [Client]) {
        let vc = composer.configuredMessageComposeViewController(recipients: numbers, message: draftMessage.body)
        if composer.canSendText(), vc != nil {
            present(vc, animated: true)
            followUpManager?.recordFollowUp(with: clients, type: .message)
        } else {
            showErrorDialog(error: "Can't send SMS on this device.")
        }
    }
    
    private func refreshView() {
        recipientsTableView.reloadData()
        bodyTextView.text = draftMessage.body
        recipientsTableViewHeight.constant = MailRecipientCell.CellHeight * CGFloat(to.count + (clients != nil ? 1 : 0))
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(DraftMessage.self).isEmpty {
            draftMessage = DraftMessage(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(draftMessage)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            draftMessage = realm.objects(DraftMessage.self).first
        }
        
        notificationToken = draftMessage.observe({ [weak self] changes in
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

extension FollowUpMessageViewController: UITableViewDataSource, UITableViewDelegate {
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

extension FollowUpMessageViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == bodyTextView {
            do {
                try realm.write(withoutNotifying: [notificationToken!], {
                    draftMessage.body = textView.text
                })
            } catch(let error) {
                print("draftMessage: \(error.localizedDescription)")
            }
        }
    }
}

extension FollowUpMessageViewController: FollowUpAddClientViewControllerDelegate {
    func addedClients(clients: [Client]) {
        to.append(contentsOf: clients)
    }
}

extension FollowUpMessageViewController: FollowUpTemplatesViewControllerDelegate {
    func emailTemplateChoosen(template: TemplateEmail) {
        fatalError()
    }
    
    func messageTemplateChoosen(template: TemplateMessage) {
        do {
            try realm.write {
                draftMessage.body = template.message
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
}
