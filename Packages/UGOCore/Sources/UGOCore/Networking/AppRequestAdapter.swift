import Alamofire
import Foundation

public class AppRequestAdapter: RequestAdapter {
    
    public init() {
    }
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        let urlRequest = urlRequest
        
        return urlRequest
    }
}

extension RequestAdapter {
    
    public func closeSession() {
        if let adapter = self as? AppRequestAdapter {
        }
    }
    
}
