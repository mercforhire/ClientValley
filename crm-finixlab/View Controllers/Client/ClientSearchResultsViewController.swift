//
//  ClientSearchResultsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-12.
//

import UIKit
import RealmSwift

class ClientSearchResultsViewController: BaseViewController {
    var results: Results<Client>!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var resultsCountLabel: ThemeLabel!
    @IBOutlet weak var tableView: UITableView!
    private var notificationToken: NotificationToken?
    private var selected: Client?
    
    override func setup() {
        super.setup()
        resultsCountLabel.text = "\(results.count) Results"
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.searchResultTheme.resultsLabel else { return }
        
        resultsCountLabel.theme = theme
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ClientProfileViewController {
            viewController.client = selected
        }
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    private func refreshView() {
        tableView.reloadData()
        resultsCountLabel.text = "\(results.count) Results"
    }
    
    override func setupRealm() {
        notificationToken = results.observe({ [weak self] changes in
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

extension ClientSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientSearchResultCell", for: indexPath) as? ClientSearchResultCell else {
            return ClientSearchResultCell()
        }
        cell.config(data: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = results[indexPath.row]
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
}
