import InputMask
import UIKit

private enum Constant {
    static let textMask = "[A] [000] [AA] [000]"
}
public class CarNumberTextField: UGOTextField {
    private let listener = MaskedTextFieldDelegate(primaryFormat: Constant.textMask)
    
    public var isFullFilled: ((Bool) -> Void)?
    
    public var regionNumber: String {
        guard let text = text else { return "" }
        let textValue = CaretString(string: text, caretPosition: text.endIndex, caretGravity: .forward(autocomplete: false))
        let extractedValue = listener.primaryMask.apply(toText: textValue).extractedValue
        return String(extractedValue.suffix(3))
    }
    
    public var carNumber: String {
        guard let text = text else { return "" }
        return String(text.dropLast(4))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = listener
        autocapitalizationType = .allCharacters
        listener.onMaskedTextChangedCallback = { [weak self] textField, text, isFilled in
            self?.isFullFilled?((isFilled && text.onlyCyrillic) == true)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
   var onlyCyrillic: Bool {
       let latinCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
       
       for scalar in unicodeScalars {
           if latinCharacterSet.contains(scalar) {
               return false
           }
       }
       
       return true
   }
}
