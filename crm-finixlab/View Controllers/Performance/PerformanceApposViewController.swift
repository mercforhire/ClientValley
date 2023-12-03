//
//  PerformanceApposViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-20.
//

import UIKit
import RealmSwift

class PerformanceApposViewController: BaseViewController {
    var showAllAppos: Bool!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var notificationToken: NotificationToken?
    private var results: Results<Appo>?
    private var clients: [Appo: Client]?
    private var selected: Appo?
    
    override func setup() {
        super.setup()
        
        if showAllAppos {
            title = "All Appointments"
        } else {
            title = "Appointments This Month"
        }
    }
    
    override func setupTheme() {
        super.setupTheme()

        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
        refreshView()
    }

    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    private func refreshView() {
        guard let results = results else { return }
        
        self.clients = [:]
        let clients = teamData.objects(Client.self)
        for appo in results {
            if let client = clients.filter("_id == %@", appo.clientId).first {
                self.clients?[appo] = client
            }
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
        
        var appos = teamUserData.objects(Appo.self)
        if !showAllAppos {
            appos = appos.filter("startTime BETWEEN {%@, %@}", Date().startOfMonth(), Date().endOfMonth())
        }
        appos = appos.sorted(byKeyPath: "startTime", ascending: true)
        self.results = appos
        
        notificationToken = appos.observe({ [weak self] changes in
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
}

extension PerformanceApposViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppoTableViewCell", for: indexPath) as? AppoTableViewCell,
              let appo = results?[indexPath.row] else {
            return AppoTableViewCell()
        }
        
        cell.config(index: indexPath.row + 1, client: clients?[appo], appo: appo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selected = results?[indexPath.row] else { return }
        
        self.selected = selected
        performSegue(withIdentifier: "goToAppoDetails", sender: self)
    }
}
