//
//  ClientProfileViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GSKStretchyHeaderView
import PuiSegmentedControl
import RealmSwift

class ClientProfileViewController: BaseViewController {
    var client: Client!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var userSettings: UserSettings!
    private var notificationToken: NotificationToken?
    private let stretchyHeader = ProfileDetailsHeader.fromNib()! as! ProfileDetailsHeader
    private var creator: TeamMember?
    
    private var mode: ProfileDetailType = .basic {
        didSet {
            switch mode {
            case .basic:
                rows = ProfileInfoRows.basicInfolist()
            case .additional:
                rows = ProfileInfoRows.additionalList()
            }
            
            tableView.reloadData()
        }
    }
    private var rows: [ProfileInfoRows] = []
    
    override func setup() {
        navigationController?.navigationBar.isHidden = true
        super.setup()
        
        let headerSize = CGSize(width: tableView.frame.size.width, height: 200)
        stretchyHeader.frame = CGRect(x: 0,
                                      y: 0,
                                      width: headerSize.width,
                                      height: headerSize.height)
        tableView.addSubview(stretchyHeader)
        stretchyHeader.starButton.addTarget(self, action: #selector(starPressed(_:)), for: .touchUpInside)
        stretchyHeader.backButton.addTarget(self, action: #selector(backPressed(_:)), for: .touchUpInside)
        stretchyHeader.editButton.addTarget(self, action: #selector(editPressed(_:)), for: .touchUpInside)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        refreshView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func starPressed(_ sender: UIBarButtonItem) {
        do {
            try realm.write {
                if !userSettings.starredClients.contains(client._id) {
                    userSettings.starredClients.insert(client._id)
                } else {
                    userSettings.starredClients.remove(client._id)
                }
                
                stretchyHeader.configureUI(client: client, userSettings: userSettings)
            }
        } catch(let error) {
            print("setupRealm \(error.localizedDescription)")
        }
    }
    
    @objc func editPressed(_ sender: UIBarButtonItem) {
        if client.creator != app.currentUser?.id {
            showErrorDialog(error: "Can not edit client you did not create.")
        } else {
            performSegue(withIdentifier: "goToEdit", sender: self)
        }
    }
    
    @objc private func segmentChanged(_ sender: PuiSegmentedControl) {
        mode = ProfileDetailType(rawValue: sender.selectedIndex)!
    }
    
    @objc private func addModifyAttributesPressed(_ sender: UIButton) {
        if client.creator != app.currentUser?.id {
            showErrorDialog(error: "Can not edit client you did not create.")
        } else {
            performSegue(withIdentifier: "goToManage", sender: self)
        }
    }
    
    @objc func emailIconTapped() {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpEmailViewController") as! FollowUpEmailViewController
        vc.preSelected = [client]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func phoneIconTapped() {
        guard let _ = client.phone else { return }
        
        showCallActionSheet(client: client)
    }
    
    @objc func messageIconTapped() {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpMessageViewController") as! FollowUpMessageViewController
        vc.preSelected = [client]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addressIconTapped() {
        let vc = StoryboardManager.loadViewController(storyboard: "FollowUp", viewControllerId: "FollowUpMailViewController") as! FollowUpMailViewController
        vc.preSelected = [client]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func refreshView() {
        stretchyHeader.configureUI(client: client, userSettings: userSettings)
        tableView.reloadData()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(UserSettings.self).isEmpty {
            userSettings = UserSettings(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(userSettings)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            userSettings = realm.objects(UserSettings.self).first
        }
        
        if let creatorID = client.creator,
           let creator = publicRealm.objects(TeamMember.self).filter("userId == %@", creatorID).first {
            self.creator = creator
        }
        
        notificationToken = client.observe({ [weak self] changes in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ClientProfileEditViewController {
            viewController.client = client
        } else if let viewController = segue.destination as? ClientAttributesViewController {
            viewController.client = client
        }
    }
}

extension ClientProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0 && indexPath.row != 1 {
            let row = rows[indexPath.row - 2]
            switch row {
            case .notes:
                if client.metadata?.notes == nil {
                    return 0
                }
            case .totalExpense:
                if client.metadata?.totalSpending == nil {
                    return 0
                }
            default:
                break
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileContactsCell", for: indexPath) as? ClientProfileContactsCell else {
                return ClientProfileContactsCell()
            }
            cell.config(email: client.contactMethod?.byEmail ?? false,
                        phone: client.contactMethod?.byPhone ?? false,
                        message: client.contactMethod?.byMessage ?? false,
                        address: client.contactMethod?.byMail ?? false)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(emailIconTapped))
            cell.emailIcon.addGestureRecognizer(tap1)
            
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(phoneIconTapped))
            cell.phoneIcon.addGestureRecognizer(tap2)
            
            let tap3 = UITapGestureRecognizer(target: self, action: #selector(messageIconTapped))
            cell.messageIcon.addGestureRecognizer(tap3)
            
            let tap4 = UITapGestureRecognizer(target: self, action: #selector(addressIconTapped))
            cell.addressIcon.addGestureRecognizer(tap4)
            
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileSegmentControlCell", for: indexPath) as? ClientProfileSegmentControlCell else {
                return ClientProfileSegmentControlCell()
            }
            cell.segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
            return cell
        } else {
            let row = rows[indexPath.row - 2]
            
            switch row {
            case .clientID:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.clientID, border: true)
                return cell
            case .creator:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: creator?.fullName ?? "Unknown", border: true)
                return cell
            case .birthday:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.birthdayString ?? "", border: true)
                return cell
            case .gender:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.statusEnum?.gender() ?? " ", border: true)
                return cell
            case .email:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.email ?? "", border: true)
                return cell
            case .phone:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.phone?.phone ?? "", border: true)
                return cell
            case .nation:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.address?.country ?? "", border: true)
                return cell
            case .address:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.address?.fullAddress() ?? "", border: true)
                return cell
            case .notes:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: client.metadata?.notes ?? "", border: false)
                return cell
            case .totalExpense:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileTextViewCell", for: indexPath) as? ClientProfileTextViewCell else {
                    return ClientProfileTextViewCell()
                }
                
                cell.config(title: row.title(), content: "$\(String(format: "%.2f", client.metadata?.totalSpending ?? 0))", border: true)
                return cell
            case .ratings:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileRatingCell", for: indexPath) as? ClientProfileRatingCell else {
                    return ClientProfileRatingCell()
                }
                
                cell.config(rating: client.metadata?.rating ?? 0)
                return cell
            case .tags:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileHashtagsCell", for: indexPath) as? ClientProfileHashtagsCell else {
                    return ClientProfileHashtagsCell()
                }
                
                cell.config(tags: client.metadata?.hashtags.sorted() ?? [])
                return cell
            case .editAttribute:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientProfileModifyCell", for: indexPath) as? ClientProfileModifyCell else {
                    return ClientProfileModifyCell()
                }
                
                cell.addButton.labelButton.addTarget(self, action: #selector(addModifyAttributesPressed(_:)), for: .touchUpInside)
                cell.addButton.rightArrow.addTarget(self, action: #selector(addModifyAttributesPressed(_:)), for: .touchUpInside)
                return cell
            }
        }
    }
}
