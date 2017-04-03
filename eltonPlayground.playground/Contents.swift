import PlaygroundSupport
import UIKit


let eltonView = DrawingView()

PlaygroundPage.current.liveView = eltonView

let helpLabel = UILabel(frame: CGRect(x: 30, y: 20, width: eltonView.frame.height, height: eltonView.frame.width))

helpLabel.text = "tap to add control points and form the missing letter"

helpLabel.textColor = UIColor.darkGray
helpLabel.sizeToFit()

eltonView.addSubview(helpLabel)
