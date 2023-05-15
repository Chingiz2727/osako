import UIKit

public protocol ListLayoutSource {
  
  var container: ListContainer { get set }
  
  func itemSize(at indexPath: IndexPath) -> CGSize
  
  var inset: UIEdgeInsets { get }
  
  var minimumLineSpacing: CGFloat { get }
  
  var minimumInteritemSpacing: CGFloat { get }
  
}

open class BaseListLayoutSource: ListLayoutSource {
    
    open var container: ListContainer = ListCollectionContainer(section: 0)
    
    open func itemSize(at indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    open var inset: UIEdgeInsets = .zero
    
    open var minimumLineSpacing: CGFloat = 0
    
    open var minimumInteritemSpacing: CGFloat = 0
    
    public init() {
        
    }
}
