import Foundation
import Alamofire

public protocol APITask {
  func cancel()
}

extension URLSessionDataTask: APITask { }


public protocol BaseAPIClient {
  func clearCache()
}

extension DataRequest: APITask { }

/// Use own type of caching to be independent from AWS amplify
public enum APICachePolicy {
  case returnCacheDataElseFetch
  case fetchIgnoringCacheData
  case returnCacheDataDontFetch
  case returnCacheDataAndFetch
  
  /// Helper to configure cache policy for different offsets.
  /// Basically we use `.fetchIgnoringCacheData` for each page after starting
  /// if the policy is `cache-and-fetch`
  public static func resolvePolicyIf(policy: APICachePolicy, offset: Int) -> APICachePolicy {
    if policy == .returnCacheDataAndFetch {
      return offset == 0 ? policy : .fetchIgnoringCacheData
    } else {
      return policy
    }
  }
}

public enum APIResponseSource {
  case server
  case cache
}
