import Foundation
import UIKit

public class DrawingView: UIView {
    

    //MARK: - Class properties
    var pointviews: [UIView] = []
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
        
        for view in self.subviews {
            if view.tag == 1337 {
                view.removeFromSuperview()
            }
        }
        
        //self.draw(points: self.controlPoints)
        if curvePoints.count > 2 {
            for point in self.curvePoints {
                self.drawCurveCircle(on: point)
            }
        }
    }
    
    func drawCurveCircle(on point: CGPoint) {
        let circle = UIView(frame: CGRect(x: point.x, y: point.y, width: 4, height: 4))

        circle.backgroundColor = UIColor.red
        circle.layer.cornerRadius = circle.frame.width/2
        circle.clipsToBounds = true
        circle.tag = 1337

        
        self.addSubview(circle)
        //self.pointviews.append(circle)

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
            
            if self.foundPoint(on: touchLocation) == nil {
                self.controlPoints.append(touchLocation)
                
                let circle = UIView(frame: CGRect(x: touchLocation.x-4, y: touchLocation.y-4, width: 8, height: 8))
                circle.backgroundColor = UIColor.black
                circle.layer.cornerRadius = circle.frame.width/2
                circle.clipsToBounds = true
                
                let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                circle.addGestureRecognizer(gestureRecognizer)
                
                self.pointviews.append(circle)
                self.addSubview(circle)
            }
        }
    }
    
    
    func foundPoint(on touchLocation: CGPoint) -> Int? {
        let touchRect = CGRect(x: touchLocation.x-10, y: touchLocation.y-10, width: 20, height: 20)
        
        for point in self.controlPoints {
            if touchRect.contains(point) {

                self.bringSubview(toFront:               self.pointviews[self.controlPoints.index(of: point)!])
                //print("achei ponto")
                return self.controlPoints.index(of: point)
            }
        }
        //print("não achei ponto")
        return nil
    }
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let index = self.pointviews.index(of: gestureRecognizer.view!)
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            gestureRecognizer.view?.center = gestureRecognizer.location(in: self)
            
            self.controlPoints[index!] = self.pointviews[index!].frame.origin
        }

    }
}

