import UIKit

public final class CheckBox: UIControl {
    
    @IBInspectable
    public var checkBoxSize: CGSize = .init(width: 20, height: 20) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 2 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = .gray30 {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            imageView.tintColor = tintColor
        }
    }

    public override var intrinsicContentSize: CGSize {
        return .init(width: 24, height: 24)
    }
    
    private let imageView = UIImageView()
    
    private func setupView() {
        tintColor = .white
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = .init(named: "check")
    }
}
