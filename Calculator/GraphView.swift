//
//  GraphView.swift
//  Calculator

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var yForX: (( x: Double) -> Double?)? { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    private var originSet: CGPoint? { didSet { setNeedsDisplay() } }
    var origin: CGPoint {
        get {
            return originSet ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            originSet = newValue
        }
    }
    private let axesDrawer = AxesDrawer(color: UIColor.blueColor())
    override func drawRect(rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        drawCurveInRect(bounds, origin: origin, scale: scale)
    }
    
    func drawCurveInRect(bounds: CGRect, origin: CGPoint, scale: CGFloat){
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var point = CGPoint()
        
        var x: Double {return Double ((point.x - origin.x) / scale)}
        
        // ---Разрывные точки----
        var oldPoint = OldPoint (y: point.y, normal: false)
        var disContinuity:Bool {
            return abs(point.y - oldPoint.y) > max(bounds.width, bounds.height) * 1.5}
        //-----------------------
        
        for i in 0...Int(bounds.size.width * contentScaleFactor){
            point.x = CGFloat(i) / contentScaleFactor
            
            if let y = (yForX)?(x: x) {
                if !y.isFinite {
                    oldPoint.normal = false
                    continue
                }
                point.y = origin.y - CGFloat(y) * scale
                if !oldPoint.normal{
                    path.moveToPoint(point)
                    oldPoint =  OldPoint ( y: point.y, normal: true)
                } else {
                    if disContinuity {
                        oldPoint =  OldPoint ( y: point.y, normal: false)
                        continue
                    } else {
                        path.addLineToPoint(point)
                        oldPoint =  OldPoint(y: point.y, normal: true)
                    }
                }
            } else {
                oldPoint.normal = false
            }
        }
        path.stroke()
    }
    
    private struct OldPoint {
        var y: CGFloat
        var normal: Bool
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    func originMove(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            if translation != CGPointZero {
                origin.x += translation.x
                origin.y += translation.y
                gesture.setTranslation(CGPointZero, inView: self)
            }
        default: break
        }
    }
    
    func origin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }

}
