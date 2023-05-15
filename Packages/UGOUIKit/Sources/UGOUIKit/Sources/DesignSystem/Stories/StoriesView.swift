import UIKit
import SnapKit


public protocol StoriesCard: AnyObject {
    func configure(with viewModel: StoriesViewModel)
}

public struct StoriesViewModel {
    public let image: String
    public let title: String
    public let description: String
}

public class StoriesView: UIView, StoriesCard {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let descriptionBackgroundView = UIView()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        return stackView
    }()
    
    public static func preferredSize() -> CGSize {
        return CGSize(width: 351, height: 160)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialLayout()
        configureView()
    }

    private func setupInitialLayout() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.addSubview(descriptionBackgroundView)
        
        descriptionBackgroundView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        descriptionBackgroundView.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    private func configureView() {
        titleLabel.textColor = .white
        titleLabel.font = .body1_bold
        titleLabel.textAlignment = .left
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = .caption2_light
        descriptionLabel.textAlignment = .left
    }
    
    public func configure(with viewModel: StoriesViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        guard let url = URL(string: viewModel.image) else { return }
        setImage(with: url, in: imageView)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
