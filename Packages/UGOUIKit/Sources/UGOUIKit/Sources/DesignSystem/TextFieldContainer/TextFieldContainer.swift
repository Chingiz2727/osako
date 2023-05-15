import UIKit

public class TextFieldContainer<TextField: UGOTextField>: UIView {
    
    public let textField = TextField()
    
    public var error: String? {
        didSet {
            errorLabel.text = error
        }
    }
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .body2_regular
        label.textColor = .gray75
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .body2_regular
        label.textColor = .uiRed
        return label
    }()
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 48 + 8)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, textField, errorLabel])
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
    }
    
}
