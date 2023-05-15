import UIKit


open class UGOButton: UIButton {
    public typealias Config = UGOButtonConfig
    
    public var config: Config = .alphaMedium {
        didSet {
            guard oldValue != config else {
                return
            }
            configure(config)
            setNeedsDisplay()
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            updateBackground()
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            updateBackground()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        let height: CGFloat = config.size.height
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }
    
    public convenience init(config: Config, frame: CGRect) {
        self.init(type: .custom)
        self.config = config
        self.frame = frame
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layer.cornerRadius = UGOButtonConstants.defaultCornerRadius
    }
    
    open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        let disabledColor = config.priority.titleColor(for: .disabled)
        let normalColor = config.priority.titleColor(for: .normal)
        if let title = title {
            let disabledMutableString = NSMutableAttributedString(attributedString: title)
            let normalMutableString = NSMutableAttributedString(attributedString: title)
            let range = NSMakeRange(0, normalMutableString.length)
            disabledMutableString.addAttribute(.foregroundColor, value: disabledColor, range: range)
            normalMutableString.addAttribute(.foregroundColor, value: normalColor, range: range)
            super.setAttributedTitle(disabledMutableString, for: .disabled)
            super.setAttributedTitle(normalMutableString, for: .normal)
        }
    }
    
    private func setup() {
      titleLabel?.font = UIFont.buttonM
        
        configure(config)
    }
    
    private func configure(_ config: Config) {
        updateBackground()
        setTitleColor(config.priority.titleColor(for: .disabled), for: .disabled)
        setTitleColor(config.priority.titleColor(for: .normal), for: .normal)
        contentEdgeInsets = config.size.contentInsets
        layer.cornerRadius = config.cornerRadius
        invalidateIntrinsicContentSize()
    }
    
    private func updateBackground() {
        if !isEnabled {
            backgroundColor = config.priority.backgroundColor(for: .disabled)
        } else {
            backgroundColor = config.priority.backgroundColor(for: .normal)
        }
    }
}

public struct UGOButtonConfig: Equatable {
    
    public enum Priority: Equatable {
        case alpha, beta, gamma, omega
    }
    
    public enum Size: Equatable {
        case medium, small
    }
    
    public let priority: Priority
    public let size: Size
    public let cornerRadius: CGFloat
    
    public init(priority: Priority, size: Size, cornerRadius: CGFloat) {
        self.priority = priority
        self.size = size
        self.cornerRadius = cornerRadius
    }
}
