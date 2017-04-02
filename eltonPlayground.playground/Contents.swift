import PlaygroundSupport
import UIKit


let eltonView = DrawingView()

PlaygroundPage.current.liveView = eltonView

//Fonts
let fontURL = Bundle.main.url(forResource: "Reef", withExtension: "otf")

CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)

var fontNames: [[AnyObject]] = []
for name in UIFont.familyNames {
    print(name)
    if let nameString = name as? String
    {
        fontNames.append(UIFont.fontNames(forFamilyName: nameString) as [AnyObject])
    }
}

//Label
var text = UILabel(frame: CGRect(x: 100, y: 200, width: 600, height: 150))
//text.text = "hello"
//text.font = text.font.withSize(150)
text.textColor = UIColor.black
eltonView.addSubview(text)

var main_string = "hello"
var string_to_color = "e"

var range = (main_string as NSString).range(of: string_to_color)

var attributedString = NSMutableAttributedString(string:main_string)
attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray , range: range)
text.attributedText = attributedString

text.font = UIFont(name: "Reef", size: 150)

