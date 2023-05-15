// MARK: - Array + Safe
extension Array {

    /// Safe subscript from "Out of bounds" error
    func element(at index: Index) -> Element? {
        if index >= count || index < 0 {
            return nil
        }
        return self[index]
    }

}

// MARK: - Array + Extra
extension Array {

    func allIndexesWhere(_ block: (Element) throws -> Bool) rethrows -> [Int] {
        var indexes: [Int] = []
        for (index, element) in self.enumerated() {
            if try block(element) {
                indexes.append(index)
            }
        }
        return indexes
    }

    mutating func remove(at indexes: [Int]) {
        var lastIndex: Int? = nil
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}

// MARK: - Array + Next/Prev
extension Array where Element: Hashable {
    
    func next(item: Element) -> Element? {
        if let index = self.firstIndex(of: item) {
            return self.element(at: index + 1)
        }
        return nil
    }

    func prev(item: Element) -> Element? {
        if let index = self.firstIndex(of: item) {
            return self.element(at: index - 1)
        }
        return nil
    }

}

public extension Array {
  func executeIfPresent(_ closure: ([Element]) -> Void) {
    if !isEmpty {
      closure(self)
    }
  }
}
