import UIKit

public final class HorizontalPicksLayoutSource: BaseListLayoutSource {
    
    public enum Kind {
        case gigant
        case veryBig
        case big
        case medium
        case small
    }
    
    var cellHeight: CGFloat {
        switch kind {
        case .gigant: return 500
        case .veryBig: return 350
        case .big: return 220
        case .medium: return 120
        case .small: return 115
        }
    }
    let kind: Kind
    
    
    public init(kind: Kind) {
        self.kind = kind
        super.init()
        self.inset = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
    
    public override func itemSize(at indexPath: IndexPath) -> CGSize {
        let availableWidth = max(container.frame.width - inset.left - inset.right, 0.0)
        return CGSize(width: availableWidth, height: cellHeight)
    }
}

