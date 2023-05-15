import UIKit
import CoreText

enum Font: RawRepresentable {
    
    typealias RawValue = FontInfo
    
    case montserrat
    
    var rawValue: FontInfo {
        switch self {
        case .montserrat:
            return FontInfo.montserrat
        }
    }
    
    init?(rawValue: FontInfo) {
        return nil
    }
}

struct FontInfo: Equatable {
    
    enum Weight: Int {
        case black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight
        case extraLightItalic, italic, light, lightItalic, medium, mediumItalic, regular, semiBold, semiBoldItalic, thin, thinItalic
        
        static func lessThan(_ weight: Self) -> Self? {
            return Self(rawValue: weight.rawValue - 1)
        }
    }
    
    static let montserrat = FontInfo(name: "Montserrat", fileExtension: "ttf", blackName: "Montserrat-Black", blackItalicName: "Montserrat-BlackItalic", boldName: "Montserrat-Bold", boldItalicName: "Montserrat-BoldItalic", extraBoldName: "Montserrat-ExtraBold", extraBoldItalicName: "Montserrat-ExtraBoldItalic", extraLightName: "Montserrat-ExtraLight", extraLightItalicName: "Montserrat-ExtraLightItalic", italicName: "Montserrat-Italic", lightName: "Montserrat-Light", lightItalicName: "Montserrat-LightItalic", mediumName: "Montserrat-Medium", mediumItalicName: "Montserrat-MediumItalic", regularName: "Montserrat-Regular", semiBoldName: "Montserrat-SemiBold", semiBoldItalic: "Montserrat-SemiBoldItalic", thinName: "Montserrat-Thin", thinItalic: "Montserrat-ThinItalic")
    
    let name: String
    private let fileExtension: String
    
    private let blackName: String
    private let blackItalicName: String?
    private let boldName: String?
    private let boldItalicName: String?
    private let extraBoldName: String?
    private let extraBoldItalicName: String?
    private let extraLightName: String?
    private let extraLightItalicName: String?
    private let italicName: String?
    private let lightName: String?
    private let lightItalicName: String?
    private let mediumName: String?
    private let mediumItalicName: String?
    private let regularName: String?
    private let semiBoldName: String?
    private let semiBoldItalic: String?
    private let thinName: String?
    private let thinItalic: String?
    
    
    init(
        name: String,
        fileExtension: String,
        blackName: String,
        blackItalicName: String?,
        boldName: String?,
        boldItalicName: String?,
        extraBoldName: String?,
        extraBoldItalicName: String?,
        extraLightName: String?,
        extraLightItalicName: String?,
        italicName: String?,
        lightName: String?,
        lightItalicName: String?,
        mediumName: String?,
        mediumItalicName: String?,
        regularName: String?,
        semiBoldName: String?,
        semiBoldItalic: String?,
        thinName: String?,
        thinItalic: String?
    ) {
        self.name = name
        self.fileExtension = fileExtension
        self.blackName = blackName
        self.blackItalicName = blackItalicName
        self.boldName = boldName
        self.boldItalicName = boldItalicName
        self.extraBoldName = extraBoldName
        self.extraBoldItalicName = extraBoldItalicName
        self.extraLightName = extraLightName
        self.extraLightItalicName = extraLightItalicName
        self.italicName = italicName
        self.lightName = lightName
        self.lightItalicName = lightItalicName
        self.mediumName = mediumName
        self.mediumItalicName = mediumItalicName
        self.regularName = regularName
        self.semiBoldName = semiBoldName
        self.semiBoldItalic = semiBoldItalic
        self.thinName = thinName
        self.thinItalic = thinItalic
    }
    
    func make(_ size:CGFloat, weight: Weight) -> UIFont {
        let name: String?
        
        switch weight {
        case .black:
            name = blackName
        case .blackItalic:
            name = blackItalicName
        case .bold:
            name = boldName
        case .boldItalic:
            name = boldItalicName
        case .extraBold:
            name = extraBoldName
        case .extraBoldItalic:
            name = extraBoldItalicName
        case .extraLight:
            name = extraLightName
        case .extraLightItalic:
            name = extraLightItalicName
        case .italic:
            name = italicName
        case .light:
            name = lightName
        case .lightItalic:
            name = lightItalicName
        case .medium:
            name = mediumName
        case .mediumItalic:
            name = mediumItalicName
        case .regular:
            name = regularName
        case .semiBold:
            name = semiBoldName
        case .semiBoldItalic:
            name = semiBoldItalic
        case .thin:
            name = thinName
        case .thinItalic:
            name = thinItalic
        }
        
        guard let unwarappedName = name else {
            if let lessWeight = Weight.lessThan(weight) {
                return make(size, weight: lessWeight)
            }
            
            else {
                return font(name: blackName, size: size)
            }
        }
        return font(name: unwarappedName, size: size)
    }
    
    private func font(name: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }
        registerFont(name: name, fileExtension: fileExtension)
        guard let font = UIFont(name: name, size: size) else {
            
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    private func registerFont(name: String, fileExtension: String) {
        guard let url = Bundle.current.url(forResource: name, withExtension: fileExtension) else {
            assertionFailure("No Existing font resource <\(name).\(fileExtension)>.")
            return
        }
        var cfError: Unmanaged<CFError>?
        
        if !CTFontManagerRegisterFontsForURL(url as CFURL, CTFontManagerScope.process, &cfError) {
            if let error = cfError {
                let _error = error.takeUnretainedValue()
                let nsError = NSError(domain: CFErrorGetDomain(_error) as String, code: CFErrorGetCode(_error), userInfo: nil)
                assertionFailure("Failed to register font <\(name)>. Error message: <\(nsError.localizedDescription)>, code:<\(nsError.code)>")
            } else {
                assertionFailure("Failed to register font withot an error description.")
            }
        }
    }
}
