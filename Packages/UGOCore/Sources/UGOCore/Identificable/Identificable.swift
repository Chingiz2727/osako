// MARK: - Protocol

public protocol Identificable {

    associatedtype Identity: Hashable

    var id: Identity { get }
    
}

// MARK: - Array: Identificable

extension Array where Element: Identificable {

    public func leftUniqueByIdentifiers() -> Self {
        var buffer: [Element] = []
        var added: Set<Element.Identity> = []
        for elem in self {
            if !added.contains(elem.id) {
                buffer.append(elem)
                added.insert(elem.id)
            }
        }
        return buffer
    }

}
