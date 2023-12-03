//
//  UIView+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import Foundation
import UIKit

extension UIView {
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
    
    static func fromNib() -> UIView? {
        let nib = UINib(nibName: String(describing: self), bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func fill(with view: UIView) {
        view.frame = bounds
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func roundSelectedCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        clipsToBounds = true
        setNeedsDisplay()
    }
    
    var globalFrame: CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
    
    func drawHole(hole: CGRect, style: RoundCornerStyle?, border: Bool) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        let holePath = UIBezierPath(roundedRect: hole, cornerRadius: style?.radius() ?? 0.0)
        let path = UIBezierPath(rect: bounds)
        path.append(holePath)
        // Setup the fill rule to EvenOdd to properly mask the specified area and make a crater
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // Append the circle to the path so that it is subtracted.
        maskLayer.path = path.cgPath
        // Mask our view with Blue background so that portion of red background is visible
        layer.mask = maskLayer
        
        if border {
            // Add border
            let borderLayer = CAShapeLayer()
            borderLayer.path = holePath.cgPath // Reuse the Bezier path
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.lineWidth = 3
            borderLayer.frame = CGRect.zero
            layer.addSublayer(borderLayer)
        }
    }
    
    func addDropShadowToRoundedView(to roundedView: UIView, color: UIColor = UIColor.lightGray, opacity: Float = 0.19, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4.0, spread: CGFloat = 0) -> UIView {
        let shadowView = UIView(frame: roundedView.frame)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: x, height: y)
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowRadius = blur / 2.0
        shadowView.layer.shadowOpacity = opacity
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: roundedView.bounds, cornerRadius: roundedView.bounds.width / 2).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        insertSubview(shadowView, belowSubview: roundedView)
        return shadowView
    }
    
    private static let separatorTag = 111_111_111
    
    enum SeparatorPosition: CGFloat {
        case bottom
        case top
        case both
        case none
    }
    
    func insertOnePixelSeparator(color: UIColor = UIColor.lightGray, inset: CGFloat = 0.0, position: SeparatorPosition = .bottom) {
        switch position {
        case .top :
            removeOnePixelSeparator()
            insertOnePixelSeparator(y: 1.0, color: color, inset: inset)
        case .bottom:
            removeOnePixelSeparator()
            insertOnePixelSeparator(y: frame.height, color: color, inset: inset)
        case .both:
            insertOnePixelSeparator(y: 1.0, color: color, inset: inset)
            insertOnePixelSeparator(y: frame.height, color: color, inset: inset)
        default:
            return
        }
    }
    
    /*
     Example 1:
     override func layoutSubviews() {
     super.layoutSubviews()
     insertOnePixelSeparator(color: AppColor.paleGrey.color(), inset: 20.0)
     }
     Example 2:
     override func addSubviewsAfterLayout() {
     super.addSubviewsAfterLayout()
     
     if showShadowUnderCTA {
     insertOnePixelSeparator(color: AppColor.paleGrey.color(), inset: 20.0)
     }
     }
     */
    func insertOnePixelSeparator(height: CGFloat = 1.0, y: CGFloat, color: UIColor, inset: CGFloat) {
        let screenSize = UIScreen.main.bounds
        let separatorHeight = height
        let additionalSeparator = UIView(frame: CGRect(x: inset, y: y - height, width: screenSize.width - (inset*2), height: separatorHeight))
        additionalSeparator.backgroundColor = color
        additionalSeparator.tag = UIView.separatorTag
        self.addSubview(additionalSeparator)
    }
    
    func removeOnePixelSeparator() {
        for separator in self.subviews where separator.tag == UIView.separatorTag {
            separator.removeFromSuperview()
        }
    }
    
    func addBorder(color: UIColor = UIColor.systemIndigo) {
        layer.borderWidth = 1.0
        layer.borderColor = color.cgColor
    }
    
    enum RoundCornerStyle {
        case small
        case medium
        case large
        case completely
        
        func radius() -> CGFloat {
            switch self {
            case .small:
                return 7.0
            case .medium:
                return 12.0
            case .large:
                return 24.0
            case .completely:
                return 0.0
            }
        }
    }
    
    func roundCorners(style: RoundCornerStyle = .small) {
        switch style {
        case .small, .medium, .large:
            layer.cornerRadius = style.radius()
        case .completely:
            layer.cornerRadius = frame.height / 2
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        clipsToBounds = true
        setNeedsDisplay()
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension CGRect {
    
    func getOutlineFrame(thickness: CGFloat) -> CGRect {
        var new = self
        new.origin.x = new.origin.x - thickness
        new.origin.y = new.origin.y - thickness
        new.size.width = new.width + 2 * thickness
        new.size.height = new.height + 2 * thickness
        return new
    }
    
}
