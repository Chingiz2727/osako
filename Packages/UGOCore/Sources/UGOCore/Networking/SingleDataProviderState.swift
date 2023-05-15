import Foundation
 
struct SingleDataProviderState<Item> {
  var loadingState: DataSourceStatus
  var item: Item?
  var error: Error? {
    get {
      if loadingState == DataSourceStatus.error {
        return _error
      } else {
        return nil
      }
    }
    set {
      _error = newValue
    }
  }
  var source: APIResponseSource?
  
  private var _error: Error? = nil
  
  init(loadingState: DataSourceStatus = .loading, item: Item? = nil) {
    self.loadingState = loadingState
    self.item = item
  }
  
  mutating func setResult(item: Item?, error: Error?) {
    self._error = error
    self.item = item
    if item != nil {
      self.loadingState = .loadedAll
    } else if error != nil {
      self.loadingState = .error
    } else {
      self.loadingState = .empty
    }
  }
  
  var isLoading: Bool {
    return loadingState == .loading
  }
}
