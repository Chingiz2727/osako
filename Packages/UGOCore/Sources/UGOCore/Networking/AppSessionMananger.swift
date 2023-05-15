import Foundation
import Alamofire

public class AppSessionMananger: SessionManager {
    public func downloadBase64File(
        with url: URLConvertible,
        method: HTTPMethod = .get,
        fileName: String,
        onCompletion pass: @escaping (LoadingResult<URL>) -> Void
    ) {
        request(url, method: method).responseString { [weak self] response in
            guard let self = self else { return }
            guard response.isSuccess else {
                pass(.error(response.networkError ?? .unknown))
                return
            }
            
            guard let value = response.value else {
                pass(.error(NetworkError.dataLoad))
                return
            }
            
            guard let data = Data(base64Encoded: value, options: .ignoreUnknownCharacters) else {
                pass(.error(NetworkError.dataLoad))
                return
            }
            
            guard let url = self.saveFile(from: data, with: fileName) else {
                pass(.error(NetworkError.dataLoad))
                return
            }
            
            pass(.success(url))
        }
    }
    
    private func saveFile(from data: Data, with fileName: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(fileName) else { return nil }
        
        do {
            try data.write(to: documentsURL)
            return documentsURL
        } catch {
            return nil
        }
    }
}
