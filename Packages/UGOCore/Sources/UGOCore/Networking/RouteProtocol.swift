import Foundation

/// URL route protocol;
/// For **enum** extension with raw type **String**
public protocol RouteProtocol {
    
    /// Server URL
    var serverUrl: String { get }
    
    /// route API
    var rawValue: String { get }
}

public extension RouteProtocol {
    
    /// Get complete URL route
    var urlString: String { return serverUrl + rawValue }
}
