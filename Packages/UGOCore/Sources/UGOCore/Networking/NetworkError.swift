import Foundation

public protocol AppError: Error {
    var description: String { get }
}

public enum NetworkError: AppError {
    case serverError(description: String)
    case dataLoad
    case unknown
    case noConnection
    case unauthorized
    case locked
    case cancelled
    
    public var description: String {
        switch self {
        case .serverError(let description):
            return description
        case .dataLoad:
            return "Возникла ошибка при загрузке данных. Приносим свои извинения за доставленные неудобства."
        case .unknown:
            return "Возникла непредвиденная ошибка. Приносим свои извинения за доставленные неудобства."
        case .noConnection:
            return "Отсутствует интернет соединение"
        case .unauthorized:
            return "Неверный логин или пароль"
        case .locked:
            return "Пользователь заблокирован"
        case .cancelled:
            return "Запрос был отменен"
        }
    }
}
