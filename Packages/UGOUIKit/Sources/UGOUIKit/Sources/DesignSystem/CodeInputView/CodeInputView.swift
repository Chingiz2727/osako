import UIKit

public protocol CodeInputViewDelegate: AnyObject {
    func textFieldShouldBeginEditing(_ textField: CodeInputView) -> Bool
    
    func textFieldDidBeginEditing(_ textField: CodeInputView)
    
    func textFieldValueChanged(_ textField: CodeInputView)
    
    func textFieldShouldEndEditing(_ textField: CodeInputView) -> Bool
    
    func textFieldDidEndEditing(_ textField: CodeInputView)
    
    func textFieldShouldReturn(_ textField: CodeInputView) -> Bool
}

public extension CodeInputViewDelegate {
    func textFieldShouldBeginEditing(_ textField: CodeInputView) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: CodeInputView) {
        
    }
    
    func textFieldValueChanged(_ textField: CodeInputView) {
        
    }
    
    func textFieldShouldEndEditing(_ textField: CodeInputView) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: CodeInputView) {
        
    }
    
    func textFieldShouldReturn(_ textField: CodeInputView) -> Bool {
        return true
    }
}

public final class CodeInputView: UIView {
    
    public typealias Delegate = CodeInputViewDelegate
    
    public weak var delegate: Delegate?
    
    @IBInspectable public var itemSpacing: CGFloat = 17.0 {
        didSet {
            if itemSpacing != oldValue {
                updateView()
            }
        }
    }
    
    @IBInspectable public var characterLimit: Int = 6 {
        willSet {
            if characterLimit != newValue {
                updateView()
            }
        }
    }
    
    @IBInspectable public var characterBackgroundColor: UIColor = .white {
        didSet {
            if characterBackgroundColor != oldValue {
                updateView()
            }
        }
    }
    
    @IBInspectable public var characterBackgroundCornerRadius: CGFloat = 10.0 {
        didSet {
            if characterBackgroundCornerRadius != oldValue {
                updateView()
            }
        }
    }
    
    public var keyBoardtype: UIKeyboardType = .numberPad {
        didSet {
            _inputView.keyboardType = keyBoardtype
        }
    }
    
    
    public var keyboardAppearance: UIKeyboardAppearance = .default {
        didSet {
            _inputView.keyboardAppearance = keyboardAppearance
        }
    }
    
    public var textContentType: UITextContentType! = nil {
        didSet {
            _inputView.textContentType = textContentType
        }
    }
    public var font: UIFont =  .title2
    
    public var text: String? {
        get {
            _inputView.text
        } set {
            _inputView.text = newValue
        }
    }
    
    private let _inputView = UITextField()
    private var labels: [UILabel] = []
    private var backgrounds: [UIView] = []
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private var needToRecreateLabel: Bool {
        return characterLimit != labels.count
    }
    
    private var needToRecreateBackground: Bool {
        return characterLimit != backgrounds.count
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCharacterAndPlaceholders()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if bounds.contains(location) {
            if (delegate?.textFieldShouldBeginEditing(self) ?? true) {
                let _ = becomeFirstResponder()
            }
        }
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        delegate?.textFieldDidBeginEditing(self)
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        delegate?.textFieldDidEndEditing(self)
        return super.resignFirstResponder()
    }
    
    private func setupView() {
        addSubview(_inputView)
        updateView()
    }
    
    private func updateView() {
        if needToRecreateBackground {
            recreateBackground()
        }
        if needToRecreateLabel {
            recreateLabels()
        }
        updateLabels(with: text ?? "")
        updateBackground()
        setNeedsLayout()
    }
    
    private func recreateLabels() {
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        
        for _ in 0..<characterLimit {
            let label = createLabel()
            labels.append(label)
            addSubview(label)
        }
    }
    
    private func recreateBackground() {
        backgrounds.forEach { $0.removeFromSuperview() }
        backgrounds.removeAll()
        
        for _ in 0..<characterLimit {
            let background = createBackground()
            backgrounds.append(background)
            addSubview(background)
        }
    }
    
    private func updateLabels(with text: String) {
        var textIndex = text.startIndex
        for label in labels {
            if textIndex < text.endIndex {
                label.text = "\(text[textIndex])"
                label.textColor = .brandGreen
                textIndex = text.index(after: textIndex)
            } else {
                label.textColor = .gray30
                label.text = "*"
            }
        }
    }
    
    private func updateBackground() {
        for background in backgrounds {
            background.backgroundColor = characterBackgroundColor
            background.layer.cornerRadius = characterBackgroundCornerRadius
        }
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect())
        label.font = font
        label.textColor = .brandGreen
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }
    
    private func createBackground() -> UIView {
        let background = UIView()
        background.backgroundColor = characterBackgroundColor
        background.layer.cornerRadius = characterBackgroundCornerRadius
        background.clipsToBounds = true
        return background
    }
    
    private func layoutCharacterAndPlaceholders() {
        let marginsCount = characterLimit - 1
        let totalMarginWidth: CGFloat = itemSpacing * CGFloat(marginsCount)
        let backgroundWidth: CGFloat = (bounds.width - totalMarginWidth) / CGFloat(characterLimit)
        var currentBackgroundX: CGFloat = 0.0
        var currentLabelCenterX = currentBackgroundX + backgroundWidth / 2
        
        for i in 0..<backgrounds.count {
            let background = backgrounds[i]
            background.frame = CGRect(x: currentBackgroundX, y: 0, width: backgroundWidth, height: bounds.height)
            currentBackgroundX = background.frame.maxX + itemSpacing
            
            let label = labels[i]
            label.bounds.size.width = backgroundWidth
            label.bounds.size.height = bounds.height
            label.center = CGPoint(x: currentLabelCenterX, y: bounds.height / 2)
            currentLabelCenterX = currentBackgroundX + backgroundWidth / 2
        }
    }
    
    private func canInsertCharacter(_ character: String) -> Bool {
        let newText: String = text.map { $0 + character } ?? character
        guard !character.hasOnlyNeewLineSymbols else { return false }
        
        let isCharacterMatchingCharacterSet = character.trimmingCharacters(in: .alphanumerics).isEmpty
        guard isCharacterMatchingCharacterSet else { return false }
        let isLenghtWithinLimit = newText.count <= characterLimit
        return isLenghtWithinLimit
    }
}

extension CodeInputView: UIKeyInput {
    public var hasText: Bool {
        if let text = self.text {
            return !text.isEmpty
        } else {
            return false
        }
    }
    
    public func deleteBackward() {
        guard hasText else {
            return
        }
        
        text?.removeLast()
        updateLabels(with: text ?? "")
        delegate?.textFieldValueChanged(self)
    }
    
    public func insertText(_ chartToInsert: String) {
        if chartToInsert.hasOnlyNeewLineSymbols {
            if (delegate?.textFieldShouldReturn(self) ?? true) {
                let _ = resignFirstResponder()
            }
        } else if canInsertCharacter(chartToInsert) {
            let newText = text.map { $0 + chartToInsert } ?? chartToInsert
            text = newText
            updateLabels(with: newText)
            delegate?.textFieldValueChanged(self)
            if newText.count == characterLimit {
                if (delegate?.textFieldShouldEndEditing(self) ?? true) {
                    let _ = resignFirstResponder()
                }
            }
        }
    }
}

fileprivate extension String {
    var hasOnlyNeewLineSymbols: Bool {
        return trimmingCharacters(in: CharacterSet.newlines).isEmpty
    }
}
