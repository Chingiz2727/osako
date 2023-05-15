import Foundation
import Alamofire
import SystemConfiguration

public final class NetworkAdapter: NetworkService {

    public let sessionManager: AppSessionMananger
    
    public init(sessionManager: AppSessionMananger) {
        self.sessionManager = sessionManager
    }
    
    @discardableResult
    public func load(context: NetworkContext, completion: @escaping (NetworkResponse) -> Void) -> APITask? {
        guard NetworkConnectionStatus.checkCurrentConnectionStatus != .notAvailable else {
            completion(FailureNetworkResponse(networkError: .noConnection))
            return nil
        }
        
        let dataRequest: DataRequest
        if context.httpBody != nil {
            guard let urlRequest = urlRequestFrom(networkContext: context)
                else { completion(FailureNetworkResponse(networkError: .unknown)); return nil }
            dataRequest = sessionManager.request(urlRequest)
        } else {
            dataRequest = dataRequestFrom(networkContext: context)
        }
    
        return dataRequest.validate().responseData { [weak self] serverResponse in
            guard self != nil else { return  }
            
            log(serverResponse: serverResponse)
            
            guard serverResponse.response != nil else {
                completion(FailureNetworkResponse(networkError: .unknown))
                return
            }
            
            completion(serverResponse)
        }
    }
    
