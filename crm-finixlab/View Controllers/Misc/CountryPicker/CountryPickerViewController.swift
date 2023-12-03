//
//  CountryPickerViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-09.
//

import UIKit
import SKCountryPicker

protocol CountryPickerViewControllerDelegate: class {
    func selected(selected: Country)
    func dismissed()
}

class CountryPickerViewController: BaseViewController {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [Character] = []
    private var sectionCountries = [Character: [Country]]()
    private var selected: Country? {
        didSet {
            guard tableView != nil else { return }
            
            tableView.reloadData()
        }
    }
    weak var delegate: CountryPickerViewControllerDelegate?
    
    static func create(selected: String?, delegate: CountryPickerViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Misc", viewControllerId: "CountryPickerViewController") as! CountryPickerViewController
        vc.selected = CountryManager.shared.country(withCode: selected ?? "")
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        let countries = CountryManager.shared.countries
        sections = countries.map { String($0.countryCode.prefix(1)).first! }
            .removeDuplicates()
            .sorted(by: <)
        for section in sections {
            let sectionCountries = countries.filter({ $0.countryCode.first! == section }).removeDuplicates()
            self.sectionCountries[section] = sectionCountries
        }
        
        tableView.reloadData()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        guard let sectionIndexTheme = themeManager.themeData?.countryPickerTheme.sectionIndex else { return }
        
        tableView.sectionIndexColor = UIColor.fromRGBString(rgbString: sectionIndexTheme.textColor)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
        setupNavBar()
    }

    @IBAction func dismissPress(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
        delegate?.dismissed()
    }
}

extension CountryPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let character = sections[section]
        return sectionCountries[character]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryPickerCell", for: indexPath) as? CountryPickerCell else {
            return CountryPickerCell()
        }
        
        let character = sections[indexPath.section]
        let country = sectionCountries[character]![indexPath.row]
        cell.config(text: country.englishName, selected: selected?.countryCode == country.countryCode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CountryPickerCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = sections[indexPath.section]
        let country = sectionCountries[character]![indexPath.row]
        selected = country
        delegate?.selected(selected: country)
        dismissPress(backButton!)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { String($0) }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sections.firstIndex(of: Character(title))!
    }
}
