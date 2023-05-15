import UIKit

public protocol PlaceCard {
    func configure(with viewModel: PlaceViewModel)
}

public struct PlaceViewModel {
    public let name: String
    public let foodType: String
    public let price: String
    public let ratin: Double
    public let deliveryMinTime: String
    public let delivertMaxTime: String
}

public final class PlaceView: UIView {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let startImageView = UIImageView()
    private let ratingLabel = UILabel()
    private let favouriteButton = FavouriteButton()
    
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startImageView, ratingLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var titlesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.addSubview(favouriteButton)
        addSubview(titlesStackView)
        addSubview(ratingStackView)
        
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(132)
        }
        
        favouriteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(8)
        }
        
        titlesStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(ratingStackView.snp.leading).offset(8)
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
    }
}

extension PlaceView: PlaceCard {
    public func configure(with viewModel: PlaceViewModel) {
        
    }
}
