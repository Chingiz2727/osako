
import Alamofire
import Foundation
import struct Foundation.TimeInterval

public let sessionManager: AppSessionMananger = {
    func getServerTrustPolicyManager() -> ServerTrustPolicyManager? {
        let serverTrustPolicy = ServerTrustPolicy.pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: false, validateHost: true)
        let policies = ["": serverTrustPolicy]

        let serverTrustPolicyManager = ServerTrustPolicyManager(policies: policies)
        return serverTrustPolicyManager
    }
    var lastResponseDateCount = 0.0
    
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 300
    configuration.timeoutIntervalForResource = 300
    let serverTrustPolicyManager = getServerTrustPolicyManager()
    let sessionManager = AppSessionMananger(configuration: configuration,
                                            serverTrustPolicyManager: serverTrustPolicyManager)

    var timer: DispatchSourceTimer?
    
    sessionManager.delegate.dataTaskDidReceiveResponseWithCompletion = { session, dataTask, response, completion in
        switch (response as? HTTPURLResponse)?.statusCode {
        case 401:
            completion(.cancel)
            return
        case 403:
            completion(.cancel)
            return
        default:
            break
        }
        
        completion(.allow)
    }
    
    return sessionManager
}()

