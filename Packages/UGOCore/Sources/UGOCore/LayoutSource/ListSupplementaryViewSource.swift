import UIKit

/// Encapsulates header/footer logic
public protocol ListSupplementaryViewSource: AnyObject {

  var collection: ListCollectionContainer? { get set }
  
  var supportedElementKinds: [String] { get }
  
  func viewForSupplementaryElement(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
  
  func sizeForSupplementaryView(of kind: String) -> CGSize
  
}

open class BaseListSupplementaryViewSource: NSObject, ListSupplementaryViewSource {
  
  open var supportedElementKinds: [String] { return [] }
    
  public var collection: ListCollectionContainer? {
    didSet {
      if collection != nil, oldValue?.collectionView != collection?.collectionView {
        registerViews()
      }
    }
  }
  
  open func viewForSupplementaryElement(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    fatalError()
  }
  
  open func sizeForSupplementaryView(of kind: String) -> CGSize {
    fatalError()
  }
  
  open func registerViews() {
    
  }
}
