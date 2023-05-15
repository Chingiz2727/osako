import Foundation

public protocol TypeNameProvider {
    static var typeName: String { get }
}

public extension TypeNameProvider {
    static var typeName: String {
        return String(describing: Self.self)
    }
}

extension NSObject: TypeNameProvider {}
