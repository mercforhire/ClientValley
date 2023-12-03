//
//  ClientAttributesViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-14.
//

import UIKit
import RealmSwift

class ClientAttributesViewController: BaseViewController {
    var client: Client!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var notificationToken: NotificationToken?
    
    override func setupTheme() {
        guard let navButtonTheme = themeManager.themeData?.navBarTheme.barButton else { return }
        
        backButton.tintColor = UIColor.fromRGBString(rgbString: navButtonTheme.textColor)!
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
    
    @objc func switchChanged(_ sender: UISwitch) {
        let attribute = OptionalAttributes.list()[sender.tag]
        
        if sender.isOn {
            switch attribute {
            case .notes:
                do {
                    try teamData.write {
                        client.metadata?.notes = ""
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            case .totalExpense:
                do {
                    try teamData.write {
                        client.metadata?.totalSpending = 0.0
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            }
        } else {
            switch attribute {
            case .notes:
                do {
                    try teamData.write {
                        client.metadata?.notes = nil
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            case .totalExpense:
                do {
                    try teamData.write {
                        client.metadata?.totalSpending = nil
                    }
                } catch(let error) {
                    print("setupRealm \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        notificationToken = client.metadata?.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.tableView.reloadData()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
    }
}

extension ClientAttributesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionalAttributes.list().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelSwitchCell", for: indexPath) as? LabelSwitchCell else {
            return LabelSwitchCell()
        }
        let attribute = OptionalAttributes.list()[indexPath.row]
        
        var shouldBeOn: Bool = true
        switch attribute {
        case .notes:
            if client.metadata?.notes == nil {
                shouldBeOn = false
            }
        case .totalExpense:
            if client.metadata?.totalSpending == nil {
                shouldBeOn = false
            }
        }
        
        cell.config(label: attribute.title(), isOn: shouldBeOn)
        cell.rightSwitch.tag = indexPath.row
        cell.rightSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return cell
    }
}
