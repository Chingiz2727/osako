import UIKit
import SnapKit

public class FavouriteButton: UIButton {
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    private static let notlikeImage = UIImage(named: "heart")
    
    private static let likeImage = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
    
    public var isLiked: Bool = false {
        didSet {
            self.isSelected = isLiked
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public override func layoutSubviews() {
        layer.cornerRadius = 20
    }
    
    @objc private func action(_ sender: UIButton) {
        isLiked.toggle()
    }
    
    private func setupView() {
        setImage(FavouriteButton.notlikeImage, for: .normal)
        setImage(FavouriteButton.likeImage, for: .selected)
        backgroundColor = .white
    }
}
