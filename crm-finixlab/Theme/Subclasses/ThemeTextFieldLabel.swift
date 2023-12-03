//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

public class ThemeLabel: UILabel {
    let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    var theme: TextLabelTheme?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI(overrideFontSize: CGFloat? = nil) {
        guard let theme = theme else { return }
        
        textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        font = theme.font.toFont(overrideSize: overrideFontSize)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI(overrideFontSize: overrideFontSize)
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

public class ThemeTextFieldLabel: ThemeLabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func pickTheme() {
        theme = themeManager.themeData!.textFieldLabelTheme
    }
    
    override func setupUI(overrideFontSize: CGFloat? = nil) {
        pickTheme()
        super.setupUI(overrideFontSize: overrideFontSize)
    }
}

public class ThemeImportantLabel: ThemeLabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func pickTheme() {
        theme = themeManager.themeData!.importantLabelTheme
    }
    
    override func setupUI(overrideFontSize: CGFloat? = nil) {
        pickTheme()
        super.setupUI(overrideFontSize: overrideFontSize)
    }
}

public class ThemeSmallLabel: ThemeLabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func pickTheme() {
        var mutableTheme = themeManager.themeData!.textFieldLabelTheme
        mutableTheme.font.size = 11
        theme = mutableTheme
    }
    
    override func setupUI(overrideFontSize: CGFloat? = nil) {
        pickTheme()
        super.setupUI(overrideFontSize: overrideFontSize)
    }
}
