//
//  AppoNewStep2ViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-01.
//

import UIKit
import FSCalendar

enum AppoScreenMode {
    case newAppo(Client)
    case editAppo(Appo)
}

class AppoNewOrEditViewController: BaseScrollingViewController {
    var mode: AppoScreenMode!
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var randomButton: ThemeBarButton!
    @IBOutlet weak var quitButton: ThemeBarButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var avatarLabel: ThemeImportantLabel!
    @IBOutlet weak var calendar: ThemeCalendar!
    @IBOutlet weak var fromTimeField: ThemeTextField!
    @IBOutlet weak var fromTimeButton: DropdownButton!
    @IBOutlet weak var timeLabel: ThemeTextFieldLabel!
    @IBOutlet weak var toTimeField: ThemeTextField!
    @IBOutlet weak var toTimeButton: DropdownButton!
    @IBOutlet weak var typeLabel: ThemeTextFieldLabel!
    @IBOutlet weak var typeField: ThemeTextField!
    @IBOutlet weak var typeButton: DropdownButton!
    @IBOutlet weak var reminderLabel: ThemeTextFieldLabel!
    @IBOutlet weak var reminderField: ThemeTextField!
    @IBOutlet weak var reminderButton: DropdownButton!
    @IBOutlet weak var estimateField: ThemeTextField!
    @IBOutlet weak var notesTextView: ThemeGrowingTextView!
    
    @IBOutlet weak var saveButton: ThemeSubmitButton!
    @IBOutlet weak var editButtonsContainer: UIStackView!
    
    private var client: Client!
    private var appo: Appo?
    
    private var day: Date! {
        didSet {
            
        }
    }
    private var fromTime: Date! {
        didSet {
            fromTimeField.text = DateUtil.convert(input: fromTime, outputFormat: .format8)
        }
    }
    
    private var startTime: Date {
        return day.getPastOrFutureDate(minute: fromTime.minute(), hour: fromTime.hour())
    }
    
    private var toTime: Date! {
        didSet {
            toTimeField.text = DateUtil.convert(input: toTime, outputFormat: .format8)
        }
    }
    
    private var endTime: Date {
        return day.getPastOrFutureDate(minute: toTime.minute(), hour: toTime.hour())
    }
    
    private var appoType: AppoType? {
        didSet {
            typeField.text = appoType?.rawValue
        }
    }
    
    private var reminder: ReminderChoices? {
        didSet {
            reminderField.text = reminder?.title()
        }
    }
    
    private let fromTimeDialog = DatePickerDialog()
    private let toTimeDialog = DatePickerDialog()
    private let typeDropdownMenu = DropdownMenu()
    private let reminderDropdownMenu = DropdownMenu()
    private lazy var deleteDialog = Dialog()
    
