import Foundation

public enum DataProviderExtraInfo {
  case searchTerm(String)
  
  public static let searchTermKey = "searchTerm"
  
}

public struct PaginatedDataProviderState<Item> {
  
  public var loadingState: DataSourceStatus
  
  public var items: [Item]
  
  public var offset: Int
  
  public var error: Error? {
    get {
      if loadingState == DataSourceStatus.error {
        return _error
      } else {
        /// Ignore underlying error if the state is fixed.
        return nil
      }
    }
    set {
      _error = newValue
    }
  }
  public var source: APIResponseSource?
  
  /// Any other associated data
  public var userInfo: [String: DataProviderExtraInfo] = [:]
  
  public var isLoading: Bool {
    return loadingState == .loading
  }
  
  private var _error: Error? = nil
  
  public init(loadingState: DataSourceStatus, items: [Item], offset: Int, userInfo: [String: DataProviderExtraInfo] = [:]) {
    self.loadingState = loadingState
    self.items = items
    self.offset = offset
  }
  
  /// Calls `.append` method on a copied from self instance
  public func appending(_ items: [Item], limit: Int) -> Self {
    var newState = self
    newState.append(items, limit: limit)
    return newState
  }
  
  /// Appends new items and keeps `loadingState` value valid.
  mutating func append(_ items: [Item], limit: Int) {
    let loadingState: DataSourceStatus
    if items.count < limit {
      if items.isEmpty && self.items.isEmpty {
        loadingState = .empty
      } else {
        loadingState = .loadedAll
      }
    } else {
      loadingState = .ready
    }
    let newState = PaginatedDataProviderState(loadingState: loadingState, items: self.items + items, offset: self.offset + limit, userInfo: userInfo)
    self = newState
  }
  
  /// Replaces items in range [offset..<offset+limit] with the new array
  public mutating func updateItems(_ items: [Item], limit: Int, offset: Int) {
    var loadingState = self.loadingState
    if !items.isEmpty {
      if items.count < limit {
        loadingState = .loadedAll
      } else {
        loadingState = .ready
      }
      if loadingState == .empty {
        
      }
    } else if items.isEmpty {
      loadingState = .empty
    }
    
    let previousItems: [Item]
    if offset > self.offset {
      previousItems = Array(self.items.prefix(offset - self.offset))
    } else {
      previousItems = []
    }
    let newState = PaginatedDataProviderState(loadingState: loadingState, items: previousItems + items, offset: offset, userInfo: userInfo)
    self = newState
  }
}

// MARK: - Convenience
extension PaginatedDataProviderState {
  var searchTerm: String? {
    let value = userInfo[DataProviderExtraInfo.searchTermKey]
    switch value {
    case .searchTerm(let searchTerm):
      return searchTerm
    default:
      return nil
    }
    
  }
}
