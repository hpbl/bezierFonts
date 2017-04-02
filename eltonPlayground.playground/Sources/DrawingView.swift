import Foundation
import UIKit

public class DrawingView: UIView {
    
    //MARK: Interface
    let words = [("hello", "e"), ("WWDC", "C"), ("bézier", "z"), ("fonts", "o")]
    let fonts = [("MAXWELL BOLD", "ttf"), ("Oduda", "otf"), ("Reef", "otf")]
    
    var wordLabel: UILabel?
    var hintButton: UIButton?
    var nextButton: UIButton?
    var currentWordIndex: Int?
    var currentFontIndex: Int?
    
    
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
        
        super.init(frame: CGRect(x: 0, y: 0, width: 480, height: 400))
        backgroundColor = UIColor.white
        
        
        //Label
        self.currentWordIndex = 0
        self.currentFontIndex = 0
        
        for font in fonts {
            let fontURL = Bundle.main.url(forResource: font.0, withExtension: font.1)
            CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
        }
        
        self.wordLabel = UILabel(frame: CGRect(x: 10, y: 100, width: 600, height: 150))
        self.wordLabel?.textColor = UIColor.black
        
        let attributedText = NSMutableAttributedString(string: words[self.currentWordIndex!].0)
        attributedText.addAttribute(NSForegroundColorAttributeName,
                                    value: self.backgroundColor!,
                                    range: (words[self.currentWordIndex!].0 as NSString).range(of: words[self.currentWordIndex!].1))
        self.wordLabel?.attributedText = attributedText
        
        self.wordLabel?.font = UIFont(name: fonts[self.currentFontIndex!].0, size: 150)
        
        self.addSubview(wordLabel!)
        
        
        //Hint Buttons
        self.hintButton = UIButton(frame: CGRect(x: self.frame.width/8 * 2, y: self.frame.height - self.frame.height/4, width: 70, height: 40))
        
        self.hintButton?.backgroundColor = UIColor.clear
        self.hintButton?.setTitle("show", for: .normal)
        self.hintButton?.setTitleColor(UIColor.gray, for: .normal)
        
        self.hintButton?.setTitle("hide", for: .selected)
        self.hintButton?.setTitleColor(UIColor.darkGray, for: .selected)
        
        self.hintButton?.addTarget(self, action: #selector(self.hintAction), for: .touchUpInside)
        
        
        self.addSubview(self.hintButton!)
        
        //Next Buttons
        self.nextButton = UIButton(frame: CGRect(x: self.frame.width/8 * 5, y: self.frame.height - self.frame.height/4, width: 70, height: 40))
        
        self.nextButton?.backgroundColor = UIColor.clear
        self.nextButton?.setTitle("next", for: .normal)
        self.nextButton?.setTitleColor(UIColor.gray, for: .normal)
        
        self.nextButton?.addTarget(self, action: #selector(self.nextAction), for: .touchUpInside)
        
        
        self.addSubview(self.nextButton!)
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
        let circle = UIView(frame: CGRect(x: point.x, y: point.y, width: 12, height: 12))

        circle.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 37/255, alpha: 1)
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
                circle.backgroundColor = UIColor.darkGray
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
    
    
    //MARK: - Interface methods
    func hintAction() {
        self.hintButton?.isSelected = !(self.hintButton?.isSelected)!
        
        if (self.hintButton?.isSelected)! {
            let attributedText = NSMutableAttributedString(string: words[self.currentWordIndex!].0)
            attributedText.addAttribute(NSForegroundColorAttributeName,
                                        value: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1),
                                        range: (words[self.currentWordIndex!].0 as NSString).range(of: words[self.currentWordIndex!].1))
            self.wordLabel?.attributedText = attributedText
        
        } else {
            let attributedText = NSMutableAttributedString(string: words[self.currentWordIndex!].0)
            attributedText.addAttribute(NSForegroundColorAttributeName,
                                        value: self.backgroundColor!,
                                        range: (words[self.currentWordIndex!].0 as NSString).range(of: words[self.currentWordIndex!].1))
            self.wordLabel?.attributedText = attributedText
        }
    }
    
    func nextAction() {
        // Clean screen
        self.pointviews.forEach({$0.removeFromSuperview()})
        self.pointviews.removeAll()
        self.controlPoints.removeAll()
        self.curvePoints.removeAll()
        
        //TODO: Update word
        self.currentWordIndex = (self.currentWordIndex! + 1) % self.words.count
        self.currentFontIndex = (self.currentFontIndex! + 1) % self.fonts.count
        
        let attributedText = NSMutableAttributedString(string: words[self.currentWordIndex!].0)
        attributedText.addAttribute(NSForegroundColorAttributeName,
                                    value: self.backgroundColor!,
                                    range: (words[self.currentWordIndex!].0 as NSString).range(of: words[self.currentWordIndex!].1))
        self.wordLabel?.attributedText = attributedText
        
        self.wordLabel?.font = UIFont(name: fonts[self.currentFontIndex!].0, size: 150)
        
        self.hintButton?.isSelected = false
        
    }
}

