//
//  UIViewController+Extension.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import Foundation
import UIKit
import FMPhotoPicker

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return nil }
        return delegate
    }
    
    var isLightMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .light
    }
}

extension UIViewController {
    static var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
    
    static var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        
        return keyWindow?.topViewController()
    }
    
    func photoPickerConfig() -> FMPhotoPickerConfig {
        let selectMode: FMSelectMode = .single
        
        var mediaTypes = [FMMediaType]()
        mediaTypes.append(.image)
        
        var config = FMPhotoPickerConfig()
        config.selectMode = selectMode
        config.mediaTypes = mediaTypes
        config.maxImage = 1
        config.forceCropEnabled = true
        config.eclipsePreviewEnabled = false
        
        // in force crop mode, only the first crop option is available
        config.availableCrops = [
            FMCrop.ratioSquare
        ]
        
        // all available filters will be used
        config.availableFilters = []
        
        return config
    }
}
