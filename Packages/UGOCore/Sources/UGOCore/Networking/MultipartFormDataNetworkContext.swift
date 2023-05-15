import Foundation

public typealias MultipartFormDataParams = (fileURL: URL, name: String, fileName: String, mimeType: String)

public protocol MultipartFormDataNetworkContext: NetworkContext {
    var paramsArray: [MultipartFormDataParams] { get }
    init(paramsArray: [MultipartFormDataParams])
}
