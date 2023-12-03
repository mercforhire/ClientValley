//
//  PerformanceBirthdaysViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-21.
//

import UIKit

class PerformanceBirthdaysViewController: BaseViewController {
    var clients: [Client]!
    
    @IBOutlet weak var tableView: UITableView!
    private var clickedClient: Client?
    
    override func setup() {
        super.setup()
    }
    
    override func setupTheme() {
        super.setupTheme()

        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClientProfileViewController {
            vc.client = clickedClient
        }
    }
}

extension PerformanceBirthdaysViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Client2LinesTableViewCell", for: indexPath) as? Client2LinesTableViewCell else {
            return Client2LinesTableViewCell()
        }
        let client = clients[indexPath.row]
        cell.config(client: client, mode: .birthday)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let client = clients[indexPath.row]
        clickedClient = client
        performSegue(withIdentifier: "showClient", sender: self)
    }
}
