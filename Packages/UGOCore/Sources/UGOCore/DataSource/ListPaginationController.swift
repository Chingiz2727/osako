
import UIKit

public class ListPaginationController<T>: ListDisplayDelegate {
  
  public weak var sectionController: ListSectionController?
  public weak var dataProvider: PaginatedDataProvider<T>?
  private let threshold: Int
  private var itemsCount: Int? {
    return sectionController?.numberOfItems
  }
  
    public var onWillDisplayCell: ((UICollectionViewCell, Int) -> Void)?
  
  public init(threshold: Int, dataProvider: PaginatedDataProvider<T>? = nil) {
    self.threshold = threshold
    self.dataProvider = dataProvider
  }
  
  public func willDisplayCell(_ cell: UICollectionViewCell, at index: Int) {
    onWillDisplayCell?(cell, index)
    
    if let dataProvider = dataProvider {
      loadNextIfNeeded(in: dataProvider, index: index)
    }
  }
  
  public func didEndDisplayCell(_ cell: UICollectionViewCell, at index: Int) {
    // No implementation.
  }
  
  // MARK: - Helpers
  
  private func loadNextIfNeeded(in dataProvider: PaginatedDataProvider<T>, index: Int) {
    guard let itemsCount = itemsCount, dataProvider.hasMoreData, !dataProvider.state.isLoading else { return }
    
    let trigger = index + threshold
    if trigger == itemsCount {
      dataProvider.loadNext()
    }
  }
}
