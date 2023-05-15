import UIKit

public protocol ReusableCollectionView: AnyObject {
  static func dequeue(from collectionView: UICollectionView, indexPath: IndexPath) -> Self
  static var identifier: String { get }
  static var kind: String { get }
}

extension ReusableCollectionView {
  
  public static var identifier: String {
    return String(describing: self)
  }
  
  public static var kind: String {
    return UICollectionView.elementKindSectionHeader
  }
  
  
  public static func dequeue(from collectionView: UICollectionView, indexPath: IndexPath) -> Self {
    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! Self
  }
}

public protocol RegisterableNibReusableView: ReusableCollectionView {
    static func register(in collectionView: UICollectionView)
}


public protocol RegisterableReusableView: ReusableCollectionView {
    static func register(in collectionView: UICollectionView)
}

extension RegisterableNibReusableView where Self: UICollectionReusableView {
  public static func register(in collectionView: UICollectionView) {
    collectionView.register(UINib.init(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
  }
}

extension RegisterableReusableView where Self: UICollectionReusableView {
  public static func register(in collectionView: UICollectionView) {
    collectionView.register(self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
  }
}

class TitleImageCollectionReusableView: UICollectionReusableView, RegisterableNibReusableView {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
}
