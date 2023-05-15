import UIKit
import UGOCore
public final class StoriesCollectionCell: UICollectionViewCell, RegisterableCell, StoriesCard {
    
    private let view = StoriesView()
    
    public static func preferredSize() -> CGSize {
        return StoriesView.preferredSize()
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
        contentView.layer.cornerRadius = 8.0
    }
    
    private func setupView() {
        contentView.addSubview(view)
        view.frame = contentView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public func configure(with viewModel: StoriesViewModel) {
        view.configure(with: viewModel)
    }
}
