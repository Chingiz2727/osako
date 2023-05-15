import UIKit

public struct UGOTextFieldConfig {
    
    public let textTypography: Typography
    public let titleTypography: Typography
    public let placeholderTypography: Typography
    public let titleFadeInDuration: TimeInterval
    public let titleFadeOutDuration: TimeInterval
    
    static var `default`: UGOTextFieldConfig {
        return .init(
            textTypography: .of(.body1_regular, isSingleLine: true),
            titleTypography: .of(.body1_regular, isSingleLine: true),
            placeholderTypography: .of(.body1_regular, isSingleLine: true),
            titleFadeInDuration: 0.3,
            titleFadeOutDuration: 0.2)
    }
}

open class UGOTextField: UITextField {
    
    private enum Constans {
        static var editingInsets: UIEdgeInsets {
            return .init(top: 12, left: 16, bottom: 12, right: 16)
        }
        
        static var editingInsetWithIcon: UIEdgeInsets {
            return .init(top: 12, left: 16, bottom: 12, right: 56)
        }
        
        static var activeBorderWidth: CGFloat {
            return 1.0
        }
        
        static var borderWidth: CGFloat {
            return 1.0
        }
        
        static var cornerRadius: CGFloat {
            return 8.0
        }
        
        static var rightViewRightPadding: CGFloat {
            return 16.0
        }
        
        static var intrinsicHeight: CGFloat {
            return 48.0
        }
    }
    
    public typealias State = UGOTextFieldState
    public typealias Theme = UGOTextFieldTheme
    public typealias Config = UGOTextFieldConfig
        
    @IBInspectable
    public var disableErrorOnTyping: Bool = true
    
    @IBInspectable
    public var rightViewSize: CGSize = .init(width: 20, height: 20)
    
    @IBInspectable
    public var editingInsets: UIEdgeInsets = Constans.editingInsets
    
