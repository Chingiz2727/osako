import UIKit

public extension UIFont {
    
    static var title: UIFont {
        return Font.montserrat.rawValue.make(32, weight: .semiBold)
    }
    
    static var title1: UIFont {
        return Font.montserrat.rawValue.make(40, weight: .bold)
    }
    
    static var title2: UIFont {
        return Font.montserrat.rawValue.make(32, weight: .semiBold)
    }
    
    static var headLine: UIFont {
        return Font.montserrat.rawValue.make(18, weight: .bold)
    }
    
    static var subtitle1: UIFont {
        return Font.montserrat.rawValue.make(24, weight: .semiBold)
    }
    
    static var subtitle2: UIFont {
        return Font.montserrat.rawValue.make(18, weight: .semiBold)
    }
    
    static var body1_regular: UIFont {
        return Font.montserrat.rawValue.make(16, weight: .regular)
    }
    
    static var body1_bold: UIFont {
        return Font.montserrat.rawValue.make(16, weight: .semiBold)
    }
    
    static var body2_regular: UIFont {
        return Font.montserrat.rawValue.make(14, weight: .regular)
    }
    
    static var body2_bold: UIFont {
        return Font.montserrat.rawValue.make(14, weight: .semiBold)
    }
    
    static var body3_regular: UIFont {
        return Font.montserrat.rawValue.make(12, weight: .regular)
    }
    
    static var body3_bold: UIFont {
        return Font.montserrat.rawValue.make(12, weight: .semiBold)
    }
    
    static var caption1_light: UIFont {
        return Font.montserrat.rawValue.make(12, weight: .light)
    }
    
    static var caption1_bold: UIFont {
        return Font.montserrat.rawValue.make(12, weight: .semiBold)
    }
    
    static var caption2_light: UIFont {
        return Font.montserrat.rawValue.make(10, weight: .light)
    }
    
    static var caption2_bold: UIFont {
        return Font.montserrat.rawValue.make(10, weight: .semiBold)
    }
    
    static var buttonL: UIFont {
        return Font.montserrat.rawValue.make(20, weight: .semiBold)
    }
    
    static var buttonM: UIFont {
        return Font.montserrat.rawValue.make(14, weight: .semiBold)
    }
    
    static var buttonS: UIFont {
        return Font.montserrat.rawValue.make(8, weight: .semiBold)
    }
}
