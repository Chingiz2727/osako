import Alamofire

public enum Route: RouteProtocol {
    case login(userName: String, password: String)
    case getData(code: String, page: Int, size: Int)
    
    public var rawValue: String {
        switch self {
        case .login:
            return "test/auth.cgi"
        case .getData:
            return "test/data.cgi"
        }
    }
    
    public var serverUrl: String {
        return "https://www.alarstudios.com/"
    }
}
