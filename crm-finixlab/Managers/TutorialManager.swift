//
//  TutorialManager.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-12-07.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

enum TutorialName: String {
    case clientSearch = "clientSearch"
    case clientNew = "clientNew"
    case followUpMain = "followUpMain"
    case appoMain = "appoMain"
    case perfMain = "perfMain"
    case accountMain = "accountMain"
}

struct TutorialStep {
    var screenName: String
    var body: String
    var pointingDirection: TutorialView.PointingDirection
    var pointPosition: TutorialView.PointingPosition
    var targetFrame: CGRect?
    var arrowOffset: CGFloat?
    var showDimOverlay: Bool
    var overUIWindow: Bool
    
    init(screenName: String,
         body: String,
         pointingDirection: TutorialView.PointingDirection = .up,
         pointPosition: TutorialView.PointingPosition = .edge,
         targetFrame: CGRect?,
         arrowOfset: CGFloat? = nil,
         showDimOverlay: Bool = true,
         overUIWindow: Bool = false) {
        self.screenName = screenName
        self.body = body
        self.pointingDirection = pointingDirection
        self.pointPosition = pointPosition
        self.targetFrame = targetFrame
        self.arrowOffset = arrowOfset
        self.showDimOverlay = showDimOverlay
        self.overUIWindow = overUIWindow
    }
}

protocol TutorialSupport: class {
    func steps() -> [TutorialStep]
}

class TutorialManager {
    private let tutorials: [TutorialStep]
    private weak var viewController: TutorialSupport?
    private var currentTutorialIndex: Int = 0
    private var autoPlay: Bool = true
    
    init(viewController: TutorialSupport, autoPlay: Bool = true) {
        self.viewController = viewController
        self.tutorials = viewController.steps()
        self.autoPlay = autoPlay
    }
    
    func showTutorial() {
        guard currentTutorialIndex < tutorials.count else {
            return
        }
        
        showTutorial(step: tutorials[currentTutorialIndex])
    }
    
    func showTutorial(step: TutorialStep?) {
        guard let step = step else { return }
        
        if TutorialManager.hasTutorialScreenBeenShown(for: step.screenName) {
            // already shown for this screen, do nothing
            currentTutorialIndex = currentTutorialIndex + 1
            showTutorial()
            return
        }
        
        guard let viewController = viewController as? UIViewController else { return }
        
        let tutorialView = TutorialView()
        tutorialView.configure(tutorialStep: step)
        tutorialView.delegate = self
        tutorialView.show(inView: viewController.view, withDelay: 100)
        TutorialManager.setTutorialAsShown(for: step.screenName)
    }
    
    static func setTutorialAsShown(for screenName: String) {
        if var viewedTutorialsMemory = AppSettingsManager.shared.getViewedTutorialsMemory() {
            viewedTutorialsMemory[screenName] = true
            AppSettingsManager.shared.setViewedTutorialsMemory(value: viewedTutorialsMemory)
        } else {
            var viewedTutorialsMemory: [String: Bool] = [:]
            viewedTutorialsMemory[screenName] = true
            AppSettingsManager.shared.setViewedTutorialsMemory(value: viewedTutorialsMemory)
        }
    }
    
    static func setTutorialAsNotShown(for screenName: String) {
        if var viewedTutorialsMemory = AppSettingsManager.shared.getViewedTutorialsMemory() {
            viewedTutorialsMemory[screenName] = nil
            AppSettingsManager.shared.setViewedTutorialsMemory(value: viewedTutorialsMemory)
        }
    }
    
    static func hasTutorialScreenBeenShown(for screenName: String) -> Bool {
        if let viewedTutorialsMemory = AppSettingsManager.shared.getViewedTutorialsMemory() {
            return viewedTutorialsMemory[screenName] ?? false
        }
        return false
    }
    
    static func resetAllTutorials() {
        AppSettingsManager.shared.setViewedTutorialsMemory(value: nil)
    }
}

extension TutorialManager: TutorialViewDelegate {
    func dismissedTutorial(tutorialView: TutorialView) {
        currentTutorialIndex = currentTutorialIndex + 1
        if autoPlay {
            showTutorial()
        }
    }
}
