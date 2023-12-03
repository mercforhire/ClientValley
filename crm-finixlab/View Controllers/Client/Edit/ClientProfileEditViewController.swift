//
//  ClientProfileEditViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-14.
//

import UIKit
import GrowingTextView
import FMPhotoPicker
import Cosmos
import RealmSwift
import SKCountryPicker
import GooglePlaces

class ClientProfileEditViewController: BaseScrollingViewController {
    var client: Client!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var civilityContainer: UIView!
    @IBOutlet weak var civilityField: ThemeTextField!
    @IBOutlet weak var civilityDropButton: DropdownButton!
    @IBOutlet weak var lastnameField: ThemeTextField!
    @IBOutlet weak var firstnameField: ThemeTextField!
    @IBOutlet weak var countryContainer: UIView!
    @IBOutlet weak var countryField: ThemeTextField!
    @IBOutlet weak var countryDropButton: DropdownButton!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    @IBOutlet weak var birthdayField: ThemeTextField!
    @IBOutlet weak var birthdayDropdownButton: DropdownButton!
    @IBOutlet weak var addressField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var zipCodeField: ThemeTextField!
    @IBOutlet weak var notesTextView: GrowingTextView!
    @IBOutlet weak var hashtagCollectionView: UICollectionView!
    @IBOutlet weak var heightBar: NSLayoutConstraint!
    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var totalSpending: ThemeTextField!
    @IBOutlet weak var mailSectionContainer: UIView!
    private let mailSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var photoSectionContainer: UIView!
    private let phoneSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var emailSectionContainer: UIView!
    private let emailSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    @IBOutlet weak var messagesSectionContainer: UIView!
    private let messagesSection = CheckboxSectionView.fromNib()! as! CheckboxSectionView
    
    private lazy var myCamera = UIImagePickerController()
    
    private var userSettings: UserSettings!
    private var notificationToken: NotificationToken?
    private var notificationToken2: NotificationToken?
    private var notificationToken3: NotificationToken?
    
    private var street_number: String = ""
    private var route: String = ""
    private var neighborhood: String = ""
    private var locality: String = ""
    private var administrative_area_level_1: String = ""
    private var country: String = ""
    private var postal_code: String = ""
    private var postal_code_suffix: String = ""
    
