import UIKit

public protocol ListContainer {
  var frame: CGRect { get }
  var contentInset: UIEdgeInsets { get }
}

extension UICollectionView: ListContainer {}

/// Abstraction over UICollectionView
///
/// Contains contextual information for each section like section number, section inset, parent
/// view controller etc.
public struct ListCollectionContainer: ListContainer {
  
  /// Section number
  public var section: Int
  
  /// Collection view frame
  public var frame: CGRect {
    return collectionView?.frame ?? .zero
  }
  
  /// Insets of a section
  public var contentInset: UIEdgeInsets {
    return collectionView?.contentInset ?? .zero
  }
  
  /// Parent view controller
  public weak var viewController: UIViewController?
  
  /// The collection view itself.
  public weak var collectionView: UICollectionView!
  
  public var reloadBlock: ((_ reloadInfo: BatchReloadInfo.Changes?, _ dataUpdateBlock: @escaping VoidBlock, _ completion: BoolBlock?) -> Void)?
  
  public init(section: Int, collectionView: UICollectionView? = nil, viewController: UIViewController? = nil) {
    self.section = section
    self.collectionView = collectionView
    self.viewController = viewController
  }
  
  public func reload(reloadInfo: BatchReloadInfo.Changes?, dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock?) {
    reloadBlock?(reloadInfo, dataUpdateBlock, completion)
  }
}

// MARK: - Convenience
extension ListCollectionContainer {
  
  
  public func dequeueCell<T: CellType & UICollectionViewCell>(cellType: T.Type, index: Int) -> T {
    return cellType.dequeue(from: collectionView, indexPath: IndexPath(row: index, section: section))
  }
  
  public func dequeueSupplementaryView<T: RegisterableReusableView & UICollectionReusableView>(viewType: T.Type, index: Int) -> T {
    return viewType.dequeue(from: collectionView, indexPath: IndexPath(row: index, section: section))
  }
}