    public func load(
        context: MultipartFormDataNetworkContext,
        onCompletion pass: @escaping (_ networkResponse: NetworkResponse) -> Void
    ) {
        guard NetworkConnectionStatus.checkCurrentConnectionStatus != .notAvailable else {
            pass(FailureNetworkResponse(networkError: .noConnection))
            return
        }
        
        sessionManager.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in context.parameters {
                    if let value = value as? CustomStringConvertible,
                        let data = value.description.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
                
                context.paramsArray.forEach { multipartFormDataParams in
                    multipartFormData.append(
                        multipartFormDataParams.fileURL,
                        withName: multipartFormDataParams.name,
                        fileName: multipartFormDataParams.fileName,
                        mimeType: multipartFormDataParams.mimeType
                    )
                }
        },
            to: context.urlString,
            method: convertHttpMethod(from: context.method),
            headers: context.header,
            encodingCompletion: { [weak self] result in
                switch result {
                case .success(let request, _, _):
                    request.validate().responseData { [weak self] dataResponse in
                        guard self != nil else { return }
                        log(serverResponse: dataResponse)
                        pass(dataResponse)
                    }
                case .failure(let error):
                    let networkError = NetworkError.serverError(description: error.localizedDescription)
                    pass(FailureNetworkResponse(networkError: networkError))
                }
            }
        )
    }
    
    private func urlRequestFrom(networkContext context: NetworkContext) -> URLRequest? {
        guard var urlRequest = try? URLRequest(
            url: context.urlString,
            method: convertHttpMethod(from: context.method)
        ) else {
            return nil
        }
        urlRequest.httpBody = context.httpBody
//        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        context.header.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        return urlRequest
    }
    
    private func dataRequestFrom(networkContext context: NetworkContext) -> DataRequest {
        return sessionManager.request(
            context.urlString,
            method: convertHttpMethod(from: context.method),
            parameters: context.parameters,
            encoding: convertEncoding(from: context.encoding),
            headers: context.header
        )
    }
    
    private func convertHttpMethod(from networkMethod: NetworkMethod) -> HTTPMethod {
        switch networkMethod {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
    
    private func convertEncoding(from networkEncoding: NetworkEncoding) -> ParameterEncoding {
        switch networkEncoding {
        case .json: return JSONEncoding.default
        case .url: return URLEncoding.default
        case .urlStringEncoding: return URLEncoding.queryString
        case .urlString: return URLEncoding(destination: .queryString)
        }
    }
    
    public func load<T>(context: NetworkContext, completion: @escaping (Result<T>) -> Void) where T : Decodable {
        fatalError("Not realized!")
    }
    
    @discardableResult
    public func download(context: NetworkContext, nameOfFile: String, completion: @escaping (NetworkResponse) -> Void) -> CancelableRequest? {
        guard NetworkConnectionStatus.checkCurrentConnectionStatus != .notAvailable else {
            completion(FailureNetworkResponse(networkError: .noConnection))
            return nil
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(nameOfFile)
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let request = sessionManager.download(
            context.urlString,
            method: convertHttpMethod(from: context.method),
            parameters: context.parameters,
            encoding: convertEncoding(from: context.encoding),
            headers: context.header,
            to: destination
        )
        
        request.validate().responseData { [weak self] downloadResponse in
            guard let networkAdapter = self else { return }
            networkAdapter.serverLog(serverResponse: downloadResponse)
            guard downloadResponse.response != nil else {
                if let error = downloadResponse.error, (error as NSError).code == -999 {
                    completion(FailureNetworkResponse(networkError: .cancelled))
                } else {
                    completion(FailureNetworkResponse(networkError: .unknown))
                }
                return
            }
            
            completion(downloadResponse)
        }
        
        return getIdentifiedRequest(from: request)
    }
    
    private func getIdentifiedRequest(from request: Request) -> IdentifiedRequest {
        let uuid = UUID()
        let identifiedRequest = IdentifiedRequest(identifier: uuid, request: request)
        return identifiedRequest
    }

    public func serverLog(serverResponse: LoggableResponse) {
        let emoji: String
        let statusCode = serverResponse.response?.statusCode
        if let statusCode = statusCode, 200..<300 ~= statusCode {
            emoji = "✅"
        } else {
            emoji = "⚠️"
        }
        
        print("\n======== REQUEST BEGIN " + emoji + " ========")
        if let request = serverResponse.request {
            if let method = request.httpMethod,
                let url = request.url {
                print("URL:")
                print(method + " " + url.absoluteString)
            }
            if let headerFields = serverResponse.response?.allHeaderFields,
                let data = try? JSONSerialization.data(withJSONObject: headerFields, options: [.prettyPrinted]),
                let string = String(data: data, encoding: .utf8) {
                print("HEADERS:")
                print(string)
            }
            if let string = request.httpBody?.jsonString {
                print("REQUEST BODY:")
                print(string)
            }
        }
        if let string = serverResponse.data?.jsonString {
            print("RESPONSE BODY:")
            print(string)
        }
        if let statusCode = statusCode {
            print("STATUS CODE: " + statusCode.description)
        }
        if let error = serverResponse.error {
            print("ERROR:")
            print(error.localizedDescription)
        }
        print("======== REQUEST END " + emoji + " ========\n")
    }
}

extension DataResponse: NetworkResponse {
    public var isSuccess: Bool {
        return result.isSuccess
    }
    
    public var networkError: NetworkError? {
        guard let error = error, let alamofireError = error as? AFError else {
            return nil
        }
        
        if alamofireError.responseCode == 401 {
            return .locked
        } else if alamofireError.responseCode == 500 {
            return .unauthorized
        }
        
        let description = json?["error_description"] as? String
            ?? json?["value"] as? String
            ?? json?["errorMessage"] as? String
            ?? json?["description"] as? String
        
        if description == "User locked" {
            return .locked
        }
        
        return .serverError(description: description ?? alamofireError.localizedDescription)
    }
}

extension DownloadResponse: NetworkResponse {
    public var data: Data? {
        return nil
    }
    
    public var isSuccess: Bool {
        return result.isSuccess
    }
    
    public var networkError: NetworkError? {
        guard let error = error, let alamofireError = error as? AFError else {
            return nil
        }
        
        if alamofireError.responseCode == 401 {
            return .unauthorized
        }
        
        let description = json?["description"] as? String ?? json?["value"] as? String
        return .serverError(description: description ?? alamofireError.localizedDescription)
    }
}

extension DataResponse: LoggableResponse { }

extension DownloadResponse: LoggableResponse { }
