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
    
    var originRelativeToCenter = CGPointZero  { didSet { setNeedsDisplay() } }
 
    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
   private  var origin: CGPoint  {
        get {
            var origin = originRelativeToCenter
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        }
        set {
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originRelativeToCenter = origin
        }
    }

    private let axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    private var lightAxes:Bool = false // рисуем и оцифровываем засечки на осях
    private var lightCurve:Bool = false // рисуем график

    
    override func drawRect(rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale,
                                                               light: lightAxes)
         if !lightCurve {
            drawCurveInRect(bounds, origin: origin, scale: scale)}
    }
    
    func drawCurveInRect(bounds: CGRect, origin: CGPoint, scale: CGFloat){
        color.set()
      
        var xGraph, yGraph :CGFloat
        var x: Double {return Double ((xGraph - origin.x) / scale)}
        
        // ---Разрывные точки----
        var oldPoint = OldPoint (yGraph: 0.0, normal: false)
        var disContinuity:Bool {
            return abs( yGraph - oldPoint.yGraph) >
                              max(bounds.width, bounds.height) * 1.5}
        //-----------------------
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        for i in 0...Int(bounds.size.width * contentScaleFactor){
            xGraph = CGFloat(i) / contentScaleFactor
            guard let y = (yForX)?(x: x) where y.isFinite
                                    else { oldPoint.normal = false;  continue}
            yGraph = origin.y - CGFloat(y) * scale
            
            if !oldPoint.normal{
                path.moveToPoint(CGPoint(x: xGraph, y: yGraph))
            } else {
                guard !disContinuity else {
                    oldPoint =  OldPoint ( yGraph: yGraph, normal: false)
                    continue }
                path.addLineToPoint(CGPoint(x: xGraph, y: yGraph))
            }
            oldPoint =  OldPoint (yGraph: yGraph, normal: true)
        }
        path.stroke()
    }
    
    private struct OldPoint {
        var yGraph: CGFloat
        var normal: Bool
    }
    
    private var snapshot:UIView?
 
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    /* Оригинальный вариант без "замороженного" снимка
     
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
    */
    
    func originMove(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            lightAxes = true
            lightCurve = true
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.4
            self.addSubview(snapshot!)
        case .Changed:
            let translation = gesture.translationInView(self)
            if translation != CGPointZero {
                origin.x += translation.x
                origin.y += translation.y
                gesture.setTranslation(CGPointZero, inView: self)
            }
        case .Ended:
            snapshot!.removeFromSuperview()
            snapshot = nil
            lightAxes = false
            lightCurve = false
            setNeedsDisplay()
        default: break
        }
    }

    func origin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }

}
