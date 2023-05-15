import Alamofire
import Foundation

enum Convertible: URLConvertible {
    case getCarInfo(vin: String)
    
    func asURL() throws -> URL {
        switch self {
        case .getCarInfo(let vin):
            let string = "https://autoexpertdevelop.ru/vin/test_data/\(vin)"
            return URL(string: string)!
        }
    }
}
