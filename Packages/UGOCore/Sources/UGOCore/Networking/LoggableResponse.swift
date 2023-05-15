import Foundation

public protocol LoggableResponse {
    var response: HTTPURLResponse? { get }
    var request: URLRequest? { get }
    var error: Error? { get }
    var data: Data? { get }
}
