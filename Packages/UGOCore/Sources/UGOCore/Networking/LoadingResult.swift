
import Foundation

public enum LoadingResult<T> {
    case success(T)
    case error(AppError)
}
