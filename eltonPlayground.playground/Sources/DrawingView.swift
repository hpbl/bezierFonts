import Foundation
import UIKit

public class DrawingView: UIView {
    

    //MARK: - Class properties
    var pointLayers: [CALayer] = []
    var controlPoints: [CGPoint] = [] {
        //updates interface when new value is attributed
        didSet {
            if controlPoints != oldValue {
                if controlPoints.count > 1{
                    self.bezierCurve()
                    
                } else {
                    self.curvePoints = []
                }
                
                self.setNeedsDisplay(self.frame)
            }
        }
    }
    
    var curvePoints: [CGPoint] = [] {
        //updates interface when new value is attributed
        didSet {
            if curvePoints != oldValue {
                self.setNeedsDisplay(self.frame)
            }
        }
    }
    
    var convexHull: [CGPoint] = []
    
    var shouldDrawHull: Bool = false {
        didSet {
            self.setNeedsDisplay(self.frame)
        }
    }
    
    public override var isFirstResponder: Bool { return true }
    
    //MARK: - inits
    public init() {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 480, height: 600))
        backgroundColor = UIColor.white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func draw(_ rect: CGRect) {
        
        self.pointLayers.map({$0.removeFromSuperlayer()})
        self.pointLayers = []

        self.draw(points: self.controlPoints)
        if curvePoints.count > 2 {
            self.draw(points: self.curvePoints)
        }
    }
    
    
    func draw(points: [CGPoint]) {
        for point in points {
            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 8, height: 8))
            
            let layer = CAShapeLayer()
            layer.path = dotPath.cgPath
            layer.strokeColor = UIColor.blue.cgColor
            
            self.layer.addSublayer(layer)
            self.pointLayers.append(layer)
        }
    }
    
    
    // MARK: - deCasteljau
    func linearInterpolation(of pointA: CGPoint, and pointB: CGPoint, by t: Double) -> CGPoint {
        var interpolation: CGPoint = CGPoint()
        
        // Interpolation of X coordinates
        let pointAInterX = (1-t)*Double((pointA.x))
        let pointBInterX = Double(pointB.x)*t
        interpolation.x = CGFloat(pointAInterX + pointBInterX)
        
        // Interpolation of X coordinates
        let pointAInterY = (1-t)*Double((pointA.y))
        let pointBInterY = Double(pointB.y)*t
        interpolation.y = CGFloat(pointAInterY + pointBInterY)
        
        return interpolation
    }
    
    func curvePoint(from controlPoints: [CGPoint], t: Double) -> CGPoint {
        var controlPointsAux : [CGPoint] = controlPoints
        
        for column in (1..<controlPointsAux.count) {
            for index in (0..<controlPointsAux.count-column) {
                controlPointsAux[index] = linearInterpolation(of: controlPointsAux[index], and: controlPointsAux[index+1], by: t)
            }
        }
        return controlPointsAux[0]
    }
    
    func bezierCurve() {
        self.curvePoints = []
        var factor = 0.0
        while factor < 1 {
            
            self.curvePoints.append(curvePoint(from: controlPoints, t: factor))
            factor = factor + 0.0005
        }
    }
    
    
    // MARK: - Handling Touch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: superview)
            
            if let foundPointIndex = self.foundPoint(on: touchLocation) {
                //self.controlPoints.remove(at: foundPointIndex)
           
            } else {
                self.controlPoints.append(CGPoint(x: touchLocation.x-15, y: touchLocation.y-15))
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: superview)
            
            if let foundPointIndex = self.foundPoint(on: touchLocation) {
                self.controlPoints[foundPointIndex] = touchLocation
            }
        }
    }
    
    func foundPoint(on touchLocation: CGPoint) -> Int? {
        
        //creating rect centered where user clicked
        let touchRect : CGRect = CGRect(x: touchLocation.x-15, y: touchLocation.y-15, width: 20, height: 20)
        
        for index in (0..<self.controlPoints.count) {
            if touchRect.contains(self.controlPoints[index]) {
                return index
            }
        }
        return nil
    }
}

