import Foundation

public class FailureNetworkResponse: NetworkResponse {
    public var isSuccess: Bool { return false }
    public var data: Data? { return nil }
    public var networkError: NetworkError?
    
    init(networkError: NetworkError) {
        self.networkError = networkError
    }
}
