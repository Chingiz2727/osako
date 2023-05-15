import SystemConfiguration

public enum NetworkConnectionStatus {
    case notAvailable, availableViaWWAN, availableViaWiFi
    
    static var checkCurrentConnectionStatus: NetworkConnectionStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            })
        }
        
        guard let target = defaultRouteReachability else { return .notAvailable }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(target, &flags) { return .notAvailable }
    
        if !flags.contains(.reachable) { return .notAvailable }
        else if flags.contains(.isWWAN) { return .availableViaWWAN }
        else if !flags.contains(.connectionRequired) { return .availableViaWiFi }
        else if (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) && !flags.contains(.interventionRequired)) {
            return .availableViaWiFi
        }
        else { return .notAvailable }
    }
}
