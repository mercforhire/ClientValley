//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import Foundation
import UIKit

class FullScreenSpinner {
    private static let spinnerView = SpinnerView()
    private static var animator: UIViewPropertyAnimator?
    
    func show(transparent: Bool = true) {
        guard let window = UIViewController.window else { return }

        FullScreenSpinner.spinnerView.frame = window.bounds
        window.addSubview(FullScreenSpinner.spinnerView)
        window.bringSubviewToFront(FullScreenSpinner.spinnerView)
        
        FullScreenSpinner.spinnerView.alpha = 0
        
        if let animator = FullScreenSpinner.animator {
            animator.stopAnimation(true)
        }
        
        FullScreenSpinner.animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            FullScreenSpinner.spinnerView.alpha = 1
        }
        
        FullScreenSpinner.animator?.addCompletion({ _ in
            FullScreenSpinner.spinnerView.startAnimation(bgAlpha: transparent ? 0.6 : 1)
        })
        
        FullScreenSpinner.animator?.startAnimation()
    }
    
    func hide() {
        if let animator = FullScreenSpinner.animator {
            animator.stopAnimation(true)
        }
        
        FullScreenSpinner.animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            FullScreenSpinner.spinnerView.alpha = 0
        }
        
        FullScreenSpinner.animator?.addCompletion({ _ in
            FullScreenSpinner.spinnerView.removeFromSuperview()
            FullScreenSpinner.spinnerView.stopAnimation()
        })
        
        FullScreenSpinner.animator?.startAnimation()
    }
}
