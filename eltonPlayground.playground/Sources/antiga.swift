//import Foundation
//import UIKit
//
//public class DrawingView: UIView {
//    
//    
//    //MARK: - Point methods
//    //normalizing point to [-1, 1]
//    func normalize(point: CGPoint) -> CGPoint{
//        var normalizedPoint: CGPoint = point
//        
//        normalizedPoint.x = (((point.x - self.frame.width)*(1 - (-1)))/(self.frame.width)) - (-1)
//        normalizedPoint.y = (((point.y - self.frame.height)*(1 - (-1)))/(self.frame.height)) - (-1)
//        
//        return normalizedPoint
//    }
//    
//    func foundPoint(on mouseClick: CGPoint) -> Int? {
//        
//        //creating rect centered where user clicked
//        let touchRect : CGRect = CGRect(x: mouseClick.x-15, y: mouseClick.y-15, width: 30, height: 30)
//        
//        for index in (0..<self.controlPoints.count) {
//            if touchRect.contains(self.controlPoints[index]) {
//                return index
//            }
//        }
//        return nil
//    }
//    
//    
//    // MARK: - Drawing methods
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//        
//        // Drawing code here.
//        
//        //clearing the color buffer and setting bg color
//        glClearColor(40/255, 43/255, 53/255, 1)
//        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
//        
//        self.draw(points: self.controlPoints)
//        if self.controlPoints.count > 1 {
//            // self.drawCurve(points: self.curvePoints)
//            self.drawCurveLines()
//        }
//        
//        if self.controlPoints.count > 2 && self.shouldDrawHull {
//            self.drawConvexHull(from: self.convexHull)
//        }
//        
//        //forcing execution of GL commands
//        glFlush()
//    }
//    
//    // OpengL routine to draw points
//    func draw(points: [CGPoint]) {
//        glPointSize(6.0)
//        glColor3f(225/255, 61/255, 121/255)
//        glBegin(GLenum(GL_POINTS))
//        
//        for point in points {
//            let normPoint = self.normalize(point: point)
//            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
//        }
//        
//        glEnd();
//    }
//    
//    // OpengL routine to draw curve
//    func drawCurveLines() {
//        
//        glLineWidth(0.5);
//        glColor3f(0, 170/255, 202/255);
//        glBegin(GLenum(GL_LINES));
//        
//        if(curvePoints.count > 1){
//            for index in (0..<(self.curvePoints.count)) {
//                let point = self.normalize(point: curvePoints[index])
//                var nextPoint : CGPoint
//                
//                if(index == self.curvePoints.count-1){
//                    nextPoint = self.normalize(point: controlPoints[self.controlPoints.endIndex-1])
//                }
//                else{
//                    nextPoint = self.normalize(point: curvePoints[index+1])
//                }
//                
//                glVertex3fv([Float(point.x), Float(point.y), 0])
//                glVertex3fv([Float(nextPoint.x), Float(nextPoint.y), 0])
//                
//            }
//        }
//        
//        glEnd();
//        
//    }
//    
//    // OpengL routine to draw Convex Hull
//    func drawConvexHull(from points: [CGPoint]) {
//        glLineWidth(2.5)
//        glColor3f(77/255, 192/255, 86/255)
//        glBegin(GLenum(GL_LINES))
//        
//        for index in (0..<self.convexHull.count) {
//            let normPoint = self.normalize(point: self.convexHull[index])
//            var nextNormPoint : CGPoint
//            if index == self.convexHull.count-1 {
//                nextNormPoint = self.normalize(point: self.convexHull[0])
//            } else {
//                nextNormPoint = self.normalize(point: self.convexHull[index+1])
//            }
//            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
//            glVertex3fv([Float(nextNormPoint.x), Float(nextNormPoint.y), 0])
//            
//        }
//        
//        glEnd();
//    }
//    
//    
//    // MARK: - Mouse and Keyboard methods
//    override func mouseDown(with event: NSEvent) {
//        //loop control variables
//        var keepOn: Bool = true
//        var isDragging: Bool = false
//        
//        let mouseDragOrUp : NSEventMask = NSEventMask(rawValue: UInt64(Int(NSEventMask.leftMouseUp.union(.leftMouseDragged).rawValue)))
//        
//        while (keepOn) {
//            
//            let nextEvent : NSEvent = (self.window?.nextEvent(matching: mouseDragOrUp))!
//            let mouseLocation: CGPoint = self.convert(nextEvent.locationInWindow, from: nil)
//            let isInsideWindow: Bool = self.mouse(mouseLocation, in: self.bounds)
//            
//            switch (nextEvent.type) {
//                
//            case NSEventType.leftMouseDragged:
//                isDragging = true
//                if let index = self.foundPoint(on: mouseLocation) {
//                    //move point to mouse location
//                    self.controlPoints[index] = mouseLocation
//                }
//                break
//                
//            case NSEventType.leftMouseUp:
//                if (isInsideWindow && !isDragging) {
//                    //create new point
//                    self.controlPoints.append(mouseLocation)
//                }
//                isDragging = false
//                keepOn = false
//                break
//                
//            default:
//                // Ignoring any other type of event
//                break
//            }
//        }
//        return
//    }
//    
//    override func rightMouseDown(with event: NSEvent) {
//        
//        //converting screen to window coordinates
//        let touchPoint : CGPoint = self.convert(event.locationInWindow, from: nil)
//        
//        if let index = self.foundPoint(on: touchPoint) {
//            self.controlPoints.remove(at: index)
//        }
//    }
//    
//    override func keyDown(with event: NSEvent) {
//        if event.keyCode == 8 {
//            self.shouldDrawHull = !self.shouldDrawHull
//        }
//    }
//    
//    