    override func setup() {
        super.setup()
        
        switch mode {
        case .newAppo:
            title = "Add Appointment"
            editButtonsContainer.isHidden = true
        case .editAppo:
            title = "Edit Appointment"
            saveButton.isHidden = true
        default:
            fatalError()
        }
        
        avatarContainer.roundCorners()
        
        fromTimeDialog.delegate = self
        toTimeDialog.delegate = self
        typeDropdownMenu.delegate = self
        reminderDropdownMenu.delegate = self
        
        requiredFields.append(RequiredField(fieldLabel: timeLabel, field: fromTimeField))
        requiredFields.append(RequiredField(fieldLabel: timeLabel, field: toTimeField))
        requiredFields.append(RequiredField(fieldLabel: typeLabel, field: typeField))
        requiredFields.append(RequiredField(fieldLabel: reminderLabel, field: reminderField))
        
        fieldsGroup.append(estimateField)
        fieldsGroup.append(notesTextView)
        calendar.setupUI()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        avatarLabel.setupUI(overrideFontSize: 13)
        guard let calenderTheme = themeManager.themeData?.appoScreenTheme.calender else { return }
        
        avatarContainer.backgroundColor = UIColor.fromRGBString(rgbString: calenderTheme.backgroundColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.findAndRemoveViewControllerOfClass(kind: AppoNewClientViewController.self)
        
        setupRealm()
        
        switch mode {
        case .newAppo(let client):
            self.client = client
            day = Date().startOfDay().getPastOrFutureDate(day: 1)
            calendar.select(day)
            fromTime = Date().startOfDay().getPastOrFutureDate(hour: 9)
            toTime = fromTime.getPastOrFutureDate(hour: 1)
        case .editAppo(let appo):
            self.appo = appo
            client = teamData.objects(Client.self).filter("_id == %@", appo.clientId).first
            day = appo.startTime.startOfDay()
            calendar.select(day)
            fromTime = appo.startTime
            toTime = appo.endTime
            appoType = AppoType(rawValue: appo.type) ?? .other
            reminder = ReminderChoices(rawValue: appo.reminder) ?? .at15min
            estimateField.text = String(format: "%.2f", appo.estimateAmount ?? 0)
            notesTextView.text = appo.notes
        default:
            fatalError()
        }
        
        guard client != nil else {
            showErrorDialog(error: "This client no longer exist in database.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        avatarLabel.text = avatarLabel.text?.replacingOccurrences(of: "<FULLNAME>", with: client.fullNameWithCivility)
        let config = AvatarImageConfiguration(image: client.avatarImage,
                                              name: client.avatar == nil ? client.initials : nil)
        avatar.config(configuration: config)
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @IBAction func randomPress(_ sender: Any) {
        day = Date().startOfDay().getPastOrFutureDate(days: Int.random(in: -50...50))
        calendar.select(day)
        fromTime = day.getPastOrFutureDate(hour: Int.random(in: 0...18)).startOfHour()
        toTime = fromTime.getPastOrFutureDate(hour: Int.random(in: 1...3)).startOfHour()
        appoType = AppoType.random()
        reminder = ReminderChoices.random()
        estimateField.text = "\(Double.random(in: 0...1000))"
        notesTextView.text = Lorem.paragraph
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @IBAction func fromTimeDropdownPress(_ sender: DropdownButton) {
        sender.isSelected = true
        
        fromTimeDialog.configure(mode: .time,
                                 selected: fromTime,
                                 showDimOverlay: true,
                                 overUIWindow: true)
        fromTimeDialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func toTimeDropdownPress(_ sender: DropdownButton) {
        sender.isSelected = true
        
        toTimeDialog.configure(mode: .time,
                               selected: toTime,
                               showDimOverlay: true,
                               overUIWindow: true)
        toTimeDialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func typeDropdownPress(_ sender: DropdownButton) {
        sender.isSelected = true
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y - stackView.frame.origin.y
        
        typeDropdownMenu.configure(selections: AppoType.listString(),
                                   selected: !(typeField.text?.isEmpty ?? true) ? typeField.text : nil,
                                   targetFrame: targetFrame,
                                   arrowOfset: nil,
                                   showDimOverlay: false,
                                   overUIWindow: true)
        
        typeDropdownMenu.show(inView: view, withDelay: 100)
    }
    
    @IBAction func reminderDropdownPress(_ sender: DropdownButton) {
        sender.isSelected = true
        var targetFrame = sender.globalFrame!
        targetFrame.origin.y = targetFrame.origin.y - stackView.frame.origin.y
        
        reminderDropdownMenu.configure(selections: ReminderChoices.listString(),
                                       selected: !(reminderField.text?.isEmpty ?? true) ? reminderField.text : nil,
                                       targetFrame: targetFrame,
                                       arrowOfset: nil,
                                       showDimOverlay: false,
                                       overUIWindow: true)
        
        reminderDropdownMenu.show(inView: view, withDelay: 100)
    }
    
    @IBAction func savePress(_ sender: ThemeSubmitButton) {
        if validateRequiredFields(), validateAppoTime() {
            let newAppo = Appo(partition: UserManager.shared.teamAndUserPartitionKey,
                               client: client,
                               startTime: startTime,
                               endTime: endTime,
                               type: appoType!,
                               reminder: reminder!,
                               estimateAmount: estimateField.text?.double,
                               notes: notesTextView.text,
                               creator: app.currentUser!.id)
            do {
                try teamUserData.write {
                    teamUserData.add(newAppo)
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
            
            if reminder != .off {
                NotificationManager.shared.scheduleAppoNotification(appo: newAppo, client: client, overridePrevious: false) { success in
                    
                }
            }
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func saveEditPress(_ sender: ThemeSubmitButton) {
        if validateRequiredFields(), validateAppoTime() {
            do {
                try teamUserData.write {
                    appo!.startTime = startTime
                    appo!.endTime = endTime
                    appo!.type = appoType!.rawValue
                    appo!.reminder = reminder!.rawValue
                    appo!.estimateAmount = estimateField.text?.double
                    appo!.notes = notesTextView.text
                    appo!.creator = app.currentUser!.id
                }
            } catch(let error) {
                print("\(error.localizedDescription)")
            }
            if reminder != .off {
                NotificationManager.shared.scheduleAppoNotification(appo: appo!, client: client, overridePrevious: true) { success in
                    
                }
            }
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func deletePress(_ sender: ThemeDeleteButton) {
        let config = DialogConfig(title: "Warning", body: "Are you sure to delete this appointment?", secondary: "Cancel", primary: "Yes")
        deleteDialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        deleteDialog.delegate = self
        deleteDialog.show(inView: view, withDelay: 100)
    }
    
    private func validateAppoTime() -> Bool {
        if endTime <= startTime {
            showErrorDialog(error: "Invalid start and end time")
            return false
        }
        return true
    }
    
    override func buttonSelected(index: Int, dialog: Dialog) {
        super.buttonSelected(index: index, dialog: dialog)
        
        if dialog == deleteDialog, index == 1 {
            NotificationManager.shared.removeAppoNotification(appo: appo!)
            do {
                try teamUserData.write {
                    teamUserData.delete(appo!)
                }
                navigationController?.popToRootViewController(animated: true)
            } catch(let error) {
                print("deleteTagPressed: \(error.localizedDescription)")
            }
        }
    }
}

extension AppoNewOrEditViewController: DropdownMenuDelegate {
    func dropdownSelected(selected: String, menu: DropdownMenu) {
        if menu == typeDropdownMenu {
            appoType = AppoType(rawValue: selected) ?? .other
            typeButton.isSelected = false
        } else if menu == reminderDropdownMenu {
            reminder = ReminderChoices(rawValue: selected) ?? .off
            reminderButton.isSelected = false
        }
    }
    
    func dismissedMenu(menu: DropdownMenu) {
        if menu == typeDropdownMenu {
            typeButton.isSelected = false
        } else if menu == reminderDropdownMenu {
            reminderButton.isSelected = false
        }
    }
}

extension AppoNewOrEditViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        if dialog == fromTimeDialog {
            fromTime = date
            fromTimeButton.isSelected = false
            if endTime < startTime {
                toTime = startTime
            }
        } else if dialog == toTimeDialog {
            toTime = date
            toTimeButton.isSelected = false
            if startTime > endTime {
                fromTime = endTime
            }
        }
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        if dialog == fromTimeDialog {
            fromTimeButton.isSelected = false
        } else if dialog == toTimeDialog {
            toTimeButton.isSelected = false
        }
    }
}

extension AppoNewOrEditViewController: UITextFieldDelegate {
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
    }
}

extension AppoNewOrEditViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = inputToolbar
        guard let index = fieldsGroup.firstIndex(of: textView) else {
            print("Error: \(textView) not added to searchFieldsGroup!")
            return true
        }
        highlightedFieldIndex = index
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        highlightedFieldIndex = nil
    }
}

extension AppoNewOrEditViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        day = date.startOfDay()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
}
