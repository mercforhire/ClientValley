//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import Foundation
import UIKit

public enum Theme: Int, Codable {
    case light = 0
    case dark = 1
}

public struct FontTheme: Codable {
    public var weight: String
    public var size: CGFloat
    public var font: String
    
    var fontName: String {
        return "\(font.capitalizingFirstLetter())-\(weight.capitalizingFirstLetter())"
    }
    
    func toFont(overrideSize: CGFloat? = nil) -> UIFont? {
        return UIFont(name: fontName, size: overrideSize ?? size)
    }
    
    init(dict: [String: Any]) {
        weight = dict["weight"] as! String
        size = dict["size"] as! CGFloat
        font = dict["font"] as! String
    }
}

public struct KeyboardToolBarTheme: Codable {
    public var backgroundColor: String
    public var buttonColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        buttonColor = dict["buttonColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct NavBarTheme: Codable {
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    public var barButton: TextLabelTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
        barButton = TextLabelTheme(dict: dict["BarButton"] as! [String : Any])
    }
}

public struct TabBarTheme: Codable {
    public var selectedColor: String
    public var selectedTextColor: String
    public var unSelectedColor: String
    public var unSelectedTextColor: String
    
    init(dict: [String: Any]) {
        selectedColor = dict["selectedColor"] as! String
        selectedTextColor = dict["selectedTextColor"] as! String
        unSelectedColor = dict["unSelectedColor"] as! String
        unSelectedTextColor = dict["unSelectedTextColor"] as! String
    }
}

