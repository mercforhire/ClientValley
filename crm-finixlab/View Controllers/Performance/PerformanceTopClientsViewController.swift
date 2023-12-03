//
//  PerformanceTopClientsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-09-21.
//

import UIKit

class PerformanceTopClientsViewController: BaseViewController {
    var clientsAndAppos: [(Client, [Appo])]!
    
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

extension PerformanceTopClientsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientsAndAppos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Client2LinesTableViewCell", for: indexPath) as? Client2LinesTableViewCell else {
            return Client2LinesTableViewCell()
        }
        let data = clientsAndAppos[indexPath.row]
        cell.config(client: data.0, mode: .appos(data.1.count))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = clientsAndAppos[indexPath.row]
        let client = data.0
        clickedClient = client
        performSegue(withIdentifier: "showClient", sender: self)
    }
}
