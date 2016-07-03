//
//  GraphViewController.swift
//  Calculator
//

import UIKit

class GraphViewController: UIViewController {
    
     var yForX: (( x: Double) -> Double?)?  { didSet { updateUI() } }
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.scale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.originMove(_:))))
            
            let doubleTapRecognizer = UITapGestureRecognizer(
                target: graphView, action: #selector(GraphView.origin(_:)))
            
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            
            graphView.scale = scale
            graphView.originRelativeToCenter = originRelativeToCenter
        updateUI()
        }
    }
    
    func updateUI() {
        graphView?.yForX = yForX
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin"
    }
    
    var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 50.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    var originFactorDefault: CGPoint {
        get {
            let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat]
            return CGPoint(x: originArray?.first ?? CGFloat (0.0),
                           y: originArray?.last ?? CGFloat (0.0))
        }
        set {
            defaults.setObject([newValue.x, newValue.y], forKey: Keys.Origin)
        }
    }
    
    var originRelativeToCenter: CGPoint {
        return CGPoint (x: originFactorDefault.x * graphView.bounds.size.width,
                        y: originFactorDefault.y * graphView.bounds.size.height)
    }
    
    var factorOld = CGPointZero
    var widthOld = CGFloat(0.0)
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        widthOld = graphView.bounds.size.width
        factorOld = CGPoint(x: graphView.originRelativeToCenter.x / graphView.bounds.size.width,
                            y: graphView.originRelativeToCenter.y / graphView.bounds.size.height )
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !(graphView.bounds.size.width == widthOld) {
            graphView.originRelativeToCenter = CGPoint(x: factorOld.x * graphView.bounds.size.width,
                                                        y: factorOld.y * graphView.bounds.size.height)
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        scale = graphView.scale
        originFactorDefault =
            CGPoint(x: graphView.originRelativeToCenter.x / graphView.bounds.size.width,
                    y: graphView.originRelativeToCenter.y / graphView.bounds.size.height)
    }
}