public struct TextLabelTheme: Codable {
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct ButtomTheme: Codable {
    public var borderColor: String?
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        borderColor = dict["borderColor"] as? String
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct TextInputTheme: Codable {
    public var borderColor: String?
    public var backgroundColor: String
    public var textColor: String
    public var errorTextColor: String?
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        borderColor = dict["borderColor"] as? String
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        errorTextColor = dict["errorTextColor"] as? String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct SegmentedControlTheme: Codable {
    public var selectedSegmentTextColor: String
    public var selectedSegmentColor: String
    public var unSelectedSegmentTextColor: String
    public var unSelectedSegmentColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        selectedSegmentTextColor = dict["selectedSegmentTextColor"] as! String
        selectedSegmentColor = dict["selectedSegmentColor"] as! String
        unSelectedSegmentTextColor = dict["unSelectedSegmentTextColor"] as! String
        unSelectedSegmentColor = dict["unSelectedSegmentColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct DropdownMenuTheme: Codable {
    public var selectedTextColor: String
    public var selectedSegmentColor: String
    public var unSelectedTextColor: String
    public var backgroundColor: String
    public var arrowColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        selectedTextColor = dict["selectedTextColor"] as! String
        selectedSegmentColor = dict["selectedSegmentColor"] as! String
        unSelectedTextColor = dict["unSelectedTextColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
        arrowColor = dict["arrowColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct CountryPickerTheme: Codable {
    public var title: TextLabelTheme
    public var row: TextLabelTheme
    public var sectionIndex: TextLabelTheme
    
    init(dict: [String: Any]) {
        title = TextLabelTheme(dict: dict["Title"] as! [String : Any])
        row = TextLabelTheme(dict: dict["CountryRow"] as! [String : Any])
        sectionIndex = TextLabelTheme(dict: dict["SectionText"] as! [String : Any])
    }
}

public struct DatePickerTheme: Codable {
    public var row: TextLabelTheme
    public var backgroundColor: String
    
    init(dict: [String: Any]) {
        row = TextLabelTheme(dict: dict["DateRow"] as! [String : Any])
        backgroundColor = dict["backgroundColor"] as! String
    }
}

public struct AvatarTheme: Codable {
    public var small: TextLabelTheme
    public var medium: TextLabelTheme
    public var large: TextLabelTheme
    public var backgroundColor: String
    
    init(dict: [String: Any]) {
        small = TextLabelTheme(dict: dict["Small"] as! [String : Any])
        medium = TextLabelTheme(dict: dict["Medium"] as! [String : Any])
        large = TextLabelTheme(dict: dict["Large"] as! [String : Any])
        backgroundColor = dict["backgroundColor"] as! String
    }
}

public struct HashTheme: Codable {
    public var font: FontTheme
    public var backgroundColor: String
    public var rightButtonColor: String
    public var rightButtonTint: String
    public var textColor: String
    public var borderColor : String
    
    init(dict: [String: Any]) {
        font = FontTheme(dict: dict["font"] as! [String : Any])
        backgroundColor = dict["backgroundColor"] as! String
        rightButtonColor = dict["rightButtonColor"] as! String
        rightButtonTint = dict["rightButtonTint"] as! String
        textColor = dict["textColor"] as! String
        borderColor = dict["borderColor"] as! String
    }
}

public struct CheckboxSectionTheme: Codable {
    public var font: FontTheme
    public var checkedTextColor: String
    public var checkedBackgroundColor: String
    public var checkedCheckboxColor: String
    public var uncheckedTextColor: String
    public var uncheckedBackgroundColor : String
    public var uncheckedCheckboxColor : String
    
    init(dict: [String: Any]) {
        font = FontTheme(dict: dict["font"] as! [String : Any])
        checkedTextColor = dict["checkedTextColor"] as! String
        checkedBackgroundColor = dict["checkedBackgroundColor"] as! String
        checkedCheckboxColor = dict["checkedCheckboxColor"] as! String
        uncheckedTextColor = dict["uncheckedTextColor"] as! String
        uncheckedBackgroundColor = dict["uncheckedBackgroundColor"] as! String
        uncheckedCheckboxColor = dict["uncheckedCheckboxColor"] as! String
    }
}

public struct CustomDialogTheme: Codable {
    public var backgroundColor: String
    public var title: TextLabelTheme
    public var body: TextLabelTheme
    public var secondary: ButtomTheme
    public var primary: ButtomTheme
    
    init(dict: [String: Any]) {
        title = TextLabelTheme(dict: dict["Title"] as! [String : Any])
        body = TextLabelTheme(dict: dict["Body"] as! [String : Any])
        backgroundColor = dict["backgroundColor"] as! String
        secondary = ButtomTheme(dict: dict["Secondary"] as! [String : Any])
        primary = ButtomTheme(dict: dict["Primary"] as! [String : Any])
    }
}

public struct IconTheme: Codable {
    public var borderColor: String?
    public var iconTintColor: String
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        borderColor = dict["borderColor"] as? String
        iconTintColor = dict["iconTintColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct ContactMethodIconTheme: Codable {
    public var available: IconTheme
    public var unavailable: IconTheme
    
    init(dict: [String: Any]) {
        available = IconTheme(dict: dict["Available"] as! [String : Any])
        unavailable = IconTheme(dict: dict["Unavailable"] as! [String : Any])
    }
}

public struct SearchResultTheme: Codable {
    public var backgroundColor: String
    public var iconTintColor: String
    public var resultsLabel: TextLabelTheme
    public var nameLabel: TextLabelTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        iconTintColor = dict["iconTintColor"] as! String
        resultsLabel = TextLabelTheme(dict: dict["ResultsLabel"] as! [String : Any])
        nameLabel = TextLabelTheme(dict: dict["NameLabel"] as! [String : Any])
    }
}

public struct LabelSwitchCellTheme: Codable {
    public var switchTintColor: String
    public var label: TextLabelTheme
    
    init(dict: [String: Any]) {
        switchTintColor = dict["switchTintColor"] as! String
        label = TextLabelTheme(dict: dict["Label"] as! [String : Any])
    }
}

public struct SearchBarTheme: Codable {
    public var borderColor: String?
    public var iconTintColor: String
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        borderColor = dict["borderColor"] as? String
        iconTintColor = dict["iconTintColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct SectionHeaderTheme: Codable {
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct FollowUpTableTheme: Codable {
    public var sectionHeader: SectionHeaderTheme
    
    init(dict: [String: Any]) {
        sectionHeader = SectionHeaderTheme(dict: dict["SectionHeader"] as! [String : Any])
    }
}

public struct MailRecipientCellTheme: Codable {
    public var backgroundColor: String
    public var textColor: String
    public var buttonBackgroundColor: String
    public var buttonTintColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        buttonBackgroundColor = dict["buttonBackgroundColor"] as! String
        buttonTintColor = dict["buttonTintColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct TemplateCellTheme: Codable {
    public var textColor: String
    public var buttonTintColor: String
    public var iconTintColor: String
    public var iconBackgroundColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        buttonTintColor = dict["buttonTintColor"] as! String
        iconTintColor = dict["iconTintColor"] as! String
        iconBackgroundColor = dict["iconBackgroundColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct AccountCellTheme: Codable {
    public var textColor: String
    public var iconTintColor: String
    public var iconBackgroundColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        iconTintColor = dict["iconTintColor"] as! String
        iconBackgroundColor = dict["iconBackgroundColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct AppListCellTheme: Codable {
    public var textColor: String
    public var backgroundColor: String
    public var timeLabelFont: FontTheme
    public var nameLabelFont: FontTheme
    public var appoNameLabelFont: FontTheme
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
        timeLabelFont = FontTheme(dict: dict["timeLabelFont"] as! [String : Any])
        nameLabelFont = FontTheme(dict: dict["nameLabelFont"] as! [String : Any])
        appoNameLabelFont = FontTheme(dict: dict["appoNameLabelFont"] as! [String : Any])
    }
}

public struct CalenderTheme: Codable {
    public var backgroundColor: String
    public var monthLabelFont: FontTheme
    public var monthLabelTextColor: String
    public var weekdayLabelFont: FontTheme
    public var weekdayLabelTextColor: String
    public var dayLabelFont: FontTheme
    public var dayLabelSelectedTextColor: String
    public var dayLabelSelectedTintColor: String
    public var dayLabelUnselectedTextColor: String
    public var dayLabelPreviousMonthTextColor: String
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        monthLabelFont = FontTheme(dict: dict["monthLabelFont"] as! [String : Any])
        monthLabelTextColor = dict["monthLabelTextColor"] as! String
        weekdayLabelFont = FontTheme(dict: dict["weekdayLabelFont"] as! [String : Any])
        weekdayLabelTextColor = dict["weekdayLabelTextColor"] as! String
        dayLabelFont = FontTheme(dict: dict["dayLabelFont"] as! [String : Any])
        dayLabelSelectedTextColor = dict["dayLabelSelectedTextColor"] as! String
        dayLabelSelectedTintColor = dict["dayLabelSelectedTintColor"] as! String
        dayLabelUnselectedTextColor = dict["dayLabelUnselectedTextColor"] as! String
        dayLabelPreviousMonthTextColor = dict["dayLabelPreviousMonthTextColor"] as! String
    }
}

public struct AppoScreenTheme: Codable {
    public var appListCellTheme: AppListCellTheme
    public var section: TextLabelTheme
    public var calender: CalenderTheme
    
    init(dict: [String: Any]) {
        appListCellTheme = AppListCellTheme(dict: dict["AppListCell"] as! [String : Any])
        section = TextLabelTheme(dict: dict["Section"] as! [String : Any])
        calender = CalenderTheme(dict: dict["Calender"] as! [String : Any])
    }
}

public struct AppoDetailsScreen: Codable {
    public var profileContainerBorderColor: String
    public var profileLabelsTextColor: String
    public var profileButtonColor: String
    public var infoIconColor: String
    
    init(dict: [String: Any]) {
        profileContainerBorderColor = dict["profileContainerBorderColor"] as! String
        profileLabelsTextColor = dict["profileLabelsTextColor"] as! String
        profileButtonColor = dict["profileButtonColor"] as! String
        infoIconColor = dict["infoIconColor"] as! String
    }
}

public struct TeamActionSheetTheme: Codable {
    public var font: FontTheme
    public var dragBarColor: String
    public var backgroundColor: String
    public var selectedColor: String
    public var unselectedColor: String
    public var unselectedIconTintColor: String
    public var selectedIconTintColor: String
    public var dividerColor: String
    
    init(dict: [String: Any]) {
        font = FontTheme(dict: dict["font"] as! [String : Any])
        dragBarColor = dict["dragBarColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
        selectedColor = dict["selectedColor"] as! String
        unselectedColor = dict["unselectedColor"] as! String
        unselectedIconTintColor = dict["unselectedIconTintColor"] as! String
        selectedIconTintColor = dict["selectedIconTintColor"] as! String
        dividerColor = dict["dividerColor"] as! String
    }
}

public struct ToastTheme: Codable {
    public var font: FontTheme
    public var textColor: String
    public var backgroundColor: String
    
    init(dict: [String: Any]) {
        font = FontTheme(dict: dict["font"] as! [String : Any])
        textColor = dict["textColor"] as! String
        backgroundColor = dict["backgroundColor"] as! String
    }
}

public struct MemberScreenTheme: Codable {
    public var memberNameFont: FontTheme
    public var roleFont: FontTheme
    public var titleFont: FontTheme
    public var subtitleFont: FontTheme
    public var cardBackgroundColor: String
    public var foregroundColor: String
    
    init(dict: [String: Any]) {
        memberNameFont = FontTheme(dict: dict["memberNameFont"] as! [String : Any])
        roleFont = FontTheme(dict: dict["roleFont"] as! [String : Any])
        titleFont = FontTheme(dict: dict["titleFont"] as! [String : Any])
        subtitleFont = FontTheme(dict: dict["subtitleFont"] as! [String : Any])
        cardBackgroundColor = dict["cardBackgroundColor"] as! String
        foregroundColor = dict["foregroundColor"] as! String
    }
}

public struct AccountScreenTheme: Codable {
    public var teamButtonBackgroundColor: String
    public var teamButtonForegroundColor: String
    public var sectionHeaderColor: String
    public var disabledItemColor: String
    
    init(dict: [String: Any]) {
        teamButtonBackgroundColor = dict["teamButtonBackgroundColor"] as! String
        teamButtonForegroundColor = dict["teamButtonForegroundColor"] as! String
        sectionHeaderColor = dict["sectionHeaderColor"] as! String
        disabledItemColor = dict["disabledItemColor"] as! String
    }
}

public struct InsightsScreenTheme: Codable {
    public var buttonBackgroundColor: String
    public var buttonForegroundColor: String
    public var appoDotColor: String
    public var followUpDotColor: String
    public var clientDotColor: String
    public var teamCellBackgroundColor: String
    public var teamCellForegroundColor: String
    public var emailDotColor: String
    public var phoneDotColor: String
    public var messageDotColor: String
    public var mailDotColor: String
    
    init(dict: [String: Any]) {
        buttonBackgroundColor = dict["buttonBackgroundColor"] as! String
        buttonForegroundColor = dict["buttonForegroundColor"] as! String
        appoDotColor = dict["appoDotColor"] as! String
        followUpDotColor = dict["followUpDotColor"] as! String
        clientDotColor = dict["clientDotColor"] as! String
        teamCellBackgroundColor = dict["teamCellBackgroundColor"] as! String
        teamCellForegroundColor = dict["teamCellForegroundColor"] as! String
        emailDotColor = dict["emailDotColor"] as! String
        phoneDotColor = dict["phoneDotColor"] as! String
        messageDotColor = dict["messageDotColor"] as! String
        mailDotColor = dict["mailDotColor"] as! String
    }
}

public struct PerformanceScreenTheme: Codable {
    public var bigCircleBorderColor: String
    public var bigCircleBackgroundColor: String
    public var bigCyanTextColor: String
    public var blueTextColor: String
    public var blackTextColor: String
    public var cyanViewBackgroundColor: String
    public var dividerColor: String
    
    init(dict: [String: Any]) {
        bigCircleBorderColor = dict["bigCircleBorderColor"] as! String
        bigCircleBackgroundColor = dict["bigCircleBackgroundColor"] as! String
        bigCyanTextColor = dict["bigCyanTextColor"] as! String
        blueTextColor = dict["blueTextColor"] as! String
        blackTextColor = dict["blackTextColor"] as! String
        cyanViewBackgroundColor = dict["cyanViewBackgroundColor"] as! String
        dividerColor = dict["dividerColor"] as! String
    }
}

public struct PerformanceTables: Codable {
    public var primaryLabelColor: String
    public var secondaryLabelColor: String
    
    init(dict: [String: Any]) {
        primaryLabelColor = dict["primaryLabelColor"] as! String
        secondaryLabelColor = dict["secondaryLabelColor"] as! String
    }
}

public struct TutorialTheme: Codable {
    public var textColor: String
    public var bubbleBackgroundColor: String
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        bubbleBackgroundColor = dict["bubbleBackgroundColor"] as! String
    }
}

public struct ThemeData: Codable {
    public var viewColor: String
    public var keyboardToolBarTheme: KeyboardToolBarTheme
    public var navBarTheme: NavBarTheme
    public var tabBarTheme: TabBarTheme
    public var textFieldLabelTheme: TextLabelTheme
    public var importantLabelTheme: TextLabelTheme
    public var primaryButtonTheme: ButtomTheme
    public var secondaryButtonTheme: ButtomTheme
    public var deleteButtonTheme: ButtomTheme
    public var labelButtonTheme: TextLabelTheme
    public var textViewTheme: TextInputTheme
    public var textFieldTheme: TextInputTheme
    public var segmentedControlTheme: SegmentedControlTheme
    public var dropdownMenuTheme: DropdownMenuTheme
    public var countryPickerTheme: CountryPickerTheme
    public var datePickerTheme: DatePickerTheme
    public var avatarTheme: AvatarTheme
    public var hashTheme: HashTheme
    public var checkboxSectionTheme: CheckboxSectionTheme
    public var customDialogTheme: CustomDialogTheme
    public var contactMethodIconTheme: ContactMethodIconTheme
    public var searchResultTheme: SearchResultTheme
    public var labelSwitchCellTheme: LabelSwitchCellTheme
    public var searchBarTheme: SearchBarTheme
    public var followUpTableTheme: FollowUpTableTheme
    public var emailNameTag: ButtomTheme
    public var mailRecipientCellTheme: MailRecipientCellTheme
    public var templateCellTheme: TemplateCellTheme
    public var accountCellTheme: AccountCellTheme
    public var appoScreenTheme: AppoScreenTheme
    public var appoDetailsScreen: AppoDetailsScreen
    public var teamActionSheetTheme: TeamActionSheetTheme
    public var toastTheme: ToastTheme
    public var accountScreen: AccountScreenTheme
    public var memberScreen: MemberScreenTheme
    public var insightsScreen: InsightsScreenTheme
    public var performanceScreen: PerformanceScreenTheme
    public var performanceTables: PerformanceTables
    public var tutorialTheme: TutorialTheme
    
    public init(dict: [String: Any]) {
        viewColor = dict["viewColor"] as! String
        keyboardToolBarTheme = KeyboardToolBarTheme(dict: dict["KeyboardToolbar"] as! [String : Any])
        navBarTheme = NavBarTheme(dict: dict["NavBar"] as! [String : Any])
        tabBarTheme = TabBarTheme(dict: dict["TabBar"] as! [String : Any])
        textFieldLabelTheme = TextLabelTheme(dict: dict["TextFieldLabel"] as! [String : Any])
        importantLabelTheme = TextLabelTheme(dict: dict["ImportantLabel"] as! [String : Any])
        primaryButtonTheme = ButtomTheme(dict: dict["PrimaryButton"] as! [String : Any])
        secondaryButtonTheme = ButtomTheme(dict: dict["SecondaryButton"] as! [String : Any])
        deleteButtonTheme = ButtomTheme(dict: dict["DeleteButton"] as! [String : Any])
        labelButtonTheme = TextLabelTheme(dict: dict["LabelButton"] as! [String : Any])
        textViewTheme = TextInputTheme(dict: dict["TextView"] as! [String : Any])
        textFieldTheme = TextInputTheme(dict: dict["TextField"] as! [String : Any])
        segmentedControlTheme = SegmentedControlTheme(dict: dict["SegmentedControl"] as! [String : Any])
        dropdownMenuTheme = DropdownMenuTheme(dict: dict["DropdownMenu"] as! [String : Any])
        countryPickerTheme = CountryPickerTheme(dict: dict["CountryPicker"] as! [String : Any])
        datePickerTheme = DatePickerTheme(dict: dict["DatePicker"] as! [String : Any])
        avatarTheme = AvatarTheme(dict: dict["Avatar"] as! [String : Any])
        hashTheme = HashTheme(dict: dict["Hashtag"] as! [String : Any])
        checkboxSectionTheme = CheckboxSectionTheme(dict: dict["CheckboxSection"] as! [String : Any])
        customDialogTheme = CustomDialogTheme(dict: dict["CustomDialog"] as! [String : Any])
        contactMethodIconTheme = ContactMethodIconTheme(dict: dict["ContactMethodIcon"] as! [String : Any])
        searchResultTheme = SearchResultTheme(dict: dict["SearchResult"] as! [String : Any])
        labelSwitchCellTheme = LabelSwitchCellTheme(dict: dict["LabelSwitchCell"] as! [String : Any])
        searchBarTheme = SearchBarTheme(dict: dict["SearchBar"] as! [String : Any])
        followUpTableTheme = FollowUpTableTheme(dict: dict["FollowUpTable"] as! [String : Any])
        emailNameTag = ButtomTheme(dict: dict["EmailNameTag"] as! [String : Any])
        mailRecipientCellTheme = MailRecipientCellTheme(dict: dict["MailRecipientCell"] as! [String : Any])
        templateCellTheme = TemplateCellTheme(dict: dict["TemplateCell"] as! [String : Any])
        accountCellTheme = AccountCellTheme(dict: dict["AccountCell"] as! [String : Any])
        appoScreenTheme = AppoScreenTheme(dict: dict["AppoScreen"] as! [String : Any])
        appoDetailsScreen = AppoDetailsScreen(dict: dict["AppoDetailsScreen"] as! [String : Any])
        teamActionSheetTheme = TeamActionSheetTheme(dict: dict["TeamActionSheet"] as! [String : Any])
        toastTheme = ToastTheme(dict: dict["Toast"] as! [String : Any])
        accountScreen = AccountScreenTheme(dict: dict["AccountScreen"] as! [String : Any])
        memberScreen = MemberScreenTheme(dict: dict["MemberScreen"] as! [String : Any])
        insightsScreen = InsightsScreenTheme(dict: dict["InsightsScreen"] as! [String : Any])
        performanceScreen = PerformanceScreenTheme(dict: dict["PerformanceScreen"] as! [String : Any])
        performanceTables = PerformanceTables(dict: dict["PerformanceTables"] as! [String : Any])
        tutorialTheme = TutorialTheme(dict: dict["Tutorial"] as! [String : Any])
    }
}
