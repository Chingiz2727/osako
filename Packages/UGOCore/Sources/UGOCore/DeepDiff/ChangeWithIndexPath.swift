import Foundation

public class IndexPathConverter {
  
  public init() {}
  
  public func convert<T>(changes: [Change<T>], section: Int) -> ChangeWithIndexPath {
    let inserts = changes.compactMap({ $0.insert }).map({ $0.index.toIndexPath(section: section) })
    let deletes = changes.compactMap({ $0.delete }).map({ $0.index.toIndexPath(section: section) })
    let replaces = changes.compactMap({ $0.replace }).map({ $0.index.toIndexPath(section: section) })
    let moves = changes.compactMap({ $0.move }).map({
      (
        from: $0.fromIndex.toIndexPath(section: section),
        to: $0.toIndex.toIndexPath(section: section)
      )
    })
    
    return ChangeWithIndexPath(
      inserts: inserts,
      deletes: deletes,
      replaces: replaces,
      moves: moves
    )
  }
}

extension Int {
  
  fileprivate func toIndexPath(section: Int) -> IndexPath {
    return IndexPath(item: self, section: section)
  }
}
