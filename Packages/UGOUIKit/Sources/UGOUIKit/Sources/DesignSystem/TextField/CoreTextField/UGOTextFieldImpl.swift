import UIKit

public enum UGOTextFieldState: Equatable {
    case enabled
    case disabled
    case error
    case active
    case valid
}

public protocol UGOTextFieldTheme {
    func iconColor(for state: UGOTextFieldState, hasInput: Bool) -> UIColor
    func backgroundColor(for state: UGOTextFieldState) -> UIColor?
    func borderColor(for state: UGOTextFieldState) -> UIColor?
    func titleColor(for state: UGOTextFieldState) -> UIColor
    func valueColor(for state: UGOTextFieldState) -> UIColor?
}

public struct UGOTextFieldImpl: UGOTextFieldTheme {
    public func iconColor(for state: UGOTextFieldState, hasInput: Bool) -> UIColor {
        switch state {
        case .enabled:
            return .gray90
        case .disabled:
            return .gray03
        case .error:
            return .gray90
        case .active:
            return .uiBlue
        case .valid:
            return .gray90
        }
    }
    
    public func backgroundColor(for state: UGOTextFieldState) -> UIColor? {
        switch state {
        case .enabled:
            return .white
        case .disabled:
            return .gray03
        case .error:
            return .white
        case .active:
            return .white
        case .valid:
            return .white
        }
    }
    
    public func borderColor(for state: UGOTextFieldState) -> UIColor? {
        switch state {
        case .enabled:
            return nil
        case .disabled:
            return nil
        case .error:
            return .uiRed
        case .active:
            return .uiBlue
        case .valid:
            return .uiLightGreen
        }
    }
    
    public func titleColor(for state: UGOTextFieldState) -> UIColor {
        return .gray90
    }
    
    public func valueColor(for state: UGOTextFieldState) -> UIColor? {
        return .gray90
    }
}
