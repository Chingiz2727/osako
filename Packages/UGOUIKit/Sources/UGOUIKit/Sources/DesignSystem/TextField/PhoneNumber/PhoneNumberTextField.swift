import InputMask
import UIKit

private enum Constant {
    static let textMask = "+7 [000] [000]-[00]-[00]"
    static let prefix = "+7"
}
public class PhoneNumberTextField: UGOTextField {
    
    private let listener = MaskedTextFieldDelegate(primaryFormat: Constant.textMask)
    
    public var phoneNumber: String {
        guard let text = text else { return "" }
        let textValue = CaretString(string: text, caretPosition: text.endIndex, caretGravity: .forward(autocomplete: false))
        let extractedValue = listener.primaryMask.apply(toText: textValue).extractedValue
        return extractedValue
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = listener
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
