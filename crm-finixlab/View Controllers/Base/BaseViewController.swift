//
//  BaseViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//
import Foundation
import UIKit
import RealmSwift

class BaseViewController: UIViewController {
    let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var themeView: ThemeView!
    
    var realm: Realm!
    var publicRealm: Realm!
    private var teamRealm: Realm?
    private var teamUserRealm: Realm?
    
    var teamData: Realm {
        return teamRealm ?? realm
    }
    
    var teamUserData: Realm {
        return teamUserRealm ?? realm
    }
    
    private(set) var viewUsesRealm = false
    
    lazy var composer: MessageComposer = MessageComposer()
    lazy var inputToolbar: UIToolbar = {
        guard let theme = themeManager.themeData?.keyboardToolBarTheme else { return UIToolbar() }
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolbarDonePress))
        doneButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonColor)
        doneButton.setTitleTextAttributes([.font: theme.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme.buttonColor)!],
                                          for: .normal)
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceButton.width = 10.0
        
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(toolbarDoneNext))
        nextButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonColor)
        let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(toolbarDonePrev))
        previousButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonColor)
        
        toolbar.setItems([fixedSpaceButton, previousButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var simpleInputToolbar: UIToolbar = {
        guard let theme = themeManager.themeData?.keyboardToolBarTheme else { return UIToolbar() }
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolbarDonePress))
        doneButton.tintColor = UIColor.fromRGBString(rgbString: theme.buttonColor)
        doneButton.setTitleTextAttributes([.font: theme.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme.buttonColor)!],
                                          for: .normal)
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    var followUpManager: FollowUpManager?
    var tutorialManager: TutorialManager?
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        guard let themeData = themeManager.themeData else { return }
        
        view.backgroundColor = UIColor.fromRGBString(rgbString: themeData.navBarTheme.backgroundColor)
        
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTeamChanged), name: Notifications.TeamChanged, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard themeView != nil else { return }
        
        themeView.roundSelectedCorners(corners: [.topLeft, .topRight], radius: 25.0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notifications.TeamChanged, object: nil)
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIViewController.topViewController == self else { return }

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "dark"])
            } else {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "light"])
            }
        }
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func toolbarDonePrev() {
        // override
    }
    
    @objc func toolbarDoneNext() {
        // override
    }
    
    @objc func toolbarDonePress() {
        view.endEditing(true)
    }
    
    @IBAction func quitPressed(_ sender: UIBarButtonItem) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "By clicking the button, the app will take you back to Client page.", secondary: "Cancel", primary: "Quit Anyway")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    func showCallActionSheet(client: Client) {
        guard let phoneNumberString = client.phone?.getFormattedString(), let numberString = client.phone?.getNumberString() else {
            showErrorDialog(error: "Invalid or missing phone number information")
            return
        }
        
        let ac = UIAlertController(title: nil, message: phoneNumberString, preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "Call", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            if self.composer.canCall(phoneNumber: numberString) {
                self.followUpManager?.recordFollowUp(with: [client], type: .phone)
                self.composer.call(phoneNumber: numberString)
            }
        }
        ac.addAction(callAction)
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = numberString
        }
        ac.addAction(copyAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func setupRealm() {
        guard let realmConfiguration = UserManager.shared.userRealmConfig else {
            fatalError()
        }
        
        realm = try! Realm(configuration: realmConfiguration)
        
        if let teamRealmConfig = UserManager.shared.teamRealmConfig,
           let teamUserRealmConfig = UserManager.shared.teamUserRealmConfig {
            teamRealm = try! Realm(configuration: teamRealmConfig)
            teamUserRealm = try! Realm(configuration: teamUserRealmConfig)
        } else {
            teamRealm = nil
            teamUserRealm = nil
        }
        followUpManager = FollowUpManager(teamRealm: teamData, teamUserRealm: teamUserData)
        
        if let publicRealmConfig = UserManager.shared.publicRealmConfig {
            publicRealm = try! Realm(configuration: publicRealmConfig)
        } else {
            publicRealm = nil
        }
        
        viewUsesRealm = true
    }
    
    @objc func handleTeamChanged() {
        guard viewUsesRealm else { return }
        
        setupRealm()
    }
}

extension BaseViewController: DialogDelegate {
    @objc func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func dismissedDialog(dialog: Dialog) {
        
    }
}
