//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

class TriangleView: UIView {
    enum PointingDirection {
        case up
        case down
    }
    
    var color: UIColor! = UIColor.white
    var direction: PointingDirection = .up
    
    @IBInspectable var fillColor: UIColor? {
        get { return color }
        set { color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        switch direction {
        case .up:
            context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        case .down:
            context.move(to: CGPoint(x: rect.minX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        }
        context.closePath()
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
