import Foundation
import UIKit

public class DrawingView: UIView {
    
    
    //MARK: - Class properties
    var controlPoints: [CGPoint] = [] {
        //updates interface when new value is attributed
        didSet {
            if controlPoints != oldValue {
                if controlPoints.count > 1{
                    self.bezierCurve()
                    self.convexHull(of: controlPoints)
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
    
    public override func draw(_ rect: CGRect) {
        
        if self.layer.sublayers != nil {
            print(self.layer.sublayers!.count)
            self.layer.sublayers?.removeAll()
        }

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
        print("rodou")
        self.curvePoints = []
        var factor = 0.0
        while factor < 1 {
            
            self.curvePoints.append(curvePoint(from: controlPoints, t: factor))
            factor = factor + 0.0005
        }
    }
    
    
    // MARK: - Convex Hull
    func convexHull(of controlPoints: [CGPoint]) {
        //Sorting the points by x-coordinate (in case of a tie, sorting by y-coordinate)
        let sortedPoints = controlPoints.sorted { (pointA, pointB) -> Bool in
            return (pointA.x == pointB.x) ? (pointA.y > pointB.y) : (pointA.x > pointB.x)
        }
        
        var upperHull : [CGPoint] = []
        var lowerHull : [CGPoint] = []
        
        /*while L contains at least two points and the sequence of last two points
         of L and the point P[i] does not make a counter-clockwise turn:
         remove the last point from L*/
        for point in sortedPoints {
            while (lowerHull.count >= 2) &&
                (self.crossProduct(pointO: lowerHull[lowerHull.count-2],
                                   pointA: lowerHull[lowerHull.count-1],
                                   pointB: point) <= 0) {
                                    lowerHull.removeLast()
            }
            lowerHull.append(point)
        }
        
        /*for i = n, n-1, ..., 1:
         while U contains at least two points and the sequence of last two points
         of U and the point P[i] does not make a counter-clockwise turn:
         remove the last point from U
         append P[i] to U*/
        for point in sortedPoints.reversed() {
            while (upperHull.count >= 2) &&
                (self.crossProduct(pointO: upperHull[upperHull.count-2],
                                   pointA: upperHull[upperHull.count-1],
                                   pointB: point) <= 0) {
                                    upperHull.removeLast()
            }
            upperHull.append(point)
        }
        
        //removing duplicates
        //lowerHull.removeLast()
        upperHull.removeLast()
        
        self.convexHull = lowerHull + upperHull
    }
    
    func crossProduct(pointO: CGPoint, pointA: CGPoint, pointB: CGPoint) -> Double {
        /*  2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
         Returns a positive value, if OAB makes a counter-clockwise turn,
         negative for clockwise turn, and zero if the points are collinear.*/
        let part1 = (pointA.x - pointO.x) * (pointB.y - pointO.y)
        let part2 = (pointA.y - pointO.y) * (pointB.x - pointO.x)
        return  Double(part1 - part2)
    }
    
    
    // MARK: - Handling Touch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: superview)
            
            if let foundPointIndex = self.foundPoint(on: touchLocation) {
                self.controlPoints.remove(at: foundPointIndex)
           
            } else {
                self.controlPoints.append(CGPoint(x: touchLocation.x, y: touchLocation.y))
            }
            
            //print(self.controlPoints.count)
            
        }
        
    }
    
    func foundPoint(on touchLocation: CGPoint) -> Int? {
        
        //creating rect centered where user clicked
        let touchRect : CGRect = CGRect(x: touchLocation.x-15, y: touchLocation.y-15, width: 30, height: 30)
        
        for index in (0..<self.controlPoints.count) {
            if touchRect.contains(self.controlPoints[index]) {
                return index
            }
        }
        return nil
    }
}

