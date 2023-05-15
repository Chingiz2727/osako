public enum DataSourceStatus {
  case loadedAll
  case loading
  case empty
  case notReady
  case ready
  case error
  
  public var isLoaded: Bool {
    return self == .loadedAll || self == .empty || self == .ready || self == .error
  }
  
  public var isLoadedWithoutErrors: Bool {
    return self == .loadedAll || self == .empty || self == .ready
  }
}
