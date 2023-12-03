//
//  AccountFeedbackViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-06.
//

import UIKit
import GrowingTextView

class AccountFeedbackViewController: BaseScrollingViewController {
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var titleLabel: ThemeImportantLabel!
    @IBOutlet weak var messageTextView: ThemeGrowingTextView!
    
    static func create() -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Account", viewControllerId: "AccountFeedbackViewController") as! AccountFeedbackViewController
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        titleLabel.setupUI(overrideFontSize: 18.0)
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
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
        setupRealm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        guard let message = messageTextView.text, message.count > 10 else {
            showErrorDialog(error: "Message too short.")
            return
        }
        
        let newFeedback = Feedback(partition: UserManager.shared.publicPartitionKey,
                                   type: "feedback",
                                   message: message,
                                   creatorEmail: UserManager.shared.email ?? "",
                                   creator: app.currentUser!.id)
        do {
            try publicRealm.write {
                publicRealm.add(newFeedback)
            }
        } catch(let error) {
            print("\(error.localizedDescription)")
        }
        backPressed(backButton)
        showErrorDialog(error: "Thank you for your message.")
    }
}

extension AccountFeedbackViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
}
