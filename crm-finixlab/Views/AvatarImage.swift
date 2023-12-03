//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

class AvatarImage: UIView {
    private let themeManager = ThemeManager.shared
    private var observer: NSObjectProtocol?
    
    enum SizeMode {
        case large
        case medium
        case small
        
        func font() -> UIFont {
            switch self {
            case .large:
                return ThemeManager.shared.themeData!.avatarTheme.large.font.toFont()!
            case .medium:
                return ThemeManager.shared.themeData!.avatarTheme.medium.font.toFont()!
            case .small:
                return ThemeManager.shared.themeData!.avatarTheme.small.font.toFont()!
            }
        }
    }
    
    private let letterContainer = UIView()
    private let letterLabel = UILabel()
    
    private var image: UIImage?
    private var name: String?
    
    private let imageView = UIImageView()
    
    var sizeMode: SizeMode = .small {
        didSet {
            switch sizeMode {
            case .large:
                letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.large.textColor)
            case .medium:
                letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.medium.textColor)
            case .small:
                letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.small.textColor)
            }
            letterLabel.font = sizeMode.font()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        setupLetterContainer()
        setupImage()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        backgroundColor = .clear
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.commonInit()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func reset() {
        image = nil
        name = nil
        imageView.image = nil
        letterLabel.text = nil
        letterContainer.backgroundColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.avatarTheme.backgroundColor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
    }
    
    private func setName(name: String) {
        letterContainer.isHidden = false
        letterLabel.text = name
        imageView.isHidden = true
    }
    
    private func setImage(image: UIImage) {
        letterContainer.isHidden = true
        imageView.isHidden = false
        
        UIView.transition(
            with: imageView,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.imageView.image = image
            },
            completion: nil)
        setupShadows()
    }
    
    func config(configuration: AvatarImageConfiguration) {
        self.image = configuration.image
        self.name = configuration.name
        
        if let image = self.image {
            setImage(image: image)
        } else if let name = self.name {
            setName(name: name)
        }
    }
    
    func hasImage() -> Bool {
        return imageView.image != nil
    }
    
    func clearImage() {
        image = nil
        setupShadows()
        
        UIView.transition(
            with: imageView,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.imageView.image = nil
            },
            completion: nil)
        if let name = self.name {
            setName(name: name)
        }
    }
    
    func updateImage(with newImage: UIImage) {
        self.image = newImage
        setImage(image: newImage)
    }
}

extension AvatarImage {
    private func setupLetterContainer() {
        fill(with: letterContainer)
        
        letterContainer.backgroundColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.avatarTheme.backgroundColor)
        letterContainer.fill(with: letterLabel)
        letterContainer.layer.cornerRadius = frame.size.width / 2
        letterContainer.layer.masksToBounds = true
        
        switch sizeMode {
        case .large:
            letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.large.textColor)
        case .medium:
            letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.medium.textColor)
        case .small:
            letterLabel.textColor = UIColor.fromRGBString(rgbString: ThemeManager.shared.themeData!.avatarTheme.small.textColor)
        }
        letterLabel.font = sizeMode.font()
        letterLabel.textAlignment = .center
        letterLabel.backgroundColor = .clear
    }
    
    private func setupImage() {
        fill(with: imageView)
    }
    
    private func setupShadows() {
        let cornerRadius = frame.height / 2
        if image != nil {
            clipsToBounds = false
            layer.shadowColor = UIColor.gray.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 4
            layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath

            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = cornerRadius
        } else {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
}

struct AvatarImageConfiguration {
    var image: UIImage?
    var name: String?
    
    init(image: UIImage?, name: String?) {
        self.image = image
        self.name = name
    }
}