    private var image: UIImage? {
        didSet {
            if image == nil {
                let config = AvatarImageConfiguration(image: nil, name: client.initials)
                avatar.config(configuration: config)
                
                do {
                    try teamData.write {
                        client.avatar = nil
                    }
                } catch(let error) {
                    print("image changed: \(error.localizedDescription)")
                }
            } else {
                let config = AvatarImageConfiguration(image: image, name: client.initials)
                avatar.config(configuration: config)
                
                do {
                    try teamData.write {
                        client.avatar = image!.pngData()
                    }
                } catch(let error) {
                    print("image changed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        areaCodeField.setupUI(insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
        
        fieldsGroup.append(civilityField)
        fieldsGroup.append(lastnameField)
        fieldsGroup.append(firstnameField)
        fieldsGroup.append(countryField)
        fieldsGroup.append(emailField)
        fieldsGroup.append(areaCodeField)
        fieldsGroup.append(phoneField)
        fieldsGroup.append(birthdayField)
        fieldsGroup.append(addressField)
        fieldsGroup.append(cityField)
        fieldsGroup.append(provinceField)
        fieldsGroup.append(zipCodeField)
        fieldsGroup.append(notesTextView)
        fieldsGroup.append(totalSpending)
        
        notesTextView.text = ""
        hashtagCollectionView.register(UINib(nibName: "HashTagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HashTagCell")
        hashtagCollectionView.register(UINib(nibName: "AddTagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AddTagCell")
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 0.0, bottom: 0, right: 0.0)
        bubbleLayout.delegate = self
        hashtagCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        mailSectionContainer.fill(with: mailSection)
        photoSectionContainer.fill(with: phoneSection)
        emailSectionContainer.fill(with: emailSection)
        messagesSectionContainer.fill(with: messagesSection)
        
        mailSection.label.text = "Mail"
        phoneSection.label.text = "Phone"
        emailSection.label.text = "Email"
        messagesSection.label.text = "Mobile Messaging"
        
        mailSection.button.addTarget(self, action: #selector(mailSectionPress), for: .touchUpInside)
        phoneSection.button.addTarget(self, action: #selector(phoneSectionPress), for: .touchUpInside)
        emailSection.button.addTarget(self, action: #selector(emailSectionPress), for: .touchUpInside)
        messagesSection.button.addTarget(self, action: #selector(messageSectionPress), for: .touchUpInside)

        ratingView.didFinishTouchingCosmos = { [weak self] rating in
            guard let self = self else { return }
            
            do {
                try self.teamData.write {
                    self.client?.metadata?.rating = Float(rating)
                }
            } catch(let error) {
                print("image changed: \(error.localizedDescription)")
            }
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        hashtagCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
        notificationToken2?.invalidate()
        notificationToken3?.invalidate()
    }
    
    @IBAction func civilityDropdownButtonPress(_ sender: UIButton) {
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y
        let dropdownMenu = DropdownMenu()
        dropdownMenu.configure(selections: CivilityStatus.listString(), selected: client.statusEnum?.title(), targetFrame: targetFrame, arrowOfset: nil, showDimOverlay: false, overUIWindow: true)
        dropdownMenu.delegate = self
        dropdownMenu.show(inView: view, withDelay: 100)
        sender.isSelected = true
    }
    
    @IBAction func countryDropdownButtonPress(_ sender: DropdownButton) {
        sender.isSelected = true
        let vc = CountryPickerViewController.create(selected: client.address?.countryCode, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func birthdayDropdownPress(_ sender: UIButton) {
        sender.isSelected = true
        let datePickerDialog = DatePickerDialog()
        datePickerDialog.configure(selected: client.birthday ?? Date().getPastOrFutureDate(year: -18),
                                   showDimOverlay: true,
                                   overUIWindow: true)
        datePickerDialog.delegate = self
        datePickerDialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        addressFilter.country = client.address?.countryCode ?? CountryManager.shared.country(withName: countryField.text ?? "")?.countryCode
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPress(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
    
    @objc private func deleteTagPressed(_ sender: UIButton) {
        do {
            try teamData.write {
                client.metadata?.hashtags.remove(at: sender.tag)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc private func addTagPressed(_ sender: UIButton) {
        let vc = HashtagAddViewController.create(historyTags: userSettings?.historyHashtags.sorted() ?? [], delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func mailSectionPress() {
        do {
            try teamData.write {
                client.contactMethod?.byMail = !(client.contactMethod?.byMail ?? true)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func phoneSectionPress() {
        do {
            try teamData.write {
                client.contactMethod?.byPhone = !(client.contactMethod?.byPhone ?? true)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func emailSectionPress() {
        do {
            try teamData.write {
                client.contactMethod?.byEmail = !(client.contactMethod?.byEmail ?? true)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc func messageSectionPress() {
        do {
            try teamData.write {
                client.contactMethod?.byMessage = !(client.contactMethod?.byMessage ?? true)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func totalExpenseInfoPressed(_ sender: UIButton) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Base expense", body: "This expense is used as a base value plus each appointment expense to calcuate the total expense in Performance screen.", secondary: nil, primary: "Got it")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func deleteButtonPress(_ sender: ThemeDeleteButton) {
        let dialog = Dialog()
        let config = DialogConfig(title: "Warning", body: "Are you sure to delete this client's information?", secondary: "Cancel", primary: "Yes")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func donePress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func refreshView() {
        let config = AvatarImageConfiguration(image: client.avatarImage, name: client.initials)
        avatar.config(configuration: config)
        civilityField.text = client.statusEnum?.title()
        lastnameField.text = client.lastName
        firstnameField.text = client.firstName
        countryField.text = client.address?.country
        emailField.text = client.email
        areaCodeField.text = client.phone?.area.addPlusSignToAreaCode()
        phoneField.text = client.phone?.phone
        birthdayField.text = client.birthdayString
        addressField.text = client.address?.address
        cityField.text = client.address?.city
        provinceField.text = client.address?.province
        zipCodeField.text = client.address?.zipCode
        
        notesTextView.text = client.metadata?.notes
        if client.metadata?.notes == nil {
            notesTextView.superview?.isHidden = true
        } else {
            notesTextView.superview?.isHidden = false
        }
    
        totalSpending.text = "\(client.metadata?.totalSpending ?? 0.0)"
        if client.metadata?.totalSpending == nil {
            totalSpending.superview?.isHidden = true
        } else {
            totalSpending.superview?.isHidden = false
        }
        
        hashtagCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            let height: CGFloat = self.hashtagCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.heightBar.constant = height
        }
        
        mailSection.configureUI(selected: client.contactMethod?.byMail ?? false)
        phoneSection.configureUI(selected: client.contactMethod?.byPhone ?? false)
        emailSection.configureUI(selected: client.contactMethod?.byEmail ?? false)
        messagesSection.configureUI(selected: client.contactMethod?.byMessage ?? false)
        
        ratingView.rating = Double(client.metadata?.rating ?? 0.0)
    }
    
    override func setupRealm() {
        super.setupRealm()

        if realm.objects(UserSettings.self).isEmpty {
            userSettings = UserSettings(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(userSettings)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            userSettings = realm.objects(UserSettings.self).first
        }
        
        notificationToken = client.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.refreshView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
        
        notificationToken2 = client.contactMethod?.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.refreshView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
        
        notificationToken3 = client.metadata?.observe({ [weak self] changes in
            switch changes {
            case .change:
                self?.refreshView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        if index == 1 {
            NotificationManager.shared.removeNotificationsFor(client: client, realm: teamUserData)
            do {
                try realm.write {
                    userSettings.starredClients.remove(client._id)
                }
            } catch(let error) {
                print("realm: \(error.localizedDescription)")
            }
            
            do {
                try teamData.write {
                    teamData.delete(client)
                }
                navigationController?.popToRootViewController(animated: true)
            } catch(let error) {
                print("dataSource: \(error.localizedDescription)")
            }
        }
    }
    
    private func fillAddressForm() {
        addressField.text = street_number + " " + route
        cityField.text = locality
        provinceField.text = administrative_area_level_1
        if postal_code_suffix != "" {
            zipCodeField.text = postal_code + "-" + postal_code_suffix
        } else {
            zipCodeField.text = postal_code
        }
        
        do {
            try teamData.write {
                client.address?.address = street_number + " " + route
                client.address?.city = locality
                client.address?.province = administrative_area_level_1
                client.address?.zipCode = zipCodeField.text ?? ""
            }
        } catch(let error) {
            print("write error: \(error.localizedDescription)")
        }
        
        // Clear values for next time.
        street_number = ""
        route = ""
        neighborhood = ""
        locality = ""
        administrative_area_level_1  = ""
        country = ""
        postal_code = ""
        postal_code_suffix = ""
    }
}

extension ClientProfileEditViewController: HashtagAddViewControllerDelegate {
    func addedTag(newTag: String) {
        guard let metadata = client.metadata else { return }
        
        if metadata.hashtags.filter({ subject in
            return subject == newTag
        }).isEmpty {
            do {
                try teamData.write {
                    client.metadata?.hashtags.append(newTag)
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        
        // add to history
        guard let userSettings = userSettings else { return }
        
        if userSettings.historyHashtags.filter({ subject in
            return subject == newTag
        }).isEmpty {
            do {
                try realm.write {
                    userSettings.historyHashtags.append(newTag)
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
    }
}

extension ClientProfileEditViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        civilityField.text = selected
        civilityDropButton.isSelected = false
        
        do {
            try teamData.write {
                client.civility = selected
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        civilityDropButton.isSelected = false
    }
}

extension ClientProfileEditViewController: CountryPickerViewControllerDelegate {
    func selected(selected: Country) {
        countryField.text = selected.englishName
        countryDropButton.isSelected = false
        
        do {
            try teamData.write {
                client.address?.country = selected.englishName
                client.address?.countryCode = selected.countryCode
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
    
    func dismissed() {
        countryDropButton.isSelected = false
    }
}

extension ClientProfileEditViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        do {
            try teamData.write {
                client?.birthday = date.startOfDay()
            }
        } catch(let error) {
            print("image changed: \(error.localizedDescription)")
        }
        birthdayDropdownButton.isSelected = false
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        birthdayDropdownButton.isSelected = false
    }
}

extension ClientProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else { return }
            
            self?.image = image.resizeImage(100, opaque: true)
        }
    }
}

extension ClientProfileEditViewController: FMPhotoPickerViewControllerDelegate {
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

extension ClientProfileEditViewController: UITextFieldDelegate {
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
            let updatedText = currentText.replacingOccurrences(of: "+ ", with: "")
            textField.text = updatedText
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        if textField == lastnameField {
            do {
                try teamData.write {
                    client.lastName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == firstnameField {
            do {
                try teamData.write {
                    client.firstName = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == emailField {
            do {
                try teamData.write {
                    client.email = textField.text
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == phoneField {
            do {
                try teamData.write {
                    client.phone?.phone = textField.text?.digits ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == addressField {
            do {
                try teamData.write {
                    client.address?.address = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == cityField {
            do {
                try teamData.write {
                    client.address?.city = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == provinceField {
            do {
                try teamData.write {
                    client.address?.province = textField.text ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == zipCodeField {
            do {
                try teamData.write {
                    client.address?.zipCode = textField.text
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == areaCodeField {
            let currentText = textField.text ?? ""
            let updatedText = "+ \(currentText)"
            textField.text = updatedText
            
            do {
                try teamData.write {
                    client.phone?.area = textField.text?.removePlusSignFromAreaCode() ?? ""
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        else if textField == totalSpending {
            do {
                try teamData.write {
                    client.metadata?.totalSpending = textField.text?.double
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
    }
}

extension ClientProfileEditViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        guard let index = fieldsGroup.firstIndex(of: textView) else {
            print("Error: \(textView) not added to searchFieldsGroup!")
            return true
        }
        highlightedFieldIndex = index
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        highlightedFieldIndex = nil
        
        do {
            try teamData.write {
                client.metadata?.notes = textView.text
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
}

extension ClientProfileEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (client.metadata?.hashtags.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < (client.metadata?.hashtags.count ?? 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCell", for: indexPath) as! HashTagCell
            let tag = client.metadata?.hashtags[indexPath.row] ?? "tag"
            cell.lblTitle.text = "#\(tag)"
            cell.rightArrow.tag = indexPath.row
            cell.rightArrow.addTarget(self, action: #selector(deleteTagPressed(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTagCell", for: indexPath) as! AddTagCell
            cell.labelButton.addTarget(self, action: #selector(addTagPressed(_:)), for: .touchUpInside)
            cell.rightArrow.addTarget(self, action: #selector(addTagPressed(_:)), for: .touchUpInside)
            return cell
        }
    }
}

extension ClientProfileEditViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < client.metadata?.hashtags.count ?? 0 {
            guard let themeData = themeManager.themeData?.hashTheme,
                  let tag = client.metadata?.hashtags[indexPath.row] else { return .zero }
            
            let title = "#\(tag)"
            var size = title.size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont()!])
            size.width = CGFloat(ceilf(Float(12.0 + size.width + 39.0)))
            size.height = 30
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
        } else {
            guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return .zero }
            
            var size = "Add".size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont()!])
            size.width = CGFloat(ceilf(Float(12.0 + size.width + 36.0)))
            size.height = 30
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
        }
    }
}

extension ClientProfileEditViewController: GMSAutocompleteViewControllerDelegate {

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console
        print("Place name: \(place.name ?? "")")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(String(describing: place.attributions))")
        
        // Get the address components.
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                for type in field.types {
                    switch type {
                    case kGMSPlaceTypeStreetNumber:
                        street_number = field.name
                    case kGMSPlaceTypeRoute:
                        route = field.name
                    case kGMSPlaceTypeNeighborhood:
                        neighborhood = field.name
                    case kGMSPlaceTypeLocality:
                        locality = field.name
                    case kGMSPlaceTypeAdministrativeAreaLevel1:
                        administrative_area_level_1 = field.name
                    case kGMSPlaceTypeCountry:
                        country = field.name
                    case kGMSPlaceTypePostalCode:
                        postal_code = field.name
                    case kGMSPlaceTypePostalCodeSuffix:
                        postal_code_suffix = field.name
                    // Print the items we aren't using.
                    default:
                        print("Type: \(type), Name: \(field.name)")
                    }
                }
            }
        }
        
        // Call custom function to populate the address form.
        fillAddressForm()
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
    }
    
}
