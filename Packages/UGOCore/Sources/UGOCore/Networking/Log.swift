import Foundation
import Alamofire

public func log<T>(serverResponse: DataResponse<T>) {
    serverRequest(request: serverResponse.request)
    serverResponseBody(data: serverResponse.data)
    serverResponseStatusCode(response: serverResponse.response)
    serverResponseError(error: serverResponse.error)
}

func defaultLog(defaultResponse: DefaultDataResponse) {
    serverRequest(request: defaultResponse.request)
    serverResponseBody(data: defaultResponse.data)
    serverResponseStatusCode(response: defaultResponse.response)
    serverResponseError(error: defaultResponse.error)
}

fileprivate func serverRequest(request: URLRequest?) {
    print("=======REQUEST========")
    if let url = request?.url {
        print("URL:")
        print(url)
    }
    if let data = request?.httpBody,
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        print("REQUEST BODY:")
        print(string)
    }
    if let header = request?.allHTTPHeaderFields {
        print("HEADER:")
        print(header)
    }
}

fileprivate func serverResponseBody(data: Data?) {
    if let data = data,
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        print("RESPONSE BODY:")
        print(string)
    }
}

fileprivate func serverResponseStatusCode(response: HTTPURLResponse?) {
    print("Status code is \(String(describing: response?.statusCode))")
    if let response = response {
        print("RESPONSE STATUS CODE: \(response.statusCode)")
    }
}

fileprivate func serverResponseError(error: Error?) {
    if let error = error {
        print("ERROR:")
        print(error.localizedDescription)
    }
    print("=======REQUEST END========")
}
