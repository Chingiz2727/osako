import Alamofire

public protocol CancelableRequest{
    func cancel()
}

extension DataRequest: CancelableRequest {}
