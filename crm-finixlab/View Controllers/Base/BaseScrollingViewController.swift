//
//  BaseScrollingViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-23.
//

import UIKit
import Foundation
import ScrollingContentViewController
import RealmSwift

class BaseScrollingViewController: ScrollingContentViewController {
    let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var themeView: ThemeView!
    
    var realm: Realm!
    var publicRealm: Realm!
    var teamRealm: Realm?
    var teamUserRealm: Realm?
    
    var teamData: Realm {
        return teamRealm ?? realm
    }
    var teamUserData: Realm {
        return teamUserRealm ?? realm
    }
    
    private(set) var viewUsesRealm = false
    
    lazy var quitDialog = Dialog()
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
    var fieldsGroup: [UIView] = []
    var highlightedFieldIndex: Int?
    var requiredFields: [RequiredField] = []
    var requiredOneFields: [RequiredOneField] = []
    var followUpManager: FollowUpManager?
    var tutorialManager: TutorialManager?
    
    func setup() {
        setupTheme()
    }
    
    func setupTheme() {
        guard let themeData = themeManager.themeData?.navBarTheme else { return }
        
        scrollView.backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        scrollView.subviews[0].backgroundColor = UIColor.fromRGBString(rgbString: themeData.backgroundColor)
        
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
        
        guard let themeView = themeView else { return }
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
        guard let highlightedFieldIndex = highlightedFieldIndex else { return }
        
        if highlightedFieldIndex == 0 {
            focusOnHighlightedField(index: fieldsGroup.count - 1)
        } else {
            focusOnHighlightedField(index: highlightedFieldIndex - 1)
        }
    }
    
    @objc func toolbarDoneNext() {
        guard let highlightedFieldIndex = highlightedFieldIndex else { return }
        
        if highlightedFieldIndex == fieldsGroup.count - 1 {
            focusOnHighlightedField(index: 0)
        } else {
            focusOnHighlightedField(index: highlightedFieldIndex + 1)
        }
    }
    
    @objc func toolbarDonePress() {
        view.endEditing(true)
    }
    
    func focusOnHighlightedField(index: Int) {
        guard index < fieldsGroup.count else { return }
        
        fieldsGroup[index].becomeFirstResponder()
    }
    
    @IBAction func quitPressed(_ sender: UIBarButtonItem) {
        let config = DialogConfig(title: "Warning",
                                  body: "By clicking the button, the app will take you back to Client page.",
                                  secondary: "Cancel",
                                  primary: "Quit Anyway")
        quitDialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        quitDialog.delegate = self
        quitDialog.show(inView: view, withDelay: 100)
    }
    
    var originalLabelColor: UIColor?
    
    func validateRequiredFields() -> Bool {
        guard let theme = themeManager.themeData?.textFieldTheme,
              let errorColor = theme.errorTextColor else { return true }
        
        var noErrors = true
        for requiredField in requiredFields {
            if originalLabelColor == nil {
                originalLabelColor = requiredField.fieldLabel.textColor
            }
            
            if requiredField.field.text?.trim().isEmpty ?? true {
                requiredField.fieldLabel.textColor = UIColor.fromRGBString(rgbString: errorColor)
                noErrors = false
            } else {
                requiredField.fieldLabel.textColor = originalLabelColor
            }
        }
        
        for requiredOneField in requiredOneFields {
            if originalLabelColor == nil {
                originalLabelColor = requiredOneField.fieldLabel.textColor
            }
            
            if requiredOneField.field.text?.trim().isEmpty ?? true, requiredOneField.field2.text?.trim().isEmpty ?? true {
        
                if requiredOneField.field.text?.trim().isEmpty ?? true {
                    requiredOneField.fieldLabel.textColor = UIColor.fromRGBString(rgbString: errorColor)
                }
                
                if requiredOneField.field2.text?.trim().isEmpty ?? true {
                    requiredOneField.fieldLabel2.textColor = UIColor.fromRGBString(rgbString: errorColor)
                }
                
                noErrors = false
            } else {
                requiredOneField.fieldLabel.textColor = originalLabelColor
                requiredOneField.fieldLabel2.textColor = originalLabelColor
            }
        }
        
        return noErrors
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

extension BaseScrollingViewController: DialogDelegate {
    @objc func buttonSelected(index: Int, dialog: Dialog) {
        if dialog == quitDialog, index == 1 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func dismissedDialog(dialog: Dialog) {
        
    }
}