    @IBInspectable
    public var visibleTitleOffset: UIOffset = .init(horizontal: 16.0, vertical: 8.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var notVisibleTitleOffset: UIOffset = .init(horizontal: 16.0, vertical: 14.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var isFailed: Bool {
        get {
            return activeState == .error
        }
        set {
            let oldFailedNewNotFailed = activeState == .error && newValue == false
            let oldNotFailedNewFailed = activeState != .error && newValue == true
            
            guard oldNotFailedNewFailed || oldFailedNewNotFailed else {
                return
            }
            
            if !isEnabled {
                defer { ignoreStateUpdate = false }
                ignoreStateUpdate = true
                isEnabled = true
            }
            
            if newValue {
                activeState = .error
            }
            
            else {
                activeState = .enabled
            }
        }
    }
    
    public override var clearButtonMode: UITextField.ViewMode {
        set {
            assertionFailure("Not supported in UGOTEXTFIELD")
        }
        get {
            return .never
        }
    }
    
    public override var placeholder: String? {
        get {
            return super.placeholder
        }
        
        set {
            if let newValue = newValue {
                super.attributedPlaceholder = makeAttributedPlaceholder(newValue)
            } else {
                super.attributedPlaceholder = nil
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Constans.intrinsicHeight)
    }
    
    public override var isSelected: Bool {
        didSet {
            let oldSelectedNowSelected = activeState == .active && isSelected == false
            let oldNotSelectedNewSelected = activeState != .active && isSelected == true
            guard oldSelectedNowSelected || oldNotSelectedNewSelected else {
                return
            }
            if isSelected {
                activeState = .active
            } else {
                activeState = .enabled
            }
        }
    }
//
//    public var title: String? {
//        get {
//            return titleLabel.text
//        } set {
//            setNeedsLayout()
//            titleLabel.attributedText = NSAttributedString(string: newValue, typography: config.titleTypography)
//        }
//    }
//
    public override var isEnabled: Bool {
        didSet {
            let oldEnabledNewNotEnabled = activeState != .disabled && isEnabled == false
            let oldNotEnabledNowEnabled = activeState != .active && isEnabled == false
            guard oldEnabledNewNotEnabled || oldNotEnabledNowEnabled else {
                return
            }
            
            if isEnabled {
                activeState = .enabled
            } else {
                activeState = .disabled
            }
        }
    }
    
    public override var text: String? {
        didSet {
            updateControl(false)
        }
    }
    
    private(set) public var activeState: UGOTextFieldState = .enabled {
        didSet {
            if activeState != oldValue {
                stateUpdate(oldValue: oldValue, newValue: activeState)
            }
        }
    }
    
    private var rightButtonAction: (() -> ())?
    
    private var ignoreStateUpdate = false
    
    private var _placeholder: String?
    
    private var theme: Theme
    
    private var config: Config
    
    
    private var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }
    
    private var isTitleVisible: Bool {
        return hasText || editingOrSelected
    }
    
    public override init(frame: CGRect) {
        self.theme = UGOTextFieldImpl()
        self.config = .default
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        self.theme = UGOTextFieldImpl()
        self.config = .default
        super.init(coder: coder)
        setupView()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = theme.borderColor(for: activeState)?.resolvedColor(with: traitCollection).cgColor
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        if let placeholder = placeholder {
            _placeholder = placeholder
        }
        let result = super.becomeFirstResponder()
        updateControl(true)
        return result
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        if let placeholder = placeholder {
            _placeholder = placeholder
        }
        let result = super.becomeFirstResponder()
        updateControl(true)
        return result
    }
    
    public func addIconView(_ image: UIImage) {
        editingInsets = Constans.editingInsetWithIcon
        let view = UIImageView(image: image)
        rightViewMode = .always
        rightView = view
        setNeedsLayout()
    }
    
    public func addButtonView(_ image: UIImage, action: @escaping ()->()) {
        rightButtonAction = action
        editingInsets = Constans.editingInsets
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchDown)
        view.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        rightViewMode = .always
        rightView = view
        setNeedsLayout()
    }
    
    @objc private func rightButtonAction(_ sender: UIButton) {
        rightButtonAction?()
    }
    
    private func setupView() {
        borderStyle = .none
        addEditingChangedObserver()
        updateColors()
        layer.borderWidth = Constans.borderWidth
        layer.cornerRadius = Constans.cornerRadius

        var defaultTextAttributes = config.textTypography.asAttributes
        let textParagraph = (defaultTextAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        textParagraph.lineBreakMode = .byTruncatingTail
        defaultTextAttributes[.paragraphStyle] = textParagraph
        self.defaultTextAttributes = defaultTextAttributes
        tintColor = theme.titleColor(for: activeState)
    }
    
    private func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc private func editingChanged() {
        if disableErrorOnTyping, isFailed {
            activeState = .enabled
        }
        updateControl(true)
    }
    
    private func updateControl(_ animated: Bool = false) {
        updateColors()
        updateTitleLabel(animated)
    }
    
    private func updateTitleLabel(_ animated: Bool = false) {
        if isTitleVisible {
            placeholder = nil
        } else if let _placeholder = _placeholder {
            placeholder = _placeholder
        }
        
//        updateTitleVisibility(animated, completion: nil)
    }
    
    private func stateUpdate(oldValue: State, newValue: State) {
        assert(Thread.isMainThread)
        switch newValue {
        case .active:
            layer.borderWidth = Constans.activeBorderWidth
        default:
            layer.borderWidth = Constans.borderWidth
        }
        updateColors()
    }
    
    private func updateColors() {
        updateMainColors()
        updateBorderColor()
        updateTextColor()
        updatePlaceholderColor()
    }
    
//    private func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
//        let alpha: CGFloat = isTitleVisible ? 1.0 : 0.0
//        let frame: CGRect = titleRectForBounds(bounds, isTitleVisible: isTitleVisible)
//        let updateBlock = { () -> Void in
//            self.titleLabel.alpha = alpha
//            self.titleLabel.frame = frame
//        }
//
//        if animated {
//            let animationOptions: UIView.AnimationOptions = .curveEaseOut
//            let duration = alpha == 1.0 ? config.titleFadeInDuration : config.titleFadeOutDuration
//
//            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
//                updateBlock()
//            }, completion: completion)
//        } else {
//            updateBlock()
//            completion?(true)
//        }
//    }
    
    private func updateMainColors() {
        backgroundColor = theme.backgroundColor(for: activeState)
        rightView?.tintColor = theme.iconColor(for: activeState, hasInput: hasText)
    }
    
    private func updateBorderColor() {
        layer.borderColor = theme.borderColor(for: activeState)?.resolvedColor(with: traitCollection).cgColor
    }
    
    private func updatePlaceholderColor() {
        guard let placeholder = placeholder else {
            return
        }
        let attributedPlaceholder = makeAttributedPlaceholder(placeholder)
        super.attributedPlaceholder = attributedPlaceholder
    }
    
    private func updateTextColor() {
        tintColor = theme.titleColor(for: activeState)
        textColor = theme.valueColor(for: activeState)
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: editingInsets)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: editingInsets)
    }
    

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = rightViewSize
        let originY = (bounds.height - size.height) / 2.0
        let originX = bounds.width - Constans.rightViewRightPadding - size.width
        return .init(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    public func textHeight() -> CGFloat {
        guard let font = font else {
            return 24.0
        }
        return font.lineHeight + 8.0
    }
    
    private func makeAttributedPlaceholder(_ string: String) -> NSAttributedString {
        let attributedPlaceholder = NSMutableAttributedString(string: string, typography: config.placeholderTypography)
        let range = NSRange(location: 0, length: attributedPlaceholder.mutableString.length)
        attributedPlaceholder.addAttributes([.foregroundColor: theme.titleColor(for: activeState)], range: range)
        return attributedPlaceholder
    }
    
//    private func titleRectForBounds(_ bounds: CGRect, isTitleVisible: Bool) -> CGRect {
//        let originY: CGFloat
//        if isTitleVisible {
//            originY = visibleTitleOffset.vertical
//        } else {
//            originY = notVisibleTitleOffset.vertical
//        }
//        let originX: CGFloat = visibleTitleOffset.horizontal
//        return CGRect(
//            x: originX, y: originY, width: bounds.width - originX - editingInsets.right,
//            height: titleLabel.intrinsicContentSize.height)
//    }
}
