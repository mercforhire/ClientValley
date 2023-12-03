//
//  AccountEditViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-30.
//

import UIKit
import RealmSwift
import FMPhotoPicker

class AccountEditViewController: BaseScrollingViewController {

    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var firstnameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var firstnameField: ThemeTextField!
    @IBOutlet weak var lastnameLabel: ThemeTextFieldLabel!
    @IBOutlet weak var lastnameField: ThemeTextField!
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    
    private let userManager = UserManager.shared
    private var userData: UserData!
    private lazy var myCamera = UIImagePickerController()
    var image: UIImage? {
        didSet {
            if image == nil {
                let config = AvatarImageConfiguration(image: nil, name: userData.initials)
                avatar.config(configuration: config)
            } else {
                let config = AvatarImageConfiguration(image: image, name: userData.initials)
                avatar.config(configuration: config)
            }
        }
    }
    
    static func create() -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Account", viewControllerId: "AccountEditViewController") as! AccountEditViewController
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        areaCodeField.setupUI(insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
        
        requiredFields.append(RequiredField(fieldLabel: firstnameLabel, field: firstnameField))
        requiredFields.append(RequiredField(fieldLabel: lastnameLabel, field: lastnameField))
        
        fieldsGroup.append(firstnameField)
        fieldsGroup.append(lastnameField)
        fieldsGroup.append(areaCodeField)
        fieldsGroup.append(phoneField)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        guard let textFieldTheme = themeManager.themeData?.textFieldTheme else { return }
        
        emailLabel.textColor = UIColor.fromRGBString(rgbString: textFieldTheme.textColor)
        emailLabel.font = textFieldTheme.font.toFont()
        
        setupNav()
    }
    
    private func setupNav() {
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
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNav()
    }
    
    @IBAction func editAvatarPressed(_ sender: Any) {
        let ac = UIAlertController(title: nil, message: "Change profile photo", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera), UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera) != nil {
                self.myCamera.sourceType = .camera
                self.myCamera.cameraDevice = .rear
                self.myCamera.delegate = self
                self.myCamera.showsCameraControls = true
                self.myCamera.allowsEditing = true
                self.present(self.myCamera, animated: false, completion: nil)
            }  else {
                showErrorDialog(error: "No camera device found.")
            }
        }
        ac.addAction(cameraAction)
        
        let pickerAction = UIAlertAction(title: "Library", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            let picker = FMPhotoPickerViewController(config: self.photoPickerConfig())
            picker.delegate = self
            self.present(picker, animated: true)
        }
        ac.addAction(pickerAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if validateRequiredFields() {
            do {
                try realm.write {
                    userData.avatar = image?.pngData()
                    if userData.phone == nil {
                        userData.phone = Phone()
                    }
                    userData.phone?.area = (areaCodeField.text ?? "").digits
                    userData.phone?.phone = (phoneField.text ?? "").digits
                    userData.firstName = firstnameField.text ?? ""
                    userData.lastName = lastnameField.text ?? ""
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
            backPressed(backButton)
        }
    }
    
    private func refreshView() {
        image = userData.avatarImage
        firstnameField.text = userData.firstName
        lastnameField.text = userData.lastName
        emailLabel.text = userManager.email
        areaCodeField.text = userData.phone?.area.addPlusSignToAreaCode()
        phoneField.text = userData.phone?.phone
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        userData = userManager.userData
    }
}


extension AccountEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else { return }
            
            self?.image = image.resizeImage(100, opaque: true)
        }
    }
}

extension AccountEditViewController: FMPhotoPickerViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        image = photo.resizeImage(100, opaque: true)
        dismiss(animated: true, completion: nil)
    }
    
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        guard let photo = photos.first else { return }
        
        image = photo.resizeImage(100, opaque: true)
        dismiss(animated: true, completion: nil)
    }
}

extension AccountEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == areaCodeField || textField == phoneField {
            if string.count > 1 {
                // User did copy & paste
                let filteredText = string.numbers
                textField.text = filteredText
                return false
            } else {
                // User did input by keypad
                let allowedCharacters = CharacterSet.decimalDigits
                let characterSet = CharacterSet(charactersIn: string)
                return allowedCharacters.isSuperset(of: characterSet)
            }
        } else {
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = inputToolbar
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let index = fieldsGroup.firstIndex(of: textField) else {
            print("Error: \(textField) not added to searchFieldsGroup!")
            return
        }
        highlightedFieldIndex = index
        
        if textField == areaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.removePlusSignFromAreaCode()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        if textField == areaCodeField {
            let currentText = textField.text ?? ""
            textField.text = currentText.addPlusSignToAreaCode()
        }
    }
}
