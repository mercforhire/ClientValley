//
//  FollowUpMailDetailsViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-31.
//

import UIKit
import GrowingTextView
import UILabel_Copyable

class FollowUpMailDetailsViewController: BaseScrollingViewController {
    var mail: Mail!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var editButton: ThemeBarButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: ThemeTextFieldLabel!
    @IBOutlet weak var dateLabel: ThemeTextFieldLabel!
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var recipientsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: ThemeTextFieldLabel!
    
    private var to: [Client] = []
    
    override func setup() {
        super.setup()
        
        recipientsTableView.roundCorners()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.tintColor = UIColor.fromRGBString(rgbString: theme.textColor)!
        editButton.tintColor = UIColor.fromRGBString(rgbString: theme.textColor)!
        
        titleLabel.isCopyingEnabled = true
        dateLabel.isCopyingEnabled = true
        descriptionLabel.isCopyingEnabled = true
        
        setupNavBar()
    }
    
    private func setupNavBar() {
        guard let theme = themeManager.themeData?.countryPickerTheme,
              let viewColor = themeManager.themeData?.viewColor else { return }
        
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
        titleLabel.text = mail.title
        if let date = mail.dueDate {
            dateLabel.text = DateUtil.convert(input: date, outputFormat: .format5)
        }
        descriptionLabel.text = mail.body
        recipientsTableView.reloadData()
        recipientsTableViewHeight.constant = MailRecipientCell.CellHeight * CGFloat(to.count)
        
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        to = realm.objects(Client.self).filter("_id IN %@", mail.recipients).sorted(byKeyPath: "firstName").map({ $0 })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FollowUpEditMailViewController {
            vc.mail = mail
        }
    }
}

extension FollowUpMailDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return to.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailRecipientCell", for: indexPath) as? MailRecipientCell else {
            return MailRecipientCell()
        }
        let client = to[indexPath.row]
        cell.config(client: client)
        cell.deleteButton.isHidden = true
        return cell
    }
}
