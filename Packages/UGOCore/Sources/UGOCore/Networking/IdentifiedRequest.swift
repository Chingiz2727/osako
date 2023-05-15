import Foundation
import Alamofire

public class IdentifiedRequest: CancelableRequest {
    public let identifier: UUID
    public let request: Request
    
    public init(identifier: UUID, request: Request) {
        self.identifier = identifier
        self.request = request
    }
    
   public func cancel() {
        request.cancel()
    }
}
