import Foundation

public protocol NetworkContext {
    var route: Route { get }
    var method: NetworkMethod { get }
    var parameters: [String: Any] { get }
    var encoding: NetworkEncoding { get }
    var httpBody: Data? { get }
    var header: [String: String] { get }
}

extension NetworkContext {
    
    public var urlString: String { return route.urlString }
    
    public var parameters: [String: Any] { return [:] }
    
    public var encoding: NetworkEncoding { return .url }
    
    public static func encode<T: Codable>(_ object: T) -> Any? {
        if let data = try? JSONEncoder().encode(object) {
            return try? JSONSerialization.jsonObject(with: data)
        }
        return nil
    }
    
    public var httpBody: Data? { return nil }
    
    public var header: [String: String] { return [:] }
}
