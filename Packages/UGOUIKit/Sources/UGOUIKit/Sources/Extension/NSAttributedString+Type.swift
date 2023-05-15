import UIKit

public extension NSAttributedString {
    
    convenience init(
        string: String?,
        typography: Typography,
        alignment: NSTextAlignment = .natural,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail) {
            var attributes = typography.asAttributes
            let paragraph = (attributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            paragraph.alignment = alignment
            paragraph.lineBreakMode = lineBreakMode
            attributes[.paragraphStyle] = paragraph
            self.init(string: string ?? "", attributes: attributes)
        }
}

public extension Typography {
    var asAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSMutableAttributedString.Key: Any] = [.font: font]
        let paragraph = NSMutableParagraphStyle()
        
        if let lineHeight = lineHeight {
            paragraph.minimumLineHeight = lineHeight
        }
        if let lineSpacing = lineSpacing {
            paragraph.lineSpacing = lineSpacing
        }
        
        attributes[.paragraphStyle] = paragraph
        
        if let letterSpacing = letterSpacing {
            attributes[.kern] = letterSpacing
        }
        
        return attributes
    }
}
