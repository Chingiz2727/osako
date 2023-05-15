//
//  File.swift
//  
//
//  Created by Shyngys Kuandyk on 08.04.2022.
//

import Foundation
import UIKit

public struct Typography: Equatable {
    public let font: UIFont
    public let lineHeight: CGFloat?
    public let letterSpacing: CGFloat?
    public let lineSpacing: CGFloat?
    
    public init(
        font: UIFont,
        lineHeight: CGFloat? = nil,
        lineSpacing: CGFloat? = nil,
        letterSpacing: CGFloat? = nil
    ) {
        self.font = font
        self.lineHeight = lineHeight
        self.lineSpacing = lineSpacing
        self.letterSpacing = letterSpacing
    }
}

public extension Typography {
    enum Kind {
        case title1
        case title2
        case headline
        case subtitle1
        case subtitle2
        case body1_regular
        case body1_bold
        case body2_regular
        case body2_bold
        case body3_regular
        case body3_bold
        case caption1_light
        case caption1_bold
        case caption2_light
        case caption2_bold
        case buttonL
        case buttonM
        case buttonS
    }
    
    static func of(_ kind: Kind, isSingleLine: Bool = false) -> Typography {
        var typography: Typography
        
        switch kind {
        case .title1:
            typography = .title1
        case .title2:
            typography = .title2
        case .headline:
            typography = .headline
        case .subtitle1:
            typography = .subtitle1
        case .subtitle2:
            typography = .subtitle2
        case .body1_regular:
            typography = .body1_regular
        case .body1_bold:
            typography = .body1_bold
        case .body2_regular:
            typography = .body2_regular
        case .body2_bold:
            typography = .body2_bold
        case .body3_regular:
            typography = .body3_regular
        case .body3_bold:
            typography = .body3_bold
        case .caption1_light:
            typography = .caption1_light
        case .caption1_bold:
            typography = .caption1_bold
        case .caption2_light:
            typography = .caption2_light
        case .caption2_bold:
            typography = .caption2_bold
        case .buttonL:
            typography = .buttonL
        case .buttonM:
            typography = .buttonM
        case .buttonS:
            typography = .buttonS
        }
        
        return typography
    }
    
    static var title1: Typography {
        return .init(font: .title1, lineHeight: 0, lineSpacing: nil, letterSpacing: nil)
    }
    
    static var title2: Typography {
        return .init(font: .title2, lineHeight: 0)
    }
    
    static var headline: Typography {
        return .init(font: .headLine, lineHeight: 0)
    }
    
    static var subtitle1: Typography {
        return .init(font: .subtitle1, lineHeight: 0)
    }
    
    static var subtitle2: Typography {
        return .init(font: .subtitle2, lineHeight: 0)
    }
    
    static var body1_regular: Typography {
        return .init(font: .body1_regular, lineHeight: 0)
    }
    
    static var body1_bold: Typography {
        return .init(font: .body1_bold, lineHeight: 0)
    }
    
    static var body2_regular: Typography {
        return .init(font: .body2_regular, lineHeight: 0)
    }
    
    static var body2_bold: Typography {
        return .init(font: .body2_bold, lineHeight: 0)
    }
    
    static var body3_regular: Typography {
        return .init(font: .body3_regular, lineHeight: 0)
    }
    
    static var body3_bold: Typography {
        return .init(font: .body3_bold, lineHeight: 0)
    }
    
    static var caption1_light: Typography {
        return .init(font: .caption1_light, lineHeight: 0)
    }
    
    static var caption1_bold: Typography {
        return .init(font: .caption1_bold, lineHeight: 0)
    }
    
    static var caption2_light: Typography {
        return .init(font: .caption2_light, lineHeight: 0)
    }
    
    static var caption2_bold: Typography {
        return .init(font: .caption2_bold, lineHeight: 0)
    }
    
    static var buttonL: Typography {
        return .init(font: .buttonL, lineHeight: 0)
    }
    
    static var buttonM: Typography {
        return .init(font: .buttonM, lineHeight: 0)
    }
    
    static var buttonS: Typography {
        return .init(font: .buttonS, lineHeight: 0)
    }
}
