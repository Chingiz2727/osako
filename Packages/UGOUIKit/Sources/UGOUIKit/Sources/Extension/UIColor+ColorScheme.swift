import UIKit

public extension UIColor {
    
    static var colorScheme: UGOColorScheme = XCAssetsColorScheme()
    
    static var brandGreen: UIColor { colorScheme.brandGreen }
    
    static var brandGreenPeel: UIColor { colorScheme.brandGreenPeel }
    
    static var brandLightGreen: UIColor { colorScheme.brandLightGreen }
    
    static var brandVividGreen: UIColor { colorScheme.brandVividGreen }
    
    static var uiBlue: UIColor { colorScheme.uiBlue }
    
    static var uiDeepBlue: UIColor { colorScheme.uiDeepBlue }
    
    static var uiDeepGreen: UIColor { colorScheme.uiDeepGreen }
    
    static var uiDeepRed: UIColor { colorScheme.uiDeepRed }
    
    static var uiGreen: UIColor { colorScheme.uiGreen }
    
    static var uiLightBlue: UIColor { colorScheme.uiLightBlue }
    
    static var uiLightGreen: UIColor { colorScheme.uiLightGreen }
    
    static var uiLightRed: UIColor { colorScheme.uiLightRed }
    
    static var uiRed: UIColor { colorScheme.uiRed }
    
    static var white: UIColor { colorScheme.white }
    
    static var gray03: UIColor { colorScheme.gray03 }
    
    static var gray10: UIColor { colorScheme.gray10 }
    
    static var gray30: UIColor { colorScheme.gray30 }
    
    static var gray55: UIColor  { colorScheme.gray55 }
    
    static var gray75: UIColor { colorScheme.gray75 }
    
    static var gray90: UIColor  { colorScheme.gray90 }
    
}

public protocol UGOColorScheme: AnyObject {
    var brandGreen: UIColor { get }
    
    var brandGreenPeel: UIColor { get }
    
    var brandLightGreen: UIColor { get }
    
    var brandVividGreen: UIColor { get }
    
    var uiBlue: UIColor { get }
    
    var uiDeepBlue: UIColor { get }
    
    var uiDeepGreen: UIColor { get }
    
    var uiDeepRed: UIColor { get }
    
    var uiGreen: UIColor { get }
    
    var uiLightBlue: UIColor { get }
    
    var uiLightGreen: UIColor { get }
    
    var uiLightRed: UIColor { get }
    
    var uiRed: UIColor { get }
    
    var white: UIColor { get }
    
    var gray03: UIColor { get }
    
    var gray10: UIColor { get }
    
    var gray30: UIColor { get }
    
    var gray55: UIColor  { get }
    
    var gray75: UIColor { get }
    
    var gray90: UIColor  { get }
}


private final class XCAssetsColorScheme: UGOColorScheme {
    var brandGreen: UIColor { required("brandGreen") }
    
    var brandGreenPeel: UIColor { required("brandGreenPeel") }
    
    var brandLightGreen: UIColor { required("brandLightGreen") }
    
    var brandVividGreen: UIColor { required("brandVividGreen") }
    
    var uiBlue: UIColor { required("UIBlue") }
    
    var uiDeepBlue: UIColor { required("UIDeepBlue") }
    
    var uiDeepGreen: UIColor { required("UIDeepGreen") }
    
    var uiDeepRed: UIColor { required("UIDeepRed") }
    
    var uiGreen: UIColor { required("UIGreen") }
    
    var uiLightBlue: UIColor { required("UIlightBlue") }
    
    var uiLightGreen: UIColor { required("UIlightGreen") }
    
    var uiLightRed: UIColor { required("UIlightRed") }
    
    var uiRed: UIColor { required("UIred") }
    
    var white: UIColor { required("white") }
    
    var gray03: UIColor { required("gray03") }
    
    var gray10: UIColor { required("gray10") }
    
    var gray30: UIColor { required("gray30") }
    
    var gray55: UIColor { required("gray55") }
    
    var gray75: UIColor { required("gray75") }
    
    var gray90: UIColor { required("gray90") }
    
}


private func required(_ colorName: String) -> UIColor {
    guard let color = UIColor(named: colorName, in: Bundle.module, compatibleWith: nil) else {
        return UIColor.black
    }
    
    return color
}
