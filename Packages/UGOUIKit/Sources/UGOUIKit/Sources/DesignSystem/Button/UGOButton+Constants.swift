import UIKit

enum UGOButtonConstants {
    static var defaultCornerRadius: CGFloat {
        return 16.0
    }
    
    static var smallCornerRadius: CGFloat {
        return 8.0
    }
    static var mediumPadding: UIEdgeInsets {
        return .init(top: 8.0, left: 24.0, bottom: 8.0, right: 24.0)
    }
    
    static var smallPadding: UIEdgeInsets {
        return .init(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
    }
}


extension UGOButtonConstants {
    
    enum Color {
        
        enum Title {
            static var alpha: UIColor {
                return .white
            }
            
            static var alphaDisabled: UIColor {
                return .white
            }
            
            static var beta: UIColor {
                return .white
            }
            
            static var betaDisabled: UIColor {
                return .white
            }
            
            static var gamma: UIColor {
                return .uiBlue
            }
            
            static var gammaDisabled: UIColor {
                return .uiBlue.withAlphaComponent(0.5)
            }
            
            static var omega: UIColor {
                return .gray90
            }
            
            static var omegaDisabled: UIColor {
                return .gray90.withAlphaComponent(0.5)
            }
        }
        
        enum Background {
            static var alpha: UIColor {
                return .brandGreen
            }
            
            static var alphaDisabled: UIColor {
                return .brandGreen.withAlphaComponent(0.5)
            }
            
            static var beta: UIColor {
                return .uiGreen
            }
            
            static var betaDisabled: UIColor {
                return .uiGreen.withAlphaComponent(0.5)
            }
            
            static var gamma: UIColor {
                return .white
            }
            
            static var gammaDisabled: UIColor {
                return .white.withAlphaComponent(0.5)
            }
            
            static var omega: UIColor {
                return .white
            }
            
            static var omegaDisabled: UIColor {
                return .white.withAlphaComponent(0.5)
            }
        }
    }
}

extension UGOButtonConfig.Priority {
    typealias Title = UGOButtonConstants.Color.Title
    
    func titleColor(for state: UIControl.State) -> UIColor {
        switch (self, state) {
        case (.alpha, _):
            return Title.alpha
        case (.alpha, .disabled):
            return Title.alphaDisabled
        case (.beta, _):
            return Title.beta
        case (.beta, .disabled):
            return Title.betaDisabled
        case (.gamma , _):
            return Title.gamma
        case (.gamma, .disabled):
            return Title.gammaDisabled
        case (.omega, _):
            return Title.omega
        case (.omega, .disabled):
            return Title.omegaDisabled
        }
    }
}

extension UGOButtonConfig.Priority {
    typealias Background = UGOButtonConstants.Color.Background
    
    func backgroundColor(for state: UIControl.State) -> UIColor {
        switch (self, state) {
        case (.alpha, .disabled):
            return Background.alphaDisabled
        case (.beta, .disabled):
            return Background.betaDisabled
        case (.gamma, .disabled):
            return Background.gammaDisabled
        case (.omega, .disabled):
            return Background.omegaDisabled
        case (.beta, _):
            return Background.beta
        case (.alpha, _):
            return Background.alpha
        case (.gamma, _):
            return Background.gamma
        case (.omega, _):
            return Background.omega
        }
    }
}

extension UGOButtonConfig.Size {
    var contentInsets: UIEdgeInsets {
        switch self {
        case .medium:
            return UGOButtonConstants.mediumPadding
        case .small:
            return UGOButtonConstants.smallPadding
        }
    }
}

extension UGOButtonConfig.Size {
    var height: CGFloat {
        switch self {
        case .medium:
            return 48.0
        case .small:
            return 32.0
        }
    }
}

extension UGOButtonConfig {
    public static var alphaMedium: UGOButtonConfig {
        return UGOButtonConfig(priority: .alpha, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius)
    }
    
    public static var alphaSmall: UGOButtonConfig {
        return UGOButtonConfig(priority: .alpha, size: .small, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var alphaSquare: UGOButtonConfig {
        return UGOButtonConfig(priority: .alpha, size: .medium, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var alphaCircle: UGOButtonConfig {
        return UGOButtonConfig(priority: .alpha, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius/2)
    }
    
    public static var betaMedium: UGOButtonConfig {
        return UGOButtonConfig(priority: .beta, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius)
    }
    
    public static var betaSmall: UGOButtonConfig {
        return UGOButtonConfig(priority: .beta, size: .small, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var betaSquare: UGOButtonConfig {
        return UGOButtonConfig(priority: .beta, size: .medium, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var betaCircle: UGOButtonConfig {
        return UGOButtonConfig(priority: .beta, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius/2)
    }
    
    public static var gammaMedium: UGOButtonConfig {
        return UGOButtonConfig(priority: .gamma, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius)
    }
    
    public static var gammaSmall: UGOButtonConfig {
        return UGOButtonConfig(priority: .gamma, size: .small, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var gammaSquare: UGOButtonConfig {
        return UGOButtonConfig(priority: .gamma, size: .medium, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var gammaCircle: UGOButtonConfig {
        return UGOButtonConfig(priority: .gamma, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius/2)
    }
    
    public static var omegaMedium: UGOButtonConfig {
        return UGOButtonConfig(priority: .omega, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius)
    }
    
    public static var omageSmall: UGOButtonConfig {
        return UGOButtonConfig(priority: .omega, size: .small, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var omegaSquare: UGOButtonConfig {
        return UGOButtonConfig(priority: .omega, size: .medium, cornerRadius: UGOButtonConstants.smallCornerRadius)
    }
    
    public static var omegaCircle: UGOButtonConfig {
        return UGOButtonConfig(priority: .omega, size: .medium, cornerRadius: UGOButtonConstants.defaultCornerRadius/2)
    }
}
