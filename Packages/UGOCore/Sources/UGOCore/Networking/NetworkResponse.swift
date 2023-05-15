import Foundation

public protocol NetworkResponse {
    var isSuccess: Bool { get }
    var data: Data? { get }
    var networkError: NetworkError? { get }
}

extension NetworkResponse {
    
    public var json: [String: Any]? {
        guard let data = data,
              let result = ((try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]) as [String : Any]??)
            else { return nil }
        return result
    }
    
    public var string: String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func decode<T: Decodable>() -> T? {
        guard let data = data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            dump(error)
            return nil
        }
    }
}
