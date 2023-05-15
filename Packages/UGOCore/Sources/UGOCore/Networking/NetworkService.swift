import Foundation
import Alamofire

public protocol NetworkService {
    @discardableResult
    func load(
        context: NetworkContext,
        completion: @escaping (NetworkResponse) -> Void
    ) -> APITask?
    func load(
        context: MultipartFormDataNetworkContext,
        onCompletion pass: @escaping (_ networkResponse: NetworkResponse) -> Void
    )
    func load<T: Decodable>(
        context: NetworkContext,
        completion: @escaping (_ result: Result<T>) -> Void
    )
    
    @discardableResult
    func download(
        context: NetworkContext,
        nameOfFile: String,
        completion: @escaping (NetworkResponse) -> Void
        ) -> CancelableRequest?
}